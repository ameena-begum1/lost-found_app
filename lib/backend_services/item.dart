import 'package:cloud_firestore/cloud_firestore.dart';

class ItemListview {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<List<Map<String, dynamic>>> getItemsByStatusCategoryAndSearch(
    String? status,
    String? category,
    String? searchQuery,
  ) {
    CollectionReference itemsRef = _firestore.collection('lost&found_list');
    Query query = itemsRef;

    if (status != 'All') {
      query = query.where('status', isEqualTo: status);
    }

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      List<Map<String, dynamic>> items =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();

      //search filter locally
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        items =
            items.where((item) {
              final name = item['title']?.toString().toLowerCase() ?? '';
              return name.contains(lowerQuery);
            }).toList();
      }

      return items;
    });
  }
}
