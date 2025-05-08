import 'package:flutter/material.dart';
import 'package:lost_n_found/screens/item_details.dart';
import 'package:lost_n_found/backend_services/item.dart';

class ItemList extends StatefulWidget {
  const ItemList({super.key, required this.statusFilter});
  final String statusFilter;

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final ItemListview _firestoreService = ItemListview();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getItemsByStatus(widget.statusFilter),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error fetching data: ${snapshot.error}'),
          );
        } else if (snapshot.hasData) {
          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  title: Text(item['title']),
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: item['image'] != null && item['image'] != ''
                        ? Image.network(item['image'], fit: BoxFit.cover)
                        : const Icon(Icons.image_not_supported),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ItemDetailScreen(item['id']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
