import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';


class NavigationController {
  final List<LatLng> routePoints;
  final GoogleMapController mapController;
  final void Function(Marker arrowMarker) onMarkerUpdated;

  int _currentIndex = 0;
  Timer? _timer;
  late BitmapDescriptor _customIcon;

  NavigationController({
    required this.routePoints,
    required this.onMarkerUpdated,
    required this.mapController,
  });

  Future<void> startNavigation() async {
    if (routePoints.isEmpty) return;

    _currentIndex = 0;
_customIcon = await _getBitmapDescriptorFromIcon(
  Symbols.assistant_navigation, 
Color(0xFF1F51FF),
  size: 90,
);

    // Place initial arrow marker
    final initialMarker = _createArrowMarker(routePoints[0], 0);
    onMarkerUpdated(initialMarker);

    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _moveArrowAlongRoute();
    });
  }

  void _moveArrowAlongRoute() {
    if (_currentIndex >= routePoints.length - 1) {
      stopNavigation();
      return;
    }

    final currentPos = routePoints[_currentIndex];
    final nextPos = routePoints[_currentIndex + 1];
    final heading = _calculateHeading(currentPos, nextPos);

    final arrowMarker = _createArrowMarker(nextPos, heading);
    _currentIndex++;

    onMarkerUpdated(arrowMarker);

    // Move camera with marker
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: nextPos,
          zoom: 19.8,
          tilt: 45,
          bearing: heading,
        ),
      ),
    );
  }

  Marker _createArrowMarker(LatLng position, double rotation) {
    return Marker(
      markerId: const MarkerId('arrow_marker'),
      position: position,
      icon: _customIcon,
      rotation: rotation,
      anchor: const Offset(0.5, 0.5),
      flat: true,
      zIndex: 1000,
    );
  }

  void stopNavigation() {
    _timer?.cancel();
  }

  void dispose() {
    stopNavigation();
  }

  double _calculateHeading(LatLng from, LatLng to) {
    final lat1 = _degreesToRadians(from.latitude);
    final lon1 = _degreesToRadians(from.longitude);
    final lat2 = _degreesToRadians(to.latitude);
    final lon2 = _degreesToRadians(to.longitude);
    final dLon = lon2 - lon1;

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final bearing = math.atan2(y, x);
    return (bearing * 180 / math.pi + 360) % 360;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  Future<BitmapDescriptor> _getBitmapDescriptorFromIcon(
    IconData icon,
    Color color, {
    double size = 80,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: color,
      ),
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);

    final image = await pictureRecorder.endRecording().toImage(
      textPainter.width.toInt(),
      textPainter.height.toInt(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(buffer);
  }
}

