import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailScreen extends StatelessWidget {
  ItemDetailScreen(this.itemId, {super.key}) {
    _reference = FirebaseFirestore.instance.collection('lost&found_list').doc(itemId);
    _futureData = _reference.get();
  }

  final String itemId;
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;

  Future<void> _openWhatsAppChat(String mobileNumber, String title, String status) async {
    String formattedNumber = mobileNumber.trim();
    if (!formattedNumber.startsWith("91")) {
      formattedNumber = "91$formattedNumber";
    }
    String message = status == 'Lost'
        ? Uri.encodeComponent("Hi! I saw your post about the lost item '$title' on Lost&Found🔍 app. I think I found it!")
        : Uri.encodeComponent("Hey! I saw your post about the found item '$title' on Lost&Found🔍 app. I think it's mine!");

    final Uri url = Uri.parse('https://wa.me/$formattedNumber?text=$message');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F9F6),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF00897B),
        title: Text("Item Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _futureData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data: ${snapshot.error}', style: GoogleFonts.poppins()));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            String userId = data['userId'] ?? '';
            DocumentReference userReference = FirebaseFirestore.instance.collection('user_profile').doc(userId);
            Future<DocumentSnapshot> userFuture = userReference.get();

            return FutureBuilder<DocumentSnapshot>(
              future: userFuture,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}', style: GoogleFonts.poppins()));
                }
                if (userSnapshot.hasData) {
                  Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  String formatted = DateFormat('dd MMM yyyy, hh:mm a').format((data['timestamp'] as Timestamp).toDate());

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: data['image'] != null && data['image'].toString().isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    data['image'],
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Container(
                                  width: double.infinity,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.broken_image, size: 100, color: Colors.black54),
                                ),
                        ),
                        const SizedBox(height: 24),
                        Text(data['title'], style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Posted on: $formatted', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.label_important, color: Colors.amber),
                            const SizedBox(width: 6),
                            Text(
                              "Status: ${data['status']}",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: data['status'] == 'Lost' ? Colors.red : Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Text(data['discription'], style: GoogleFonts.poppins(fontSize: 16)),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.redAccent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Location', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text(data['location'], style: GoogleFonts.poppins(fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 40),
                        Text('Posted by', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundImage: userData['ProfileImageUrl'] != null
                                ? NetworkImage(userData['ProfileImageUrl'])
                                : null,
                            child: userData['ProfileImageUrl'] == null ? const Icon(Icons.person) : null,
                          ),
                          title: Text(userData['Name'] ?? 'Unknown', style: GoogleFonts.poppins()),
                        ),
                        const Divider(height: 40),
                        Text(
                          data['status'] == 'Lost' ? 'Is this your lost item?' : 'Did you lose this item?',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final mobile = data['mobile_no'];
                              final title = data['title'];
                              final status = data['status'];
                              if (mobile != null && title != null) {
                                _openWhatsAppChat(mobile, title, status);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Something went wrong')),
                                );
                              }
                            },
                            icon: const Icon(Icons.message,color: Colors.white,),
                            label: const Text('Contact'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00897B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
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
