import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPostService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getUserItemsStream() {
    final user = _auth.currentUser!;
    return FirebaseFirestore.instance
        .collection('lost&found_list')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  Future<void> deleteItem(String docId) async {
    await FirebaseFirestore.instance
        .collection('lost&found_list')
        .doc(docId)
        .delete();
  }
}
