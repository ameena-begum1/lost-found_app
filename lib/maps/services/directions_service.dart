import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteService {
  final String googleApiKey = 'AIzaSyDGbhNYVSt6aNgqDQgKhL-Ge0BGiOFnIj0'; 

  // Fetch route coordinates from Google Directions API
  Future<List<LatLng>> getRouteCoordinates(LatLng start, LatLng end) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch directions');
    }

    final data = json.decode(response.body);

    if ((data['routes'] as List).isEmpty) {
      return [];
    }

    final route = data['routes'][0];
    final overviewPolyline = route['overview_polyline']['points'];

    return _decodePolyline(overviewPolyline);
  }

  // Decode polyline from encoded string to List<LatLng>
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}
