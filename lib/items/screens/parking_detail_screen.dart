import 'package:flutter/material.dart';

class ParkingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> spot;

  const ParkingDetailScreen({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = spot['available'] > 0;
    final IconData icon = spot['vehicle'] == 'Car'
        ? Icons.directions_car
        : Icons.two_wheeler;

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Back to Home',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(spot['name'],),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 60, color: Colors.teal),
            const SizedBox(height: 20),
            Text(
              'Type: ${spot['vehicle']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'For: ${spot['for']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              'Timings: 8:30 AM – 5 PM',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              'Security: Guarded & CCTV Monitored',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              isAvailable
                  ? '${spot['available']} Spots Available'
                  : 'Currently Full',
              style: TextStyle(
                fontSize: 18,
                color: isAvailable ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                // Placeholder for future map navigation
              },
              icon: const Icon(Icons.map),
              label: const Text('View on Map (Coming Soon)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
