// // lib/maps/college_map_screen.dart
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:lost_n_found/maps/models/location_data.dart';
// import 'package:lost_n_found/maps/services/directions_service.dart';
// import 'package:lost_n_found/maps/services/map_service.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter_typeahead/flutter_typeahead.dart';

// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? _mapController;
//   final Map<MarkerId, Marker> _markers = {};
//   bool _isLoading = true;
//   bool _locationPermissionGranted = false;
//   List<LocationData> _locations = [];
//   LocationData? _startLocation;
//   LocationData? _endLocation;
//   Polyline? _routeLine;
//   final MapService _mapservice = MapService();
//   final RouteService _routeService = RouteService();

//   static final LatLngBounds _collegeBounds = LatLngBounds(
//     southwest: LatLng(17.4265, 78.4400),
//     northeast: LatLng(17.4293, 78.4460),
//   );

//   static const double _minZoom = 18.2;
//   static const double _maxZoom = 20.0;
//   static const LatLng _collegeCenter = LatLng(17.4280, 78.4435);
//   static const CameraPosition _initialCameraPosition = CameraPosition(
//     target: _collegeCenter,
//     zoom: _minZoom,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissionsAndLoad();
//   }

//   Future<void> _checkPermissionsAndLoad() async {
//     final status = await Permission.location.status;
//     if (!status.isGranted) {
//       final result = await Permission.location.request();
//       _locationPermissionGranted = result.isGranted;
//     } else {
//       _locationPermissionGranted = true;
//     }

//     await _loadMarkersFromBackend();
//   }

//   Future<void> _loadMarkersFromBackend() async {
//     try {
//       final locations = await _mapservice.fetchLocations();
//       final markers = await _mapservice.getMarkersFromLocations(locations);

//       setState(() {
//         _locations = locations;
//         _markers.clear();
//         _markers.addAll(markers.map((k, v) => MapEntry(MarkerId(k), v)));
//         _isLoading = false;
//         _routeLine = null;
//       });

//       if (_mapController != null && locations.isNotEmpty) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _zoomTightlyToMarkers(locations.map((e) => e.position).toList());
//         });
//       }
//     } catch (e) {
//       print('❌ Error loading markers: $e');
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _zoomTightlyToMarkers(List<LatLng> positions) async {
//     if (positions.isEmpty) return;
//     double minLat = positions.first.latitude;
//     double maxLat = positions.first.latitude;
//     double minLng = positions.first.longitude;
//     double maxLng = positions.first.longitude;

//     for (final pos in positions) {
//       minLat = min(minLat, pos.latitude);
//       maxLat = max(maxLat, pos.latitude);
//       minLng = min(minLng, pos.longitude);
//       maxLng = max(maxLng, pos.longitude);
//     }

//     final bounds = LatLngBounds(
//       southwest: LatLng(minLat, minLng),
//       northeast: LatLng(maxLat, maxLng),
//     );

//     final padding = 20.0;
//     await _mapController?.animateCamera(
//       CameraUpdate.newLatLngBounds(bounds, padding),
//     );
//   }

//   void _enforceZoomLimits(CameraPosition position) {
//     if (_mapController == null) return;
//     double currentZoom = position.zoom;
//     if (currentZoom < _minZoom) {
//       _mapController!.moveCamera(CameraUpdate.zoomTo(_minZoom));
//     } else if (currentZoom > _maxZoom) {
//       _mapController!.moveCamera(CameraUpdate.zoomTo(_maxZoom));
//     }
//   }

//   void _checkMapCenter() async {
//     if (_mapController == null) return;
//     final screenCenter = ScreenCoordinate(
//       x: MediaQuery.of(context).size.width ~/ 2,
//       y: MediaQuery.of(context).size.height ~/ 2,
//     );
//     final center = await _mapController!.getLatLng(screenCenter);
//     if (!_collegeBounds.contains(center)) {
//       _mapController!.animateCamera(CameraUpdate.newLatLng(_collegeCenter));
//     }
//   }

//   Future<void> _updateMapWithRoute() async {
//   final markers = await _mapservice.getMarkersFromLocations(
//     _locations,
//     highlight1: _startLocation,
//     highlight2: _endLocation,
//   );

//   List<LatLng> routePoints = [];

//   if (_startLocation != null && _endLocation != null) {
//     routePoints = await _routeService.getRouteCoordinates(
//       _startLocation!.position,
//       _endLocation!.position,
//     );
//   }

//   setState(() {
//     _markers.clear();
//     _markers.addAll(markers.map((k, v) => MapEntry(MarkerId(k), v)));

//     if (routePoints.isNotEmpty) {
//       _routeLine = Polyline(
//         polylineId: PolylineId('route'),
//         color: Colors.purple,
//         width: 5,
//         points: routePoints,
//       );
//     } else {
//       _routeLine = null;
//     }
//   });
// }

//   Widget _buildTypeAheadField(String label, bool isStart) {
//     return TypeAheadField<LocationData>(
//       suggestionsCallback: (pattern) async {
//         if (pattern.isEmpty) return [];
//         return _locations
//             .where((loc) => loc.name.toLowerCase().contains(pattern.toLowerCase()))
//             .toList();
//       },
//       itemBuilder: (context, suggestion) => ListTile(
//         dense: true,
//         visualDensity: VisualDensity.compact,
//         title: Text(suggestion.name, style: TextStyle(fontSize: 14)),
//       ),
//       onSelected: (LocationData suggestion) async {
//         setState(() {
//           if (isStart) {
//             _startLocation = suggestion;
//           } else {
//             _endLocation = suggestion;
//           }
//         });
//         await _updateMapWithRoute();
//       },
//       emptyBuilder: (context) => SizedBox.shrink(),
//       builder: (context, controller, focusNode) => Padding(
//         padding: const EdgeInsets.symmetric(vertical: 4),
//         child: TextField(
//           controller: controller,
//           focusNode: focusNode,
//           style: const TextStyle(fontSize: 14),
//           decoration: InputDecoration(
//             prefixIcon: Icon(Icons.search, size: 18),
//             contentPadding: const EdgeInsets.symmetric(
//               vertical: 10,
//               horizontal: 12,
//             ),
//             labelText: label,
//             labelStyle: TextStyle(fontSize: 14),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           const SizedBox(height: 40),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Column(
//               children: [
//                 _buildTypeAheadField("From", true),
//                 const SizedBox(height: 4),
//                 _buildTypeAheadField("To", false),
//               ],
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : GoogleMap(
//                     initialCameraPosition: _initialCameraPosition,
//                     markers: Set<Marker>.of(_markers.values),
//                     polylines: _routeLine != null ? {_routeLine!} : {},
//                     myLocationEnabled: _locationPermissionGranted,
//                     zoomControlsEnabled: true,
//                     mapType: MapType.normal,
//                     cameraTargetBounds: CameraTargetBounds(_collegeBounds),
//                     onMapCreated: (controller) async {
//                       _mapController = controller;
//                       try {
//                         final style = await rootBundle.loadString('assets/map_style.json');
//                         _mapController?.setMapStyle(style);
//                       } catch (_) {
//                         print("No map style found, continuing.");
//                       }
//                       if (_markers.isNotEmpty) {
//                         _zoomTightlyToMarkers(
//                           _markers.values.map((m) => m.position).toList(),
//                         );
//                       }
//                     },
//                     onCameraMove: _enforceZoomLimits,
//                     onCameraIdle: _checkMapCenter,
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // import 'dart:async';
// // import 'dart:math' as math;
// // import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:lost_n_found/maps/models/location_data.dart';
// // import 'package:lost_n_found/maps/services/directions_service.dart';
// // import 'package:lost_n_found/maps/services/map_service.dart';
// // import 'package:lost_n_found/maps/services/navigation_controller.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:flutter/services.dart' show rootBundle;
// // import 'package:flutter_typeahead/flutter_typeahead.dart';

// // class MapScreen extends StatefulWidget {
// //   @override
// //   _MapScreenState createState() => _MapScreenState();
// // }

// // class _MapScreenState extends State<MapScreen> {
// //   GoogleMapController? _mapController;
// //   final Map<MarkerId, Marker> _markers = {};
// //   bool _isLoading = true;
// //   bool _locationPermissionGranted = false;
// //   List<LocationData> _locations = [];
// //   LocationData? _startLocation;
// //   LocationData? _endLocation;
// //   Polyline? _routeLine;
// //   final MapService _mapservice = MapService();
// //   final RouteService _routeService = RouteService();

// //   NavigationController? _navigationController;
// //   bool _isNavigating = false;

// //   static final LatLngBounds _collegeBounds = LatLngBounds(
// //     southwest: LatLng(17.4265, 78.4400),
// //     northeast: LatLng(17.4293, 78.4460),
// //   );

// //   static const double _minZoom = 18.2;
// //   static const double _maxZoom = 20.0;
// //   static const LatLng _collegeCenter = LatLng(17.4280, 78.4435);
// //   static const CameraPosition _initialCameraPosition = CameraPosition(
// //     target: _collegeCenter,
// //     zoom: _minZoom,
// //   );

// //   @override
// //   void initState() {
// //     super.initState();
// //     _checkPermissionsAndLoad();
// //   }

// //   Future<void> _checkPermissionsAndLoad() async {
// //     final status = await Permission.location.status;
// //     if (!status.isGranted) {
// //       final result = await Permission.location.request();
// //       _locationPermissionGranted = result.isGranted;
// //     } else {
// //       _locationPermissionGranted = true;
// //     }

// //     await _loadMarkersFromBackend();
// //   }

// //   Future<void> _loadMarkersFromBackend() async {
// //     try {
// //       final locations = await _mapservice.fetchLocations();
// //       final markers = await _mapservice.getMarkersFromLocations(locations);

// //       setState(() {
// //         _locations = locations;
// //         _markers.clear();
// //         _markers.addAll(markers.map((k, v) => MapEntry(MarkerId(k), v)));
// //         _isLoading = false;
// //         _routeLine = null;
// //       });

// //       if (_mapController != null && locations.isNotEmpty) {
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           _zoomTightlyToMarkers(locations.map((e) => e.position).toList());
// //         });
// //       }
// //     } catch (e) {
// //       print('❌ Error loading markers: $e');
// //       setState(() => _isLoading = false);
// //     }
// //   }

// //   Future<void> _zoomTightlyToMarkers(List<LatLng> positions) async {
// //     if (positions.isEmpty) return;
// //     double minLat = positions.first.latitude;
// //     double maxLat = positions.first.latitude;
// //     double minLng = positions.first.longitude;
// //     double maxLng = positions.first.longitude;

// //     for (final pos in positions) {
// //       minLat = math.min(minLat, pos.latitude);
// //       maxLat = math.max(maxLat, pos.latitude);
// //       minLng = math.min(minLng, pos.longitude);
// //       maxLng = math.max(maxLng, pos.longitude);
// //     }

// //     final bounds = LatLngBounds(
// //       southwest: LatLng(minLat, minLng),
// //       northeast: LatLng(maxLat, maxLng),
// //     );

// //     final padding = 40.0;
// //     await _mapController?.animateCamera(
// //       CameraUpdate.newLatLngBounds(bounds, padding),
// //     );
// //   }

// //   void _enforceZoomLimits(CameraPosition position) {
// //     if (_mapController == null) return;
// //     double currentZoom = position.zoom;
// //     if (currentZoom < _minZoom) {
// //       _mapController!.moveCamera(CameraUpdate.zoomTo(_minZoom));
// //     } else if (currentZoom > _maxZoom) {
// //       _mapController!.moveCamera(CameraUpdate.zoomTo(_maxZoom));
// //     }
// //   }

// //   void _checkMapCenter() async {
// //     if (_mapController == null) return;
// //     final screenCenter = ScreenCoordinate(
// //       x: MediaQuery.of(context).size.width ~/ 2,
// //       y: MediaQuery.of(context).size.height ~/ 2,
// //     );
// //     final center = await _mapController!.getLatLng(screenCenter);
// //     if (!_collegeBounds.contains(center)) {
// //       _mapController!.animateCamera(CameraUpdate.newLatLng(_collegeCenter));
// //     }
// //   }

// //   Future<void> _updateMapWithRoute() async {
// //     final markers = await _mapservice.getMarkersFromLocations(
// //       _locations,
// //       highlight1: _startLocation,
// //       highlight2: _endLocation,
// //     );

// //     List<LatLng> routePoints = [];

// //     if (_startLocation != null && _endLocation != null) {
// //       routePoints = await _routeService.getRouteCoordinates(
// //         _startLocation!.position,
// //         _endLocation!.position,
// //       );
// //     }

// //     setState(() {
// //       _markers.clear();
// //       _markers.addAll(markers.map((k, v) => MapEntry(MarkerId(k), v)));

// //       if (routePoints.isNotEmpty) {
// //         _routeLine = Polyline(
// //           polylineId: PolylineId('route'),
// //           color: Colors.purple,
// //           width: 5,
// //           points: routePoints,
// //         );
// //       } else {
// //         _routeLine = null;
// //       }
// //     });

// //     if (routePoints.isNotEmpty) {
// //       _zoomTightlyToMarkers(routePoints);
// //     }
// //   }

// //   void _startNavigation() {
// //     if (_startLocation == null || _endLocation == null || _routeLine == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Please select valid From and To locations')),
// //       );
// //       return;
// //     }
// //     if (_navigationController != null) {
// //       _navigationController!.dispose();
// //     }
// //     _navigationController = NavigationController(
// //       mapController: _mapController!,
// //       routePoints: _routeLine!.points, onMarkerUpdated: (Marker arrowMarker) {  },
// //     );
// //     _navigationController!.startNavigation();

// //     setState(() {
// //       _isNavigating = true;
// //     });
// //   }

// //   Widget _buildTypeAheadField(String label, bool isStart) {
// //     return TypeAheadField<LocationData>(
// //       suggestionsCallback: (pattern) async {
// //         if (pattern.isEmpty) return [];
// //         return _locations
// //             .where((loc) => loc.name.toLowerCase().contains(pattern.toLowerCase()))
// //             .toList();
// //       },
// //       itemBuilder: (context, suggestion) => ListTile(
// //         dense: true,
// //         visualDensity: VisualDensity.compact,
// //         title: Text(suggestion.name, style: TextStyle(fontSize: 14)),
// //       ),
// //       onSelected: (LocationData suggestion) async {
// //         setState(() {
// //           if (isStart) {
// //             _startLocation = suggestion;
// //           } else {
// //             _endLocation = suggestion;
// //           }
// //           _isNavigating = false; // reset nav on new selection
// //         });
// //         await _updateMapWithRoute();
// //       },
// //       emptyBuilder: (context) => SizedBox.shrink(),
// //       builder: (context, controller, focusNode) => Padding(
// //         padding: const EdgeInsets.symmetric(vertical: 6),
// //         child: TextField(
// //           controller: controller,
// //           focusNode: focusNode,
// //           style: const TextStyle(fontSize: 14),
// //           decoration: InputDecoration(
// //             prefixIcon: Icon(Icons.search, size: 18),
// //             contentPadding: const EdgeInsets.symmetric(
// //               vertical: 12,
// //               horizontal: 14,
// //             ),
// //             labelText: label,
// //             labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(10),
// //             ),
// //             filled: true,
// //             fillColor: Colors.grey.shade100,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _navigationController?.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       // backgroundColor: Colors.white,
// //       body: SafeArea(
// //         child: Column(
// //           children: [
// //             const SizedBox(height: 12),
// //             Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //               child: Column(
// //                 children: [
// //                   _buildTypeAheadField("From", true),
// //                   const SizedBox(height: 8),
// //                   _buildTypeAheadField("To", false),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             Expanded(
// //               child: _isLoading
// //                   ? const Center(child: CircularProgressIndicator())
// //                   : GoogleMap(
// //                       initialCameraPosition: _initialCameraPosition,
// //                       markers: Set<Marker>.of(_markers.values),
// //                       polylines: _routeLine != null ? {_routeLine!} : {},
// //                       myLocationEnabled: _locationPermissionGranted,
// //                       zoomControlsEnabled: true,
// //                       mapType: MapType.normal,
// //                       cameraTargetBounds: CameraTargetBounds(_collegeBounds),
// //                       onMapCreated: (controller) async {
// //                         _mapController = controller;
// //                         try {
// //                           final style = await rootBundle.loadString('assets/map_style.json');
// //                           _mapController?.setMapStyle(style);
// //                         } catch (_) {
// //                           print("No map style found, continuing.");
// //                         }
// //                         if (_markers.isNotEmpty) {
// //                           _zoomTightlyToMarkers(
// //                             _markers.values.map((m) => m.position).toList(),
// //                           );
// //                         }
// //                       },
// //                       onCameraMove: _enforceZoomLimits,
// //                       onCameraIdle: _checkMapCenter,
// //                     ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       floatingActionButton: FloatingActionButton.extended(
// //         onPressed: _isNavigating ? null : _startNavigation,
// //         label: Text('Start Navigation'),
// //         icon: Icon(Icons.directions),
// //         backgroundColor: _isNavigating ? Colors.grey : Colors.deepPurple,
// //       ),
// //       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
// //     );
// //   }
// // }

//UI set ==========================================================================================================
// lib/maps/college_map_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lost_n_found/maps/models/location_data.dart';
import 'package:lost_n_found/maps/services/directions_service.dart';
import 'package:lost_n_found/maps/services/map_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final MapService _mapservice = MapService();
  final RouteService _routeService = RouteService();

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
      final locations = await _mapservice.fetchLocations();
      final markers = await _mapservice.getMarkersFromLocations(locations);

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
    final markers = await _mapservice.getMarkersFromLocations(
      _locations,
      highlight1: _startLocation,
      highlight2: _endLocation,
    );

    List<LatLng> routePoints = [];

    if (_startLocation != null && _endLocation != null) {
      routePoints = await _routeService.getRouteCoordinates(
        _startLocation!.position,
        _endLocation!.position,
      );
    }

    setState(() {
      _markers.clear();
      _markers.addAll(markers.map((k, v) => MapEntry(MarkerId(k), v)));

      if (routePoints.isNotEmpty) {
        _routeLine = Polyline(
          polylineId: PolylineId('route'),
          color: Colors.teal,
          width: 5,
          points: routePoints,
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
            .where(
              (loc) => loc.name.toLowerCase().contains(pattern.toLowerCase()),
            )
            .toList();
      },
      itemBuilder:
          (context, suggestion) => ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Text(
              suggestion.name,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
            ),
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
      emptyBuilder: (context) => const SizedBox.shrink(),
      builder:
          (context, controller, focusNode) => TextField(
            controller: controller,
            focusNode: focusNode,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                size: 18,
                color: Colors.black,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
              labelText: label,
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Search Route",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTypeAheadField("From", true),
                  const SizedBox(height: 8),
                  _buildTypeAheadField("To", false),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed:
                          _startLocation != null && _endLocation != null
                              ? _updateMapWithRoute
                              : null,
                      icon: const Icon(Icons.search, color: Colors.black),
                      label: Text(
                        "Search Route",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF9C438),
                        disabledBackgroundColor: const Color(
                          0xFFF9C438,
                        ).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: GoogleMap(
                          initialCameraPosition: _initialCameraPosition,
                          markers: Set<Marker>.of(_markers.values),
                          polylines: _routeLine != null ? {_routeLine!} : {},
                          myLocationEnabled: _locationPermissionGranted,
                          zoomControlsEnabled: true,
                          mapType: MapType.normal,
                          cameraTargetBounds: CameraTargetBounds(
                            _collegeBounds,
                          ),
                          onMapCreated: (controller) async {
                            _mapController = controller;
                            try {
                              final style = await rootBundle.loadString(
                                'assets/map_style.json',
                              );
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
            ),
          ],
        ),
      ),
    );
  }
}
