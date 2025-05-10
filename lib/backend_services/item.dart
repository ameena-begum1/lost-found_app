import 'package:cloud_firestore/cloud_firestore.dart';

// class ItemListview {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Stream<List<Map<String, dynamic>>> getItemsByStatus(String status) {
//     return _firestore
//         .collection('lost&found_list')
//         .where('status', isEqualTo: status)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.map((doc) {
//               return {
//                 'id': doc.id,
//                 'title': doc['title'],
//                 'image': doc['image'],
//               };
//             }).toList());
//   }
// }

class ItemListview {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getItemsByStatusAndCategory(
      String status, String? category) {
    CollectionReference itemsRef = _firestore.collection('lost&found_list');

    Query query = itemsRef.where('status', isEqualTo: status);

if (category != null && category != 'All') {
  print('Firestore query for category: $category');

  query = query.where('category', isEqualTo: category);
}

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; 
        return data;
      }).toList();
    });
  }
}

