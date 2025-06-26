import 'package:flutter/material.dart';
import 'package:lost_n_found/parking/screens/parking_detail.dart';

class ParkingScreen extends StatelessWidget {
  const ParkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> parkingSpots = [
      {
        'name': 'Workshop Gate Car Parking',
        'for': 'Students',
        'vehicle': 'Car',
        'available': 12,
      },
      {
        'name': '2-Wheeler Parking Opp. Veg Canteen',
        'for': 'Students',
        'vehicle': '2-Wheeler',
        'available': 5,
      },
      {
        'name': 'Main Gate Car Parking',
        'for': 'Staff',
        'vehicle': 'Car',
        'available': 0,
      },
      {
        'name': 'Block 5 Staff 2-Wheeler Parking',
        'for': 'Staff',
        'vehicle': '2-Wheeler',
        'available': 9,
      },
      {
        'name': 'Block 5/2 Staff Car Parking',
        'for': 'Staff',
        'vehicle': 'Car',
        'available': 3,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Back to Home',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("SUES Parking Availability",style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color(0xFF00897B),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: parkingSpots.length,
        itemBuilder: (context, index) {
          final spot = parkingSpots[index];
          final bool isAvailable = spot['available'] > 0;
          final IconData icon = spot['vehicle'] == 'Car'
              ? Icons.directions_car
              : Icons.two_wheeler;
          final Color cardColor = isAvailable
              ? Colors.green.shade50
              : Colors.red.shade50;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ParkingDetailScreen(spot: spot),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: cardColor,
              elevation: 4,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(icon, size: 32, color: Colors.teal),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spot['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'For: ${spot['for']} • ${spot['vehicle']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isAvailable
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: isAvailable ? Colors.green : Colors.red,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAvailable
                                ? '${spot['available']} Spots'
                                : 'No Spots',
                            style: TextStyle(
                              color:
                                  isAvailable ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
