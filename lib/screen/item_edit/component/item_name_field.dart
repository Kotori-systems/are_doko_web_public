import 'package:flutter/material.dart';

// TODO(tanaka): #23 ItemNameField,ItemCategoryField,LocationCategoryField の共通化？
class ItemNameField extends StatelessWidget {
  const ItemNameField({
    super.key,
    required this.controller,
  });

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration:
          const InputDecoration(labelText: 'Item Name'),
    );
  }
}
