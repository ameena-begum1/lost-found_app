import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:lost_n_found/backend_services/store_user_profile.dart';
import 'dart:core';
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
  TextEditingController branchController = TextEditingController();

  List<String> year = ['Year', '1', '2', '3', '4'];
  String? selectedYear = 'Year';

Widget selectYear() {
  return DropdownMenu<String>(
    initialSelection: selectedYear,
    onSelected: (String? value) {
      setState(() {
        selectedYear = value ?? 'Year';
      });
    },
    dropdownMenuEntries: year.map<DropdownMenuEntry<String>>((String value) {
      return DropdownMenuEntry(value: value, label: value);
    }).toList(),
  );
}


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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
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
                          child: Icon(Icons.person, size: 70),
                          backgroundColor: Color.fromARGB(212, 197, 191, 191),                       
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
              decoration: const InputDecoration(
                labelText: "User Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: rollnoController,
              decoration: const InputDecoration(
                labelText: "roll no.",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: branchController,
                    decoration: const InputDecoration(
                      labelText: "Branch",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                selectYear(),
              ],
            ),
            const SizedBox(height: 30),
            StoreProfile(
                nameController: nameController.text,
                rollnoController: rollnoController.text,
                branchController: branchController.text,
                year: selectedYear!,
                image: _image ?? Uint8List(0), )
          ],
        ),
      ),
    );
  }
}