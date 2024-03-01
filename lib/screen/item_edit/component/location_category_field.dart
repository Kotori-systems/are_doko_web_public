import 'package:flutter/material.dart';

class LocationCategoryField extends StatelessWidget {
  const LocationCategoryField({
    super.key,
    required this.controller,
  });

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Location Category',
      ),
    );
  }
}
