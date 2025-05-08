import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FetchUserProfile {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<DocumentSnapshot> getUserProfileStream(String uid) {
    return _firestore.collection('user_profile').doc(uid).snapshots();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
