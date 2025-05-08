/* to store the Item details to firebase*///work when submit button is clicked
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StoreData extends StatefulWidget {
  const StoreData({
    super.key,
    required this.titleController,
    required this.status,
    required this.discriptionController,
    required this.imageUrl,
  });

  final TextEditingController titleController;
  final String status;
  final TextEditingController discriptionController;
  final String imageUrl;

  @override
  State<StoreData> createState() => _StoreDataState();
}

class _StoreDataState extends State<StoreData> {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('lost&found_list');

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () async {
        final title = widget.titleController.text.trim();
        final description = widget.discriptionController.text.trim();
        final imageUrl = widget.imageUrl;

        if (title.isEmpty || description.isEmpty || imageUrl.isEmpty || widget.status == 'Status') {
          _showSnackBar('Please complete all fields');
          return;
        }

        try {
          final User user = FirebaseAuth.instance.currentUser!;
          Map<String, String> dataToStore = {
            'title': title,
            'status': widget.status,
            'discription': description,
            'image': imageUrl,
            'userId': user.uid,
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
