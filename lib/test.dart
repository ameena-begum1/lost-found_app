// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/services.dart' show rootBundle;

// class CollegeMapScreen extends StatefulWidget {
//   @override
//   _CollegeMapScreenState createState() => _CollegeMapScreenState();
// }

// class _CollegeMapScreenState extends State<CollegeMapScreen> {
//   GoogleMapController? _mapController;
//   final Map<MarkerId, Marker> _markers = {};
//   bool _isLoading = true;
//   bool _locationPermissionGranted = false;

//   // SUES college boundary limits (based on your actual markers)
//   static final LatLngBounds _collegeBounds = LatLngBounds(
//     southwest: LatLng(17.4265, 78.4400),
//     northeast: LatLng(17.4293, 78.4460),
//   );

//   static const double _minZoom = 18.2;
//   static const double _maxZoom = 20.0;

//   // Initial position is center of SUES
//   static const LatLng _collegeCenter = LatLng(17.4280, 78.4435);
//   static const CameraPosition _initialCameraPosition =
//       CameraPosition(target: _collegeCenter, zoom: _minZoom);

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissionsAndLoad();
//   }

//   Future<void> _checkPermissionsAndLoad() async {
//     final status = await Permission.location.status;
//     if (!status.isGranted) {
//       final result = await Permission.location.request();
//       setState(() => _locationPermissionGranted = result.isGranted);
//     } else {
//       setState(() => _locationPermissionGranted = true);
//     }

//     await _loadMarkersFromFirestore();
//   }

//   Future<void> _loadMarkersFromFirestore() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance.collection('locations').get();

//       final Map<MarkerId, Marker> newMarkers = {};
//       List<LatLng> positions = [];

//       int index = 0;
//       for (var doc in snapshot.docs) {
//         final data = doc.data();
//         final lat = data['latitude'];
//         final lng = data['longitude'];
//         final name = data['name'] ?? 'Location';

//         if (lat is double && lng is double) {
//           final pos = LatLng(lat, lng);
//           final markerId = MarkerId('marker_$index');

//           final marker = Marker(
//             markerId: markerId,
//             position: pos,
//             infoWindow: InfoWindow(title: name),
//             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//           );

//           newMarkers[markerId] = marker;
//           positions.add(pos);
//           index++;
//         }
//       }

//       setState(() {
//         _markers.clear();
//         _markers.addAll(newMarkers);
//         _isLoading = false;
//       });

//       if (_mapController != null && positions.isNotEmpty) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _zoomTightlyToMarkers(positions);
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

//     // Zoom in close (low padding so markers are not tight)
//     final padding = 20.0;
//     await _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, padding));
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

//     ScreenCoordinate screenCenter = ScreenCoordinate(
//       x: MediaQuery.of(context).size.width ~/ 2,
//       y: MediaQuery.of(context).size.height ~/ 2,
//     );

//     LatLng center = await _mapController!.getLatLng(screenCenter);
//     if (!_collegeBounds.contains(center)) {
//       _mapController!.animateCamera(CameraUpdate.newLatLng(_collegeCenter));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('SUES Maps'),
//         backgroundColor: Color(0xFFFFFF33),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : GoogleMap(
//               initialCameraPosition: _initialCameraPosition,
//               markers: Set<Marker>.of(_markers.values),
//               myLocationEnabled: _locationPermissionGranted,
//               zoomControlsEnabled: true,
//               mapType: MapType.normal,
//               cameraTargetBounds: CameraTargetBounds(_collegeBounds),
//               onMapCreated: (controller) async {
//                 _mapController = controller;

//                 try {
//                   final style = await rootBundle.loadString('assets/map_style.json');
//                   _mapController?.setMapStyle(style);
//                 } catch (_) {
//                   print("No map style found, continuing.");
//                 }

//                 if (_markers.isNotEmpty) {
//                   _zoomTightlyToMarkers(_markers.values.map((m) => m.position).toList());
//                 }
//               },
//               onCameraMove: _enforceZoomLimits,
//               onCameraIdle: _checkMapCenter,
//             ),
//     );
//   }
// }
