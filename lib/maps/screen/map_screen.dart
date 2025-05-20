// lib/maps/college_map_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lost_n_found/items/backend_services/maps.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_typeahead/flutter_typeahead.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Map<MarkerId, Marker> _markers = {};
  bool _isLoading = true;
  bool _locationPermissionGranted = false;
  List<LocationData> _locations = [];
  LocationData? _startLocation;
  LocationData? _endLocation;
  Polyline? _routeLine;
  final _service = MapService();

  static final LatLngBounds _collegeBounds = LatLngBounds(
    southwest: LatLng(17.4265, 78.4400),
    northeast: LatLng(17.4293, 78.4460),
  );

  static const double _minZoom = 18.2;
  static const double _maxZoom = 20.0;
  static const LatLng _collegeCenter = LatLng(17.4280, 78.4435);
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: _collegeCenter,
    zoom: _minZoom,
  );

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoad();
  }

  Future<void> _checkPermissionsAndLoad() async {
    final status = await Permission.location.status;
    if (!status.isGranted) {
      final result = await Permission.location.request();
      _locationPermissionGranted = result.isGranted;
    } else {
      _locationPermissionGranted = true;
    }

    await _loadMarkersFromBackend();
  }

  Future<void> _loadMarkersFromBackend() async {
    try {
      final locations = await _service.fetchLocations();
      final markers = await _service.getMarkersFromLocations(locations);

      setState(() {
        _locations = locations;
        _markers.clear();
        _markers.addAll(markers.map((k, v) => MapEntry(MarkerId(k), v)));
        _isLoading = false;
        _routeLine = null;
      });

      if (_mapController != null && locations.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _zoomTightlyToMarkers(locations.map((e) => e.position).toList());
        });
      }
    } catch (e) {
      print('❌ Error loading markers: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _zoomTightlyToMarkers(List<LatLng> positions) async {
    if (positions.isEmpty) return;
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final pos in positions) {
      minLat = min(minLat, pos.latitude);
      maxLat = max(maxLat, pos.latitude);
      minLng = min(minLng, pos.longitude);
      maxLng = max(maxLng, pos.longitude);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    final padding = 20.0;
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, padding),
    );
  }

  void _enforceZoomLimits(CameraPosition position) {
    if (_mapController == null) return;
    double currentZoom = position.zoom;
    if (currentZoom < _minZoom) {
      _mapController!.moveCamera(CameraUpdate.zoomTo(_minZoom));
    } else if (currentZoom > _maxZoom) {
      _mapController!.moveCamera(CameraUpdate.zoomTo(_maxZoom));
    }
  }

  void _checkMapCenter() async {
    if (_mapController == null) return;
    final screenCenter = ScreenCoordinate(
      x: MediaQuery.of(context).size.width ~/ 2,
      y: MediaQuery.of(context).size.height ~/ 2,
    );
    final center = await _mapController!.getLatLng(screenCenter);
    if (!_collegeBounds.contains(center)) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(_collegeCenter));
    }
  }

  Future<void> _updateMapWithRoute() async {
    final markers = await _service.getMarkersFromLocations(
      _locations,
      highlight1: _startLocation,
      highlight2: _endLocation,
    );

    setState(() {
      _markers.clear();
      _markers.addAll(markers.map((k, v) => MapEntry(MarkerId(k), v)));

      if (_startLocation != null && _endLocation != null) {
        _routeLine = Polyline(
          polylineId: PolylineId('route'),
          color: Colors.purple,
          width: 5,
          points: [_startLocation!.position, _endLocation!.position],
        );
      } else {
        _routeLine = null;
      }
    });
  }

  Widget _buildTypeAheadField(String label, bool isStart) {
    return TypeAheadField<LocationData>(
      suggestionsCallback: (pattern) async {
        if (pattern.isEmpty) return [];
        return _locations
            .where((loc) => loc.name.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, suggestion) => ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        title: Text(suggestion.name, style: TextStyle(fontSize: 14)),
      ),
      onSelected: (LocationData suggestion) async {
        setState(() {
          if (isStart) {
            _startLocation = suggestion;
          } else {
            _endLocation = suggestion;
          }
        });
        await _updateMapWithRoute();
      },
      emptyBuilder: (context) => SizedBox.shrink(),
      builder: (context, controller, focusNode) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, size: 18),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
            labelText: label,
            labelStyle: TextStyle(fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildTypeAheadField("From", true),
                const SizedBox(height: 4),
                _buildTypeAheadField("To", false),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: _initialCameraPosition,
                    markers: Set<Marker>.of(_markers.values),
                    polylines: _routeLine != null ? {_routeLine!} : {},
                    myLocationEnabled: _locationPermissionGranted,
                    zoomControlsEnabled: true,
                    mapType: MapType.normal,
                    cameraTargetBounds: CameraTargetBounds(_collegeBounds),
                    onMapCreated: (controller) async {
                      _mapController = controller;
                      try {
                        final style = await rootBundle.loadString('assets/map_style.json');
                        _mapController?.setMapStyle(style);
                      } catch (_) {
                        print("No map style found, continuing.");
                      }
                      if (_markers.isNotEmpty) {
                        _zoomTightlyToMarkers(
                          _markers.values.map((m) => m.position).toList(),
                        );
                      }
                    },
                    onCameraMove: _enforceZoomLimits,
                    onCameraIdle: _checkMapCenter,
                  ),
          ),
        ],
      ),
    );
  }
}
