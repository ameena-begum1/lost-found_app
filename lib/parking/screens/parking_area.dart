import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: const Color(0xFFFFFCF5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          tooltip: 'Back to Home',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "SUES Parking Availability",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFF9C438),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parkingSpots.length,
        itemBuilder: (context, index) {
          final spot = parkingSpots[index];
          final bool isAvailable = spot['available'] > 0;
          final IconData icon =
              spot['vehicle'] == 'Car'
                  ? Icons.directions_car
                  : Icons.two_wheeler;
          final Color cardColor = Colors.white;

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
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF3CD),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(icon, size: 28, color: Colors.black),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spot['name'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'For: ${spot['for']} • ${spot['vehicle']}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Icon(
                          isAvailable ? Icons.check_circle : Icons.cancel,
                          color: isAvailable ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAvailable
                              ? '${spot['available']} Spots'
                              : 'No Spots',
                          style: GoogleFonts.poppins(
                            color: isAvailable ? Colors.green : Colors.red,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
