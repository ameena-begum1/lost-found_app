//my posted items screen

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lost_n_found/screens/post_item.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});
  @override
  State<UserList> createState() {
    return _UserListState();
  }
}

class _UserListState extends State<UserList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: Text('My posted items'),
      ),
      body: Center(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('lost&found_list')
                .where('userId', isEqualTo: user.uid)
                .snapshots(), // holds the real-tiem uapdated data
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              //error if any
              if (snapshot.hasError) {
                return Center(
                  child: Text('error in fetching the data ${snapshot.error}'),
                );
              }
              //if data is present
              else if (snapshot.hasData) {
                QuerySnapshot querySnapshot = snapshot.data;
                List<QueryDocumentSnapshot> documents = querySnapshot.docs;

                //if user didn't posted any thing yet
                if (documents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "You haven't posted any items yet.\n  Start by posting your first item!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PostItem()),
                              );
                            },
                            icon: Icon(Icons.add),
                            color: Colors.grey)
                      ],
                    ),
                  );
                }

                //converting the documents to Map
                List<Map> items = documents
                    .map((e) => {
                          //converting to list
                          'id': e.id,
                          'title': e['title'],
                          'status': e['status'],
                          'discription': e['discription'],
                          'image': e['image']
                        })
                    .toList();
                //displaying the list
                return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      //get items at this index
                      Map thisItem = items[index];

                      //widget
                      return Card(
                          child: ListTile(
                        title: Text('${thisItem['title']}'),
                        subtitle: Text('${thisItem['status']}'),
                        leading: Container(
                          width: 40,
                          height: 40,
                          child: thisItem.containsKey('image')
                              ? Image.network('${thisItem['image']}')
                              : Container(),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PostItem(),
                                ),
                              );
                            } else if (value == 'delete') {
                              // deleting the item from firebase
                              await FirebaseFirestore.instance
                                  .collection('lost&found_list')
                                  .doc(thisItem['id'])
                                  .delete();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ));
                    });
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}
