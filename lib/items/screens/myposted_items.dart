// //my posted items screen
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lost_n_found/items/backend_services/mypost.dart';
// import 'package:lost_n_found/items/screens/post_item.dart';

// class UserList extends StatefulWidget {
//   const UserList({super.key});

//   @override
//   State<UserList> createState() => _UserListState();
// }

// class _UserListState extends State<UserList> {
//   final MyPostService _userItemsService = MyPostService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('My posted items')),
//       body: Center(
//         child: StreamBuilder(
//           stream: _userItemsService.getUserItemsStream(),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             if (snapshot.hasError) {
//               return Center(
//                 child: Text('Error in fetching the data: ${snapshot.error}'),
//               );
//             } else if (snapshot.hasData) {
//               QuerySnapshot querySnapshot = snapshot.data;
//               List<QueryDocumentSnapshot> documents = querySnapshot.docs;

//               if (documents.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         "You haven't posted any items yet.\nStart by posting your first item!",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       IconButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const PostItem(),
//                             ),
//                           );
//                         },
//                         icon: const Icon(Icons.add),
//                         color: Colors.grey,
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               List<Map<String, dynamic>> items =
//                   documents.map((doc) {
//                     return {
//                       'id': doc.id,
//                       'title': doc['title'],
//                       'status': doc['status'],
//                       'image': doc['image'],
//                       'discription': doc['discription'],
//                       'mobile_no': doc['mobile_no'],
//                       'location': doc['location'],
//                       'category': doc['category'],
//                     };
//                   }).toList();

//               return ListView.builder(
//                 itemCount: items.length,
//                 itemBuilder: (context, index) {
//                   final item = items[index];

//                   return Card(
//                     child: ListTile(
//                       title: Text(item['title']),
//                       subtitle: Text(item['status']),
//                       leading: SizedBox(
//                         width: 40,
//                         height: 40,
//                         child:
//                             item['image'] != null
//                                 ? Image.network(item['image'])
//                                 : const SizedBox(),
//                       ),
//                       trailing: PopupMenuButton<String>(
//                         onSelected: (value) async {
//                           if (value == 'edit') {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder:
//                                     (context) => PostItem(existingItem: item),
//                               ),
//                             );
//                           } else if (value == 'delete') {
//                             await _userItemsService.deleteItem(item['id']);
//                           }
//                         },
//                         itemBuilder:
//                             (context) => const [
//                               PopupMenuItem(value: 'edit', child: Text('Edit')),
//                               PopupMenuItem(
//                                 value: 'delete',
//                                 child: Text('Delete'),
//                               ),
//                             ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             } else {
//               return const Center(child: CircularProgressIndicator());
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

//UI set ================================================================================================================
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lost_n_found/items/backend_services/mypost.dart';
import 'package:lost_n_found/items/screens/post_item.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final MyPostService _userItemsService = MyPostService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Posted Items')),
      body: Center(
        child: StreamBuilder(
          stream: _userItemsService.getUserItemsStream(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error in fetching the data: ${snapshot.error}',
                  style: GoogleFonts.poppins(color: Colors.grey[800]),
                ),
              );
            } else if (snapshot.hasData) {
              QuerySnapshot querySnapshot = snapshot.data;
              List<QueryDocumentSnapshot> documents = querySnapshot.docs;

              if (documents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        color: Colors.grey,
                        size: 70,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "You haven't posted any items yet.\nStart by posting your first item!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PostItem(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Post Item"),
                        style: ElevatedButton.styleFrom(
                          textStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              List<Map<String, dynamic>> items =
                  documents.map((doc) {
                    return {
                      'id': doc.id,
                      'title': doc['title'],
                      'status': doc['status'],
                      'image': doc['image'],
                      'discription': doc['discription'],
                      'mobile_no': doc['mobile_no'],
                      'location': doc['location'],
                      'category': doc['category'],
                    };
                  }).toList();

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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      title: Text(
                        item['title'],
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        item['status'],
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFFB300),
                        ), // yellow text
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child:
                              item['image'] != null &&
                                      item['image'].toString().isNotEmpty
                                  ? Image.network(
                                    item['image'],
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    ),
                                  ),
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => PostItem(existingItem: item),
                              ),
                            );
                          } else if (value == 'delete') {
                            await _userItemsService.deleteItem(item['id']);
                          }
                        },
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        itemBuilder:
                            (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
