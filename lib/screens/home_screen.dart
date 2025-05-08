import 'package:flutter/material.dart';
import 'package:lost_n_found/widgets/item_listview.dart';
import 'package:lost_n_found/widgets/bottom_navbar.dart';
import 'package:lost_n_found/screens/drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

 final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();//for using drawer 

  bool isLostItems = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, 
      appBar: AppBar(
        title: const Text("Lost and Found"),
      ),
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLostItems = true;
                  });
                },
                child: const Text("Lost Items"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLostItems = false;
                  });
                },
                child: const Text("Found Items"),
              ),
            ],
          ),
           Expanded(
             child: ItemList(statusFilter: isLostItems? 'Lost': 'Found'),
                ),
                  ],
      ),
      bottomNavigationBar: navBar(context,_scaffoldKey),
      endDrawer:  const Drawer( 
        shape: BeveledRectangleBorder(),
        backgroundColor: Color.fromARGB(255, 43, 43, 43), child: DrawerScreen()), 
      );
  }
}