import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lost_n_found/maps/models/location_data.dart';
import 'package:lost_n_found/maps/services/directions_service.dart';
import 'package:lost_n_found/maps/services/map_service.dart';
import 'package:lost_n_found/maps/services/navigation_controller.dart';
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
  bool _isLoading = true, _locationPermissionGranted = false;
  List<LocationData> _locations = [];
  LocationData? _startLocation, _endLocation;
  Polyline? _routeLine;
  bool _isNavigating = false;
  StreamSubscription<Position>? _positionStream;

  static final LatLngBounds _collegeBounds = LatLngBounds(
    southwest: LatLng(17.4265, 78.4400),
    northeast: LatLng(17.4293, 78.4460),
  );

  static const double _minZoom = 18.2, _maxZoom = 20.0;
  static const LatLng _collegeCenter = LatLng(17.4280, 78.4435);
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: _collegeCenter,
    zoom: _minZoom,
  );

  @override
  void initState() {
    super.initState();
    _initPermissions();
  }

  Future<void> _initPermissions() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    if (await Geolocator.isLocationServiceEnabled()) {
      _locationPermissionGranted = true;
    }

    await _loadMarkers();
  }

  Future<LatLng?> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  Future<void> _loadMarkers() async {
    final locations = await MapService().fetchLocations();
    final markers = await MapService().getMarkersFromLocations(locations);
    setState(() {
      _locations = locations;
      _markers.addAll(markers.map((k, v) => MapEntry(MarkerId(k), v)));
      _isLoading = false;
    });

    if (_mapController != null && locations.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _zoomTightlyToMarkers(locations.map((e) => e.position).toList());
      });
    }
  }

  Future<void> _zoomTightlyToMarkers(List<LatLng> pts) async {
    final lats = pts.map((p) => p.latitude), lngs = pts.map((p) => p.longitude);
    final bounds = LatLngBounds(
      southwest: LatLng(lats.reduce(math.min), lngs.reduce(math.min)),
      northeast: LatLng(lats.reduce(math.max), lngs.reduce(math.max)),
    );
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  void _updateCamera(LatLng pos, double bearing) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: pos,
          zoom: _maxZoom - 0.2,
          bearing: bearing,
          tilt: 45,
        ),
      ),
    );
  }

  Future<void> _updateRoute() async {
    if (_startLocation == null || _endLocation == null) return;
    final pts = await RouteService().getRouteCoordinates(
      _startLocation!.position,
      _endLocation!.position,
    );
    setState(() {
      _routeLine = pts.isNotEmpty
          ? Polyline(
              polylineId: PolylineId('route'),
              color: Color.fromARGB(255, 79, 174, 251),
              width: 6,
              points: pts,
            )
          : null;
    });
    if (pts.isNotEmpty) _zoomTightlyToMarkers(pts);
  }

  void _startNavigation() async {
    if (_endLocation == null || _mapController == null) return;

    // Get current location if source is not selected
    if (_startLocation == null) {
      final current = await _getCurrentLocation();
      if (current == null) return;
      _startLocation = LocationData(
        id: "current",
        name: "Current Location",
        position: current,
      );
    }

    await _updateRoute();

    final start = _startLocation!.position;

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: start, zoom: _maxZoom - 0.2, tilt: 45),
      ),
    );

    _positionStream?.cancel();
    final arrowIcon = await NavigationController.getArrowIcon();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 2,
      ),
    ).listen((Position pos) {
      final userLatLng = LatLng(pos.latitude, pos.longitude);
      final heading = pos.heading;

      final marker = Marker(
        markerId: MarkerId('arrow_marker'),
        position: userLatLng,
        icon: arrowIcon,
        rotation: heading,
        flat: true,
        anchor: Offset(0.5, 0.5),
        zIndex: 1000,
      );

      setState(() => _markers[MarkerId('arrow_marker')] = marker);
      _updateCamera(userLatLng, heading);
    });

    setState(() => _isNavigating = true);
  }

  Widget _typeAhead(String label, bool isStart) {
    return TypeAheadField<LocationData>(
      suggestionsCallback: (pat) async => pat.isEmpty
          ? []
          : _locations
              .where((l) => l.name.toLowerCase().contains(pat.toLowerCase()))
              .toList(),
      itemBuilder: (context, suggestion) =>
          ListTile(title: Text(suggestion.name)),
      onSelected: (suggestion) async {
        setState(() {
          if (isStart) {
            _startLocation = suggestion;
          } else {
            _endLocation = suggestion;
          }
          _isNavigating = false;
        });
        await _updateRoute();
      },
      emptyBuilder: (context) => SizedBox.shrink(),
      builder: (context, controller, focusNode) => TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.location_on, color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Theme(
      data: ThemeData(
        primaryColor: Color(0xFF00897B),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF00897B),
        ),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _typeAhead('Current Location', true),
                    const SizedBox(height: 8),
                    _typeAhead('To', false),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00897B),
                        ),
                      )
                    : GoogleMap(
                        initialCameraPosition: _initialCameraPosition,
                        myLocationEnabled: _locationPermissionGranted,
                        markers: _markers.values.toSet(),
                        polylines:
                            _routeLine != null ? {_routeLine!} : {},
                        zoomControlsEnabled: true,
                        onMapCreated: (c) async {
                          _mapController = c;
                          try {
                            final style = await rootBundle
                                .loadString('assets/map_style.json');
                            _mapController?.setMapStyle(style);
                          } catch (_) {}
                        },
                      ),
              ),
              if (_endLocation != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: ElevatedButton.icon(
                    onPressed: _isNavigating ? null : _startNavigation,
                    icon: Icon(Icons.navigation, color: Colors.white),
                    label: Text(
                      'Start Navigation',
                      style:
                          TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00897B),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
