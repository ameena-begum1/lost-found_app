/* Save profile details when edited and fetch*/
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_n_found/items/screens/home_screen.dart';

Future<String?> uploadProfileImage(Uint8List imageBytes) async {
  try {
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('profile_pic');

    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    await referenceImageToUpload.putData(imageBytes);

    String imageUrl = await referenceImageToUpload.getDownloadURL();
    print("Upload successful! Image URL: $imageUrl");
    return imageUrl;
  } catch (error) {
    print('Error uploading image: $error');
    return null;
  }
}

class StoreProfile extends StatefulWidget {
  const StoreProfile({
    super.key,
    required this.nameController,
    required this.rollnoController,
    required this.branch,
    required this.year,
    required this.image,
  });

  final String nameController;
  final String rollnoController;
  final String branch;
  final String year;
  final Uint8List image;

  @override
  State<StoreProfile> createState() {
    return _StoreProfileState();
  }
}

class _StoreProfileState extends State<StoreProfile> {
  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'user_profile',
  );
  bool _isLoading = false; 

  Future<void> saveProfileDetails() async {
    try {
      setState(() {
        _isLoading = true; 
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? imageUrl = await uploadProfileImage(widget.image);
        if (imageUrl != null) {
          Map<String, String> profileToStore = {
            'Name': widget.nameController,
            'Roll no.': widget.rollnoController,
            'Branch': widget.branch,
            'Year': widget.year,
            'ProfileImageUrl': imageUrl,
          };
          await _reference
              .doc(user.uid)
              .set(profileToStore, SetOptions(merge: true));

          print('Data added successfully');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profile saved.')));
          Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image.')),
          );
        }
      }
    } catch (e) {
      print("Error adding user profile: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save profile.')));
    } finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }

bool isFormFilled() {
  return widget.nameController.isNotEmpty &&
      widget.rollnoController.isNotEmpty &&
      widget.branch.isNotEmpty &&
      widget.year != 'Year'; 
}


  @override
Widget build(BuildContext context) {
  return _isLoading
      ? const Center(child: CircularProgressIndicator())
      : SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: isFormFilled() ? saveProfileDetails : null,
            style: ButtonStyle(
              backgroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(vertical: 16),
              ),
              shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            child: const Text(
              'Save Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF007C91),
              ),
            ),
          ),
        );
}

}
