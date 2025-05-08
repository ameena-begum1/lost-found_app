import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_n_found/backend_services/fetch_profile.dart';
import 'edit_profile.dart';
import 'signin_screen.dart';
import 'myposted_items.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});
  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  final FetchUserProfile _profile= FetchUserProfile();

  @override
  Widget build(BuildContext context) {
    final User user = _profile.getCurrentUser()!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<DocumentSnapshot>(
        stream: _profile.getUserProfileStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var profileData = snapshot.data?.data() as Map<String, dynamic>?;
          bool hasProfileData = profileData != null && profileData.isNotEmpty;

          return Column(
            children: <Widget>[
              const SizedBox(height: 80),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfile()));
                  },
                  child: FutureBuilder(
                    future: precacheImage(
                      NetworkImage(profileData?['ProfileImageUrl'] ?? ''),
                      context,
                      onError: (error, stackTrace) {},
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          profileData != null &&
                          profileData['ProfileImageUrl'] != null &&
                          profileData['ProfileImageUrl'].toString().isNotEmpty) {
                        return CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(profileData['ProfileImageUrl']),
                        );
                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar(
                          radius: 64,
                          child: CircularProgressIndicator(color: Colors.white),
                          backgroundColor: Colors.grey,
                        );
                      } else {
                        return const CircleAvatar(
                          radius: 64,
                          child: Icon(Icons.person, size: 64),
                          backgroundColor: Colors.grey,
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                hasProfileData ? profileData['Name'] : 'Unknown',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                hasProfileData
                    ? "${profileData['Branch']} | ${profileData['Year']} | ${profileData['Roll no.']}"
                    : 'Not Available',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 50),
              ListTile(
                title: const Text('My Posted Items'),
                textColor: Colors.white,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const UserList()));
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('About Developers'),
                textColor: Colors.white,
                onTap: () {},
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () async {
                  await _profile.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SigninScreen()));
                },
                child: const Text('Logout'),
              ),
            ],
          );
        },
      ),
    );
  }
}
