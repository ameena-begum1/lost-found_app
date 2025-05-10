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
  final FetchUserProfile _profile = FetchUserProfile();

  @override
  Widget build(BuildContext context) {
    final User user = _profile.getCurrentUser()!;

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFF007C91),
          padding: const EdgeInsets.only(
            top: 50,
            left: 20,
            bottom: 60,
            right: 16,
          ),
          child: StreamBuilder<DocumentSnapshot>(
            stream: _profile.getUserProfileStream(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              var profileData = snapshot.data?.data() as Map<String, dynamic>?;
              bool hasProfileData =
                  profileData != null && profileData.isNotEmpty;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfile()),
                      );
                    },
                    child: FutureBuilder(
                      future: precacheImage(
                        NetworkImage(profileData?['ProfileImageUrl'] ?? ''),
                        context,
                        onError: (_, __) {},
                      ),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.done &&
                            profileData?['ProfileImageUrl']?.isNotEmpty ==
                                true) {
                          return CircleAvatar(
                            radius: 52,
                            backgroundImage: NetworkImage(
                              profileData!['ProfileImageUrl'],
                            ),
                          );
                        } else if (snap.connectionState ==
                            ConnectionState.waiting) {
                          return const CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.grey,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          );
                        } else {
                          return const CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              size: 32,
                              color: Colors.white,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasProfileData ? profileData!['Name'] : 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasProfileData
                            ? "${profileData!['Branch']} | ${profileData['Year']} | ${profileData['Roll no.']}"
                            : 'Not Available',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                ListTile(
                  leading: const Icon(Icons.list_alt_outlined),
                  title: const Text('My Posted Items'),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UserList()),
                      ),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_none),
                  title: const Text('Notifications'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.group_add_outlined),
                  title: const Text('Invite Friends'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About Developers'),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    await _profile.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => SigninScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
