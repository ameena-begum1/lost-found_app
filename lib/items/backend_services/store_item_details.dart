/* to store the Item details to firebase*/ //work when submit button is clicked
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
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
        }

        try {
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
          print('Data added successfully');
          _showSnackBar('Submitted Successfully!');
        } catch (error) {
          print('Error adding data: $error');
          _showSnackBar('Failed to submit. Please try again.');
        }
      },
      child: const Text('Submit'),
    );
  }
}
