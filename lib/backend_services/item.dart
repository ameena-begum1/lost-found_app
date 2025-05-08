import 'package:cloud_firestore/cloud_firestore.dart';

class ItemListview {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getItemsByStatus(String status) {
    return _firestore
        .collection('lost&found_list')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                'title': doc['title'],
                'image': doc['image'],
              };
            }).toList());
  }
}
