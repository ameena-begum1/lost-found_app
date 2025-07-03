import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lost_n_found/items/backend_services/fetch_profile.dart';
import 'package:lost_n_found/items/screens/notifications.dart';
import 'package:lost_n_found/others/invite_friends.dart';
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD54F), Color(0xFFFFD54F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.only(
            top: 60,
            left: 20,
            bottom: 50,
            right: 20,
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
                            radius: 50,
                            backgroundImage: NetworkImage(
                              profileData!['ProfileImageUrl'],
                            ),
                          );
                        } else if (snap.connectionState ==
                            ConnectionState.waiting) {
                          return const CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          );
                        } else {
                          return const CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white24,
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
                  Text(
                    hasProfileData ? profileData['Name'] : 'Unknown',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasProfileData ? profileData['Institution'] : 'Unknown',
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasProfileData
                        ? "${profileData['Branch']} | ${profileData['Year']} | ${profileData['Roll no.']}"
                        : 'Not Available',
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFFF1F9F6),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildListTile(
                  icon: Icons.list_alt_outlined,
                  label: 'My Posted Items',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UserList()),
                      ),
                ),
                _buildListTile(
                  icon: Icons.notifications_none,
                  label: 'Notifications',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsScreen(),
                      ),
                    );
                  },
                ),
                _buildListTile(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {},
                ),
                _buildListTile(
                  icon: Icons.group_add_outlined,
                  label: 'Invite Friends',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InviteFriendsScreen(),
                      ),
                    );
                  },
                ),
                _buildListTile(
                  icon: Icons.info_outline,
                  label: 'About Developers',
                  onTap: () {},
                ),
                const Divider(height: 24, thickness: 1.2),
                _buildListTile(
                  icon: Icons.logout,
                  label: 'Logout',
                  iconColor: Colors.redAccent,
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

  Widget _buildListTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: Colors.white,
        leading: Icon(icon, color: iconColor ?? const Color(0xFFFFD54F)),
        title: Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        onTap: onTap,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
