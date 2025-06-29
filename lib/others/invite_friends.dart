import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  void _shareInviteLink(BuildContext context) {
    const String inviteMessage = '''
Hey! 👋

Say hello to FindOra — your smart campus buddy!

🔎 Report and recover lost items instantly with AI matching
🗺️ Navigate your campus with ease
🅿️ Hassle-free parking management

Find. Reclaim. Navigate.
📲 Download FindOra now! 💛
🔗 https://drive.google.com/file/d/1GpuDAoWyt63LoI79FAxYUlwcWLIrge44/view?usp=drive_link
''';

    Share.share(inviteMessage);
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        title: Text(
          "Invite Friends",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.share, color: Color(0xFF00BFA5), size: 48),
              const SizedBox(height: 16),
              Text(
                'Share FindOra with your friends!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF00897B),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _shareInviteLink(context),
                icon: const Icon(Icons.send,color: Colors.white,),
                label: Text(
                  "Invite Now",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
