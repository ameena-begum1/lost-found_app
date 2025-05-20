import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../models/location_data.dart';

class TypeAheadFieldWidget extends StatelessWidget {
  final String label;
  final List<LocationData> locations;
  final Function(LocationData) onSelected;

  TypeAheadFieldWidget({
    required this.label,
    required this.locations,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<LocationData>(
      suggestionsCallback: (pattern) async {
        if (pattern.isEmpty) return [];
        return locations
            .where((loc) => loc.name.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          title: Text(suggestion.name, style: TextStyle(fontSize: 14)),
        );
      },
      onSelected: onSelected,
      emptyBuilder: (context) => SizedBox.shrink(),
      builder: (context, controller, focusNode) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, size: 18),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
              labelText: label,
              labelStyle: TextStyle(fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      },
    );
  }
}
