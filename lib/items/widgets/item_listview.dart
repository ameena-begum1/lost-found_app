// import 'package:flutter/material.dart';
// import 'package:lost_n_found/items/screens/item_detail.dart';
// import 'package:lost_n_found/items/backend_services/item.dart';

// class ItemList extends StatefulWidget {
//   const ItemList({
//     super.key,
//     required this.categoryFilter,
//      this.statusFilter,
//     this.searchQuery, required bool useGrid,
//   });
//   final String? statusFilter;
//   final String? categoryFilter;
//   final String? searchQuery;

//   @override
//   State<ItemList> createState() => _ItemListState();
// }

// class _ItemListState extends State<ItemList> {
//   final ItemListview _firestoreService = ItemListview();

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<Map<String, dynamic>>>(
//       stream: _firestoreService.getItemsByStatusCategoryAndSearch(
//   widget.statusFilter == 'All' ? 'All' : widget.statusFilter,
//         widget.categoryFilter,
//         widget.searchQuery,
//       ),

//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Center(child: Text('Error fetching data: ${snapshot.error}'));
//         } else if (snapshot.hasData) {
//           final items = snapshot.data!;
//           if (items.isEmpty) {
//             print('Status Filter: ${widget.statusFilter}');
//             print('Category Filter: ${widget.categoryFilter}');

//             return const Center(child: Text('No items found.'));
//           }

//           return ListView.builder(
//             itemCount: items.length,
//             itemBuilder: (context, index) {
//               final item = items[index];
//               return Card(
//                 child: ListTile(
//                   title: Text(item['title']),
//                   leading: SizedBox(
//                     width: 40,
//                     height: 40,
//                     child:
//                         item['image'] != null && item['image'] != ''
//                             ? Image.network(item['image'], fit: BoxFit.cover)
//                             : const Icon(Icons.image_not_supported),
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ItemDetailScreen(item['id']),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         } else {
//           return const Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
// }

//UI set============================================================================================================================
import 'package:flutter/material.dart';
import 'package:lost_n_found/items/screens/item_detail.dart';
import 'package:lost_n_found/items/backend_services/item.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemList extends StatefulWidget {
  const ItemList({
    super.key,
    required this.categoryFilter,
    this.statusFilter,
    this.searchQuery,
    required bool useGrid,
  });

  final String? statusFilter;
  final String? categoryFilter;
  final String? searchQuery;

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final ItemListview _firestoreService = ItemListview();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getItemsByStatusCategoryAndSearch(
        widget.statusFilter == 'All' ? 'All' : widget.statusFilter,
        widget.categoryFilter,
        widget.searchQuery,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error fetching data: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final items = snapshot.data!;

          // if (items.isEmpty) {
          //   return const Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(
          //           Icons
          //               .sentiment_dissatisfied_rounded, // Cute sad face emoji style
          //           size: 80,
          //           color: Color(0xFF00BFA5), // Matches your theme
          //         ),
          //         SizedBox(height: 16),
          //         Text(
          //           'No items found.',
          //           style: TextStyle(
          //             fontSize: 16,
          //             color: Colors.grey,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ],
          //     ),
          //   );
          // }
          if (items.isEmpty) {
 return Center(
  child: TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 900),
    curve: Curves.elasticOut,
    builder: (context, value, child) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: value,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, 10),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.sentiment_dissatisfied_rounded,
                size: 60,
                color: Color(0xFFFFD54F),
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.yellow.withOpacity(0.4),
                    // offset: Offset(2, 3),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No items found.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    },
  ),
);

}


          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailScreen(item['id']),
                      ),
                    );
                  },
                  title: Text(
                    item['title'],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    item['status'],
                    style: GoogleFonts.poppins(
                      color:
                          item['status'] == 'Lost' ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child:
                          item['image'] != null &&
                                  item['image'].toString().isNotEmpty
                              ? Image.network(item['image'], fit: BoxFit.cover)
                              : Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              ),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                ),
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
