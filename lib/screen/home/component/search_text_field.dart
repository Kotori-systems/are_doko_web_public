import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    required this.searchController,
    required this.onChanged,
  });

  final TextEditingController searchController;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: const InputDecoration(
        labelText: 'Search',
        suffixIcon: Icon(Icons.search),
      ),
      onChanged: onChanged,
    );
  }
}
