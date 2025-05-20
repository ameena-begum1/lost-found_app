import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationData {
  final String id;
  final String name;
  final LatLng position;

  LocationData({required this.id, required this.name, required this.position});
}
