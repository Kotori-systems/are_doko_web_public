import 'package:flutter/material.dart';

class AddOrEditButton extends StatelessWidget {
  const AddOrEditButton({
    super.key,
    required this.isNewItem,
    required this.onPressed,
  });

  final bool isNewItem;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      onPressed: onPressed,
      child: Text(
        isNewItem ? 'Add' : 'Edit',
      ),
    );
  }
}
