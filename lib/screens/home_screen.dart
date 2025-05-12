import 'package:flutter/material.dart';
import 'package:lost_n_found/widgets/item_listview.dart';
import 'package:lost_n_found/widgets/bottom_navbar.dart';
import 'package:lost_n_found/screens/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_n_found/backend_services/fetch_profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FetchUserProfile _fetchUserProfile = FetchUserProfile();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  String statusFilter = 'All'; //default All
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Bag',
    'Bottle',
    'Watch',
    'Goggles',
    'Mobile',
    'Keys',
    'Others',
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = _fetchUserProfile.getCurrentUser();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: StreamBuilder<DocumentSnapshot>(
          stream: _fetchUserProfile.getUserProfileStream(currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              return Text(
                'Hello👋 ${data['Name']}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            } else {
              return const Text(
                'Unknown',
                style: TextStyle(color: Colors.white, fontSize: 18),
              );
            }
          },
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child:
                currentUser == null
                    ? const CircleAvatar(
                      child: Icon(Icons.person, color: Colors.white),
                    )
                    : StreamBuilder<DocumentSnapshot>(
                      stream: _fetchUserProfile.getUserProfileStream(
                        currentUser.uid,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;

                          final imageUrl = data['ProfileImageUrl'] ?? '';

                          return CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage:
                                imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : null,
                            child:
                                imageUrl.isEmpty
                                    ? const Icon(
                                      Icons.person,
                                      color: Colors.black,
                                    )
                                    : null,
                          );
                        } else {
                          return const CircleAvatar(
                            child: Icon(Icons.person, color: Colors.white),
                          );
                        }
                      },
                    ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search item",
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 15.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                    ),
                    child: const Icon(Icons.notifications, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                ['All', 'Lost', 'Found'].map((status) {
                  final isSelected = statusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ElevatedButton(
                      onPressed: () => setState(() => statusFilter = status),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected ? Colors.teal : Colors.grey[300],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(status),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ItemList(
              statusFilter: statusFilter == 'All' ? null : statusFilter,
              categoryFilter:
                  selectedCategory == 'All' ? null : selectedCategory,
              searchQuery: searchQuery,
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  selectedColor: Colors.teal.shade300,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
      bottomNavigationBar: navBar(context, _scaffoldKey),
      drawer: const Drawer(
        shape: BeveledRectangleBorder(),
        backgroundColor: Color(0xFF007C91),
        child: DrawerScreen(),
      ),
    );
  }
}
