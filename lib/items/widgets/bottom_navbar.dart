import 'package:flutter/material.dart';
import 'package:lost_n_found/items/screens/parking_screen.dart';
import 'package:lost_n_found/maps/screen/map_screen.dart';
import 'package:lost_n_found/items/screens/home_screen.dart';
import 'package:lost_n_found/items/screens/post_item.dart';

ValueNotifier<int> currentIndexNotifier = ValueNotifier<int>(0);

BottomNavigationBar navBar(
  BuildContext context,
  GlobalKey<ScaffoldState> scaffoldKey,
) {
  int currentIndex = currentIndexNotifier.value;
  return BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: (index) {
      currentIndexNotifier.value = index;
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PostItem()),
        );
      } else if (index == 2) {
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  MapScreen()),
        );
      } else if (index == 3) {
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  ParkingScreen()),
        );
      }
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home',backgroundColor: Colors.teal),
      BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Post Item',backgroundColor: Colors.teal),
      BottomNavigationBarItem(icon: Icon(Icons.location_pin), label: 'Maps',backgroundColor: Colors.teal),
      BottomNavigationBarItem(icon: Icon(Icons.local_parking_sharp), label: 'Parking',backgroundColor: Colors.teal),
    ],
  );
}