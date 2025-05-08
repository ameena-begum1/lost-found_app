import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File handling
import 'package:flutter/foundation.dart'
    show
        kIsWeb; //optional as i am using web to run so using this to open camera for web
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:core';

class UploadItemImage extends StatefulWidget {
  const UploadItemImage({super.key, required this.onUploadImage});

  final Function(String) onUploadImage;
  @override
  State<UploadItemImage> createState() {
    return _UploadImageState();
  }
}

class _UploadImageState extends State<UploadItemImage> {
  //1.using image_picker for picking image
  final ImagePicker img = ImagePicker();
  XFile? _image;
  //2.variable to store image
  String imageUrl = '';

  Future<void> _pickImage(ImageSource source) async {
    if (kIsWeb) {
      //for web, i can remove this later
      final webFile = await img.pickImage(source: source);
      setState(() {
        _image = webFile;
      });
      print('${webFile?.path}');
    } else {
      final file = await img.pickImage(source: source);
      setState(() {
        _image = file;
      });
      print('${file?.path}');
    }
  }

  // for optios gallery or camera
  void _showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery).then((value) {
                    _uploadImage();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera).then((value) {
                    _uploadImage();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //2.using firebase storage for uploading image
  Future<void> _uploadImage() async {
    if (_image == null) {
      print('no image selected.');
      return;
    }
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');

    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      print("Uploading image to Firebase...");

      if (kIsWeb) {
        final bytes = await _image!.readAsBytes();
        await referenceImageToUpload.putData(bytes);
      } else {
        //store the file
        await referenceImageToUpload.putFile(
          File(_image!.path),
        ); //putFile to insert
      }
      imageUrl = await referenceImageToUpload.getDownloadURL();
      print("Upload successful! Image URL: $imageUrl");
      widget.onUploadImage(imageUrl);
    } catch (error) {
      print('Error in uploading the file: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: _showPicker,
            child: Container(
              height: 200,
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey, width: 2),
                image:
                    _image != null
                        ? DecorationImage(
                          image:
                              kIsWeb
                                  ? NetworkImage(_image!.path)
                                  : FileImage(File(_image!.path))
                                      as ImageProvider,
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  _image == null
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Upload the image',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      )
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}
