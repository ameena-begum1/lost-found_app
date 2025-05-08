import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemDetailScreen extends StatelessWidget {
  ItemDetailScreen(this.itemId, {super.key}) {
    _reference = FirebaseFirestore.instance
        .collection('lost&found_list')
        .doc(itemId);
    _futureData = _reference.get();
  }

  final String itemId;
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Item Details")),
      body: FutureBuilder<DocumentSnapshot>(
        future: _futureData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching data: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            // Extract item data from Firestore
            DocumentSnapshot documentSnapshot = snapshot.data!;
            Map<String, dynamic> data =
                documentSnapshot.data() as Map<String, dynamic>;

            // Fetch user data based on userId from the item
            String userId =
                data['userId'] ?? ''; // Default to empty string if null
            DocumentReference userReference = FirebaseFirestore.instance
                .collection('user_profile')
                .doc(userId);
            Future<DocumentSnapshot> userFuture = userReference.get();

            return FutureBuilder<DocumentSnapshot>(
              future: userFuture,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error fetching user data: ${userSnapshot.error}',
                    ),
                  );
                }

                if (userSnapshot.hasData) {
                  Map<String, dynamic> userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display Item Image
                        Center(
                          child:
                              (data['image'] != null &&
                                      data['image'].toString().isNotEmpty)
                                  ? Image.network(
                                    data['image'],
                                    width: 300,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    width: 300,
                                    height: 300,
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 100,
                                      color: Colors.black54,
                                    ),
                                  ),
                        ),
                        const SizedBox(height: 16),

                        // Item Details Section
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Item Title
                              Text(
                                data['title'],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Status
                              Text(
                                "Status: ${data['status']}",
                                style: TextStyle(
                                  color:
                                      data['status'] == "Lost"
                                          ? Colors.red
                                          : Colors.green,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Item Description
                              Text(
                                data['discription'], // Default text if null
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Divider(height: 32),

                              // User Info Section (Dynamic user data)
                              const Text('Posted by'),
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      userData['ProfileImageUrl'] != null
                                          ? NetworkImage(
                                            userData['ProfileImageUrl'] ?? '',
                                          )
                                          : null,
                                  child:
                                      userData['ProfileImageUrl'] == null
                                          ? const Icon(Icons.person)
                                          : null,
                                ),
                                title: Text(
                                  userData['Name'] ?? 'Unknown User',
                                ), // Default text if null
                              ),
                              const Divider(height: 32),

                              // Action Button (Found / Claim)
                              ElevatedButton(
                                onPressed: () {
                                  // Implement item status update functionality
                                },
                                child: Text(
                                  data['status'] == 'Lost'
                                      ? 'Found Item'
                                      : 'Claim Item',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text("No user data found"));
              },
            );
          }
          return const Center(child: Text("No item data found"));
        },
      ),
    );
  }
}
