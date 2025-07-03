import 'package:flutter/material.dart';
import 'package:lost_n_found/items/screens/notifications.dart';
import 'package:lost_n_found/items/widgets/item_listview.dart';
import 'package:lost_n_found/items/widgets/bottom_navbar.dart';
import 'package:lost_n_found/items/screens/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_n_found/items/backend_services/fetch_profile.dart';
import 'package:google_fonts/google_fonts.dart';

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

  String statusFilter = 'All';
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
      backgroundColor: const Color.fromARGB(255, 254, 253, 250),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: StreamBuilder<DocumentSnapshot>(
          stream: _fetchUserProfile.getUserProfileStream(currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              return Text(
                'Hello👋 ${data['Name']}',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            } else {
              return Text(
                'Unknown',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
              );
            }
          },
        ),
       actions: [
  Padding(
    padding: const EdgeInsets.only(right: 12.0),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
      },
      child: const Icon(Icons.notifications_none, color: Colors.white),
    ),
  ),
],

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
                            backgroundColor: Colors.white,
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
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search item",
                hintStyle: GoogleFonts.poppins(),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 15.0,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFFFD54F), // Teal outline
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 176, 138, 13), // Darker Teal when focused
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
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
                            isSelected
                                ? const Color(0xFFFFD54F)
                                : Colors.grey[300],
                        foregroundColor:
                            isSelected ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
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
              useGrid: true,
            ),
          ),
          const SizedBox(height: 12),
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
                  label: Text(category, style: GoogleFonts.poppins()),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  selectedColor: const Color.fromARGB(255, 250, 214, 97),
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
      bottomNavigationBar: navBar(context, _scaffoldKey),
      drawer: const Drawer(
        shape: BeveledRectangleBorder(),
        backgroundColor: Color(0xFFFFD54F),
        child: DrawerScreen(),
      ),
    );
  }
}
