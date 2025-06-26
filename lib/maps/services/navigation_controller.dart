import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigationController {
  final List<LatLng> routePoints;
  int _currentIndex = 0;
  Timer? _timer;

  // Callback to notify UI when arrow marker updates
  final void Function(Marker arrowMarker) onMarkerUpdated;

  NavigationController({
    required this.routePoints,
    required this.onMarkerUpdated, required GoogleMapController mapController,
  });

  void startNavigation() {
    if (routePoints.isEmpty) return;

    _currentIndex = 0;

    // Place initial arrow marker
    Marker arrowMarker = Marker(
      markerId: MarkerId('arrow_marker'),
      position: routePoints[0],
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      rotation: 0,
      anchor: Offset(0.5, 0.5),
      flat: true,
      zIndex: 1000,
    );

    onMarkerUpdated(arrowMarker);

    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _moveArrowAlongRoute();
    });
  }

  void stopNavigation() {
    _timer?.cancel();
  }

  void _moveArrowAlongRoute() {
    if (_currentIndex >= routePoints.length - 1) {
      stopNavigation();
      return;
    }

    final currentPos = routePoints[_currentIndex];
    final nextPos = routePoints[_currentIndex + 1];

    final heading = _calculateHeading(currentPos, nextPos);

    Marker arrowMarker = Marker(
      markerId: MarkerId('arrow_marker'),
      position: nextPos,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      rotation: heading,
      anchor: Offset(0.5, 0.5),
      flat: true,
      zIndex: 1000,
    );

    _currentIndex++;

    onMarkerUpdated(arrowMarker);
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

  void dispose() {}
}
