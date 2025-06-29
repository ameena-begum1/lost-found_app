import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_data.dart';

class MapService {
  final _collection = FirebaseFirestore.instance.collection('locations');
  Future<List<LocationData>> fetchLocations() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return LocationData(
        id: doc.id,
        name: data['name'] ?? 'Unknown',
        position: LatLng(data['latitude'], data['longitude']),
      );
    }).toList();
  }

  // Generate markers from fetched locations
  Future<Map<String, Marker>> getMarkersFromLocations(
  
    List<LocationData> locations, {
    LocationData? highlight1,
    LocationData? highlight2,
  }) async {
    final Map<String, Marker> markers = {};
    for (var i = 0; i < locations.length; i++) {
      final loc = locations[i];
      markers['marker_$i'] = Marker(
        markerId: MarkerId('marker_$i'),
        position: loc.position,
        infoWindow: InfoWindow(title: loc.name),
        // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        icon: BitmapDescriptor.defaultMarkerWithHue(185), // 180° is teal-ish

      );
    }
    return markers;
  }
}
