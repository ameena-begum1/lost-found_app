// import 'package:flutter/material.dart';
// import 'dart:typed_data';
// import 'package:image_picker/image_picker.dart';
// import 'package:lost_n_found/items/backend_services/store_user_profile.dart';
// import 'dart:core';
// class EditProfile extends StatefulWidget {
//   const EditProfile({super.key});
//   @override
//   State<EditProfile> createState() {
//     return _EditProfileState();
//   }
// }

// class _EditProfileState extends State<EditProfile> {
//   TextEditingController nameController = TextEditingController();
//   TextEditingController rollnoController = TextEditingController();
//   TextEditingController branchController = TextEditingController();

//   List<String> year = ['Year', '1', '2', '3', '4'];
//   String? selectedYear = 'Year';

// Widget selectYear() {
//   return DropdownMenu<String>(
//     initialSelection: selectedYear,
//     onSelected: (String? value) {
//       setState(() {
//         selectedYear = value ?? 'Year';
//       });
//     },
//     dropdownMenuEntries: year.map<DropdownMenuEntry<String>>((String value) {
//       return DropdownMenuEntry(value: value, label: value);
//     }).toList(),
//   );
// }


// // to selcet image as profile pic
// pictImage(ImageSource source) async{
//   final ImagePicker imagePicker = ImagePicker();
// XFile? file = await imagePicker.pickImage(source: source);
//   if(file != null) {
//     return await file.readAsBytes();
//   }
//   print('No images selected');
// }
//   Uint8List? _image;
//   void selectImage() async {
//     Uint8List img = await pictImage(ImageSource.gallery);
//     setState(() {
//       _image = img;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Profile'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: ListView(
//           children: <Widget>[
//             Center(
//               child: Stack(
//                 children: [
//                   _image != null
//                       ? CircleAvatar(
//                           radius: 64,
//                           backgroundImage: MemoryImage(_image!),
//                         )
//                       : const CircleAvatar(
//                           radius: 64,
//                           child: Icon(Icons.person, size: 70),
//                           backgroundColor: Color.fromARGB(212, 197, 191, 191),                       
//                         ),
//                   Positioned(
//                     bottom: -10,
//                     left: 80,
//                     child: IconButton(
//                       onPressed: selectImage,
//                       icon: const Icon(Icons.add_a_photo),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 labelText: "User Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: rollnoController,
//               decoration: const InputDecoration(
//                 labelText: "roll no.",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: branchController,
//                     decoration: const InputDecoration(
//                       labelText: "Branch",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   width: 20,
//                 ),
//                 selectYear(),
//               ],
//             ),
//             const SizedBox(height: 30),
//             StoreProfile(
//                 nameController: nameController.text,
//                 rollnoController: rollnoController.text,
//                 branchController: branchController.text,
//                 year: selectedYear!,
//                 image: _image ?? Uint8List(0), )
//           ],
//         ),
//       ),
//     );
//   }
// }


//UI set Rabia ================================================================================================
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:lost_n_found/items/backend_services/store_user_profile.dart';
import 'package:lost_n_found/items/widgets/gradient_container.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});
  @override
  State<EditProfile> createState() {
    return _EditProfileState();
  }
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController rollnoController = TextEditingController();
  

  List<String> year = ['Year', '1', '2', '3', '4'];
  String? selectedYear = 'Year';
  final List<String> branches = [
    'Branch','CSE', 'ECE', 'IT', 'EEE', 'MECH', 'CIVIL', 'AI-DS', 'AI-ML', 'CSE-AI', 'CSE-DS'
  ];
  String? selectedBranch='Branch';

// to selcet image as profile pic
pictImage(ImageSource source) async{
  final ImagePicker imagePicker = ImagePicker();
XFile? file = await imagePicker.pickImage(source: source);
  if(file != null) {
    return await file.readAsBytes();
  }
  print('No images selected');
}
  Uint8List? _image;
  void selectImage() async {
    Uint8List img = await pictImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('User Profile'),
      // ),

      body:
       GradientContainer(
        colors: const [
         Color(0xFF00BFA6),
          Color.fromARGB(255, 6, 144, 125)
        ],
         child: SafeArea(
           child: SingleChildScrollView(
             child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
               child: IntrinsicHeight(
                 child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 70),
                      const Center(
                        child: Text(
                          'User Profile',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 27),
                      Center(
                        child: Stack(
                          children: [
                            _image != null
                                ? CircleAvatar(
                                    radius: 64,
                                    backgroundImage: MemoryImage(_image!),
                                  )
                                : const CircleAvatar(
                                    radius: 64,
                                    child: Icon(Icons.person, size: 70,color: Color(0xFF00BFA6),),
                                    backgroundColor: Color.fromARGB(210, 255, 255, 255),                       
                                  ),
                            Positioned(
                              bottom: -10,
                              left: 80,
                              child: IconButton(
                                onPressed: selectImage,
                                icon: const Icon(Icons.add_a_photo),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "User Name",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:   const BorderSide(width:0,style: BorderStyle.none)
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: rollnoController,
                        decoration: InputDecoration(
                          labelText: "Roll Number",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:   const BorderSide(width:0,style: BorderStyle.none)

                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownMenu<String>(
                                        width: 173.5,
                                        menuHeight: 300,
                                        inputDecorationTheme: InputDecorationTheme(filled: true,fillColor: Colors.white,
                                        border: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                        borderSide: const BorderSide(width:0,style: BorderStyle.none),)),
                                        initialSelection: selectedBranch,
                                        menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                                        ),
                                        onSelected: (String? value) {
                                         setState(() {
                                           selectedBranch = value ?? 'Branch';
                                        });
                                      },
                                      dropdownMenuEntries: branches.map<DropdownMenuEntry<String>>((String value) {
                                      return DropdownMenuEntry(value: value, label: value);
                                 
                                  }
                                    ).toList(),
                                      
                                  ),
                                  
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                           DropdownMenu<String>(
                                        width: 173.5,
                                        inputDecorationTheme: InputDecorationTheme(filled: true,fillColor: Colors.white,
                                        border: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                        borderSide: const BorderSide(width:0,style: BorderStyle.none),)),
                                        initialSelection: selectedYear,
                                        menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                                        ),
                                        onSelected: (String? value) {
                                         setState(() {
                                           selectedYear = value ?? 'Year';
                                        });
                                      },
                                      dropdownMenuEntries: year.map<DropdownMenuEntry<String>>((String value) {
                                      return DropdownMenuEntry(value: value, label: value);
                                  }                        ).toList(),
                                      
                                  )
                        ],
                      ),
                      const SizedBox(height: 30),
                      StoreProfile(
                          nameController: nameController.text,
                          rollnoController: rollnoController.text,
                          branch: selectedBranch!,
                          year: selectedYear!,
                          image: _image ?? Uint8List(0), branchController: '', )
                    ],
                  ),
                       ),
               ),
             ),
           ),
         ),
       ),
    );
  }
}