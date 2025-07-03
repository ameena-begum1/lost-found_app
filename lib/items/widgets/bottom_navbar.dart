// import 'package:flutter/material.dart';
// import 'package:lost_n_found/maps/screen/map_screen.dart';
// import 'package:lost_n_found/items/screens/home_screen.dart';
// import 'package:lost_n_found/items/screens/post_item.dart';

// ValueNotifier<int> currentIndexNotifier = ValueNotifier<int>(0);

// BottomNavigationBar navBar(
//   BuildContext context,
//   GlobalKey<ScaffoldState> scaffoldKey,
// ) {
//   int currentIndex = currentIndexNotifier.value;
//   return BottomNavigationBar(
//     currentIndex: currentIndex,
//     onTap: (index) {
//       currentIndexNotifier.value = index;
//       if (index == 0) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const HomeScreen()),
//         );
//       } else if (index == 1) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const PostItem()),
//         );
//       } else if (index == 2) {
//           Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) =>  MapScreen()),
//         );
//       }
//     },
//     items: const [
//       BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//       BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Post Item'),
//       BottomNavigationBarItem(icon: Icon(Icons.location_pin), label: 'Maps'),
//     ],
//   );
// }


//UI set ====================================================================================
import 'package:flutter/material.dart';
import 'package:lost_n_found/maps/screen/map_screen.dart';
import 'package:lost_n_found/items/screens/home_screen.dart';
import 'package:lost_n_found/items/screens/post_item.dart';
import 'package:lost_n_found/parking/screens/parking_area.dart';

ValueNotifier<int> currentIndexNotifier = ValueNotifier<int>(0);

BottomNavigationBar navBar(
  BuildContext context,
  GlobalKey<ScaffoldState> scaffoldKey,
) {
  int currentIndex = currentIndexNotifier.value;

  return BottomNavigationBar(
    currentIndex: currentIndex,
    backgroundColor: Colors.white,
    selectedItemColor: const Color(0xFFFFD54F),
    unselectedItemColor: Colors.grey,
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
    type: BottomNavigationBarType.fixed,
    elevation: 10,
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
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
      }
      else {
         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ParkingScreen()),
        );
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
        icon: Icon(Icons.location_pin),
        label: 'Maps',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.local_parking),label: 'Parking')
    ],
  );
}
