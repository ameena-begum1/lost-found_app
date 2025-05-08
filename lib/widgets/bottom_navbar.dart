import 'package:flutter/material.dart';
import 'package:lost_n_found/screens/home_screen.dart';
import 'package:lost_n_found/screens/post_item.dart';
//function for bottom navigation bar

ValueNotifier<int> currentIndexNotifier = ValueNotifier<int>(0);

  BottomNavigationBar navBar(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey)  {
    int _currentIndex = currentIndexNotifier.value; // this is use for navigation bar 
    return  BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            currentIndexNotifier.value = index;
            // Handle navigation when tapping bottom nav items
            if(index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder:(context) => const HomeScreen()),
              );
            }
            else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostItem()),
              );
            } 
            else if (index == 2) {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const ProfilePage()),
              // );
               scaffoldKey.currentState?.openEndDrawer(); //to open drawer
            }
          },
          items: const [
             BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: 'Post Item',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        );
  }
  