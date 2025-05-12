//my posted items screen
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_n_found/backend_services/mypost.dart';
import 'package:lost_n_found/screens/post_item.dart';

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
      appBar: AppBar(title: const Text('My posted items')),
      body: Center(
        child: StreamBuilder(
          stream: _userItemsService.getUserItemsStream(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error in fetching the data: ${snapshot.error}'),
              );
            } else if (snapshot.hasData) {
              QuerySnapshot querySnapshot = snapshot.data;
              List<QueryDocumentSnapshot> documents = querySnapshot.docs;

              if (documents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "You haven't posted any items yet.\nStart by posting your first item!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 15),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PostItem(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        color: Colors.grey,
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
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Card(
                    child: ListTile(
                      title: Text(item['title']),
                      subtitle: Text(item['status']),
                      leading: SizedBox(
                        width: 40,
                        height: 40,
                        child:
                            item['image'] != null
                                ? Image.network(item['image'])
                                : const SizedBox(),
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
