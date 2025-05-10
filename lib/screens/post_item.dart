//post item screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lost_n_found/backend_services/upload_item_image.dart';
import 'package:lost_n_found/backend_services/store_item_details.dart';

class PostItem extends StatefulWidget {
  const PostItem({super.key});

  @override
  State<PostItem> createState() {
    return _PostItemState();
  }
}

class _PostItemState extends State<PostItem> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _discriptionController = TextEditingController();
  final TextEditingController _mobilenoController = TextEditingController();
  final TextEditingController _location = TextEditingController();
  String imageUrl = '';

  void updateImageUrl(String url) {
    setState(() {
      imageUrl = url;
    });
  }

  final List<String> list = ['Status', 'Lost', 'Found'];
  String? selectedStatus = 'Status';
  final List<String> categoryList = [
    'Select Category',
    'Bag',
    'Bottle',
    'Watch',
    'Goggles',
    'Mobile',
    'Keys',
    'Others',
  ];
  String? selectedCategory = 'Select Category';

  Widget statusMenu() {
    return DropdownMenu<String>(
      initialSelection: list.first,
      onSelected: (String? value) {
        setState(() {
          selectedStatus = value ?? 'status';
        });
      },
      dropdownMenuEntries:
          list.map<DropdownMenuEntry<String>>((String value) {
            return DropdownMenuEntry(value: value, label: value);
          }).toList(),
    );
  }

  Widget categoryMenu() {
    return DropdownMenu<String>(
      initialSelection: categoryList.first,
      onSelected: (String? value) {
        setState(() {
          selectedCategory = value ?? 'Select Category';
        });
      },
      dropdownMenuEntries:
          categoryList.map<DropdownMenuEntry<String>>((String value) {
            return DropdownMenuEntry(value: value, label: value);
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Item")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UploadItemImage(onUploadImage: updateImageUrl),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Item Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 3, // 1.5 * 2 #chamka
                    child: categoryMenu(),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2, // 1 * 2
                    child: statusMenu(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _discriptionController,
                decoration: const InputDecoration(
                  labelText: "Item Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _location,
                decoration: const InputDecoration(
                  labelText: "Location",
                  hintText: "eg: near non-veg canteen",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _mobilenoController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "Mobile No. to Contact",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: StoreData(
                  titleController: _titleController,
                  status: selectedStatus!,
                  category: selectedCategory!,
                  discriptionController: _discriptionController,
                  imageUrl: imageUrl,
                  mobilenoController: _mobilenoController,
                  location: _location,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
