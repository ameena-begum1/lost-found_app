import 'package:flutter/material.dart';
import 'package:lost_n_found/screens/maps.dart';
import 'package:lost_n_found/screens/home_screen.dart';
import 'package:lost_n_found/screens/post_item.dart';

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
          MaterialPageRoute(builder: (context) =>  CollegeMapScreen()),
        );
      }
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Post Item'),
      BottomNavigationBarItem(icon: Icon(Icons.location_pin), label: 'Maps'),
    ],
  );
}
