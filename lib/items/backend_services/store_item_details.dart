// import 'dart:typed_data';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:lost_n_found/ai_match/match.dart';
// import 'package:lost_n_found/items/screens/item_detail.dart';

// class StoreData extends StatefulWidget {
//   const StoreData({
//     super.key,
//     required this.titleController,
//     required this.status,
//     required this.category,
//     required this.discriptionController,
//     required this.mobilenoController,
//     required this.location,
//     required this.imageUrl,
//   });

//   final TextEditingController titleController;
//   final String status;
//   final String category;
//   final TextEditingController discriptionController;
//   final TextEditingController mobilenoController;
//   final TextEditingController location;
//   final String imageUrl;

//   @override
//   State<StoreData> createState() => _StoreDataState();
// }

// class _StoreDataState extends State<StoreData> {
//   final CollectionReference _reference = FirebaseFirestore.instance.collection(
//     'lost&found_list',
//   );

//   String get oppositeType => widget.status == 'Lost' ? 'Found' : 'Lost';

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FilledButton(
//       onPressed: () async {
//         final title = widget.titleController.text.trim();
//         final description = widget.discriptionController.text.trim();
//         final imageUrl = widget.imageUrl;
//         final mobile_no = widget.mobilenoController.text.trim();
//         final location = widget.location.text.trim();

//         if (title.isEmpty ||
//             description.isEmpty ||
//             imageUrl.isEmpty ||
//             widget.status == 'Status' ||
//             location.isEmpty ||
//             mobile_no.isEmpty) {
//           _showSnackBar('Please complete all fields');
//           return;
//         }

//         if (mobile_no.length != 10) {
//           _showSnackBar('Please enter a valid mobile no.');
//           return;
//         }

//         try {
//           final User user = FirebaseAuth.instance.currentUser!;
//           Map<String, dynamic> dataToStore = {
//             'title': title,
//             'status': widget.status,
//             'category': widget.category,
//             'discription': description,
//             'mobile_no': mobile_no,
//             'location': location,
//             'image': imageUrl,
//             'userId': user.uid,
//             'timestamp': FieldValue.serverTimestamp(),
//           };

//           await _reference.add(dataToStore);

//           // Load newly submitted image
//           final response = await http.get(Uri.parse(imageUrl));
//           if (response.statusCode != 200) {
//             _showSnackBar("Failed to load uploaded image");
//             return;
//           }
//           final Uint8List newImageBytes = response.bodyBytes;

//           final snapshot =
//               await FirebaseFirestore.instance
//                   .collection('lost&found_list')
//                   .where('status', isEqualTo: oppositeType)
//                   .get();

//           for (var doc in snapshot.docs) {
//             final existingImageUrl = doc['image'];
//             if (existingImageUrl == imageUrl) continue; // avoid self-comparison

//             final response2 = await http.get(Uri.parse(existingImageUrl));
//             if (response2.statusCode != 200) continue;

//             final Uint8List existingBytes = response2.bodyBytes;
//             final isMatch = await areImagesSimilar(
//               newImageBytes,
//               existingBytes,
//             );

//             if (isMatch) {
//               // Match found, show dialog with title and image
//               showDialog(
//                 context: context,
//                 builder:
//                     (ctx) => AlertDialog(
//                       title: const Text("AI Match Found!"),
//                       content: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text("Matched item:\nTitle: ${doc['title']}"),
//                           const SizedBox(height: 10),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => ItemDetailScreen(doc.id),
//                                 ),
//                               );
//                             },
//                             child: Image.network(doc['image'], height: 150),
//                           ),
//                         ],
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(ctx),
//                           child: const Text("OK"),
//                         ),
//                       ],
//                     ),
//               );
//               break;
//             }
//           }

//           print('Data added successfully');
//           _showSnackBar('Submitted Successfully!');
//         } catch (error) {
//           print('Error adding data: $error');
//           _showSnackBar('Failed to submit. Please try again.');
//         }
//       },
//       child: const Text('Submit'),
//     );
//   }
// }

//=================================================================================================================

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lost_n_found/smart_item_match/match.dart';
import 'package:lost_n_found/items/screens/item_detail.dart';

class StoreData extends StatefulWidget {
  const StoreData({
    super.key,
    required this.titleController,
    required this.status,
    required this.category,
    required this.discriptionController,
    required this.mobilenoController,
    required this.location,
    required this.imageUrl,
  });

  final TextEditingController titleController;
  final String status;
  final String category;
  final TextEditingController discriptionController;
  final TextEditingController mobilenoController;
  final TextEditingController location;
  final String imageUrl;

  @override
  State<StoreData> createState() => _StoreDataState();
}

class _StoreDataState extends State<StoreData> {
  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'lost&found_list',
  );

  String get oppositeType => widget.status == 'Lost' ? 'Found' : 'Lost';

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: const Color(0xFFFFD74B), // ✅ Updated button color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () async {
        final title = widget.titleController.text.trim();
        final description = widget.discriptionController.text.trim();
        final imageUrl = widget.imageUrl;
        final mobile_no = widget.mobilenoController.text.trim();
        final location = widget.location.text.trim();

        if (title.isEmpty ||
            description.isEmpty ||
            imageUrl.isEmpty ||
            widget.status == 'Status' ||
            location.isEmpty ||
            mobile_no.isEmpty) {
          _showSnackBar('Please complete all fields');
          return;
        }

        if (mobile_no.length != 10) {
          _showSnackBar('Please enter a valid mobile no.');
          return;
        }

        try {
          // Load the newly uploaded image
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode != 200) {
            _showSnackBar("Failed to load uploaded image");
            return;
          }
          final Uint8List newImageBytes = response.bodyBytes;

          // Search for matching opposite-type items
          final snapshot =
              await FirebaseFirestore.instance
                  .collection('lost&found_list')
                  .where('status', isEqualTo: oppositeType)
                  .get();

          for (var doc in snapshot.docs) {
            final existingImageUrl = doc['image'];
            if (existingImageUrl == imageUrl) continue;

            final response2 = await http.get(Uri.parse(existingImageUrl));
            if (response2.statusCode != 200) continue;

            final Uint8List existingBytes = response2.bodyBytes;
            final isMatch = await areImagesSimilar(
              newImageBytes,
              existingBytes,
            );

            if (isMatch) {
              showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      backgroundColor: const Color.fromARGB(255, 213, 255, 251),
                      title: const Text(
                        "FindOra Matched Item!",
                        style: TextStyle(
                          color: Color(0xFF00897B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Looks like someone already submitted this item!\n\nMatched item:\n${doc['title']}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ItemDetailScreen(doc.id),
                                ),
                              );
                            },
                            child: Image.network(doc['image'], height: 150),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            "OK",
                            style: TextStyle(color: Color(0xFF00897B)),
                          ),
                        ),
                      ],
                    ),
              );

              _showSnackBar(
                "Your item matches an existing one. No need to submit again!",
              );
              return;
            }
          }

          // No match found - Proceed to submit
          final User user = FirebaseAuth.instance.currentUser!;
          Map<String, dynamic> dataToStore = {
            'title': title,
            'status': widget.status,
            'category': widget.category,
            'discription': description,
            'mobile_no': mobile_no,
            'location': location,
            'image': imageUrl,
            'userId': user.uid,
            'timestamp': FieldValue.serverTimestamp(),
          };

          await _reference.add(dataToStore);

          _showSnackBar('Submitted Successfully!');
          print('Data added successfully');
        } catch (error) {
          print('Error adding data: $error');
          _showSnackBar('Failed to submit. Please try again.');
        }
      },
      child: const Text('Submit'),
    );
  }
}
