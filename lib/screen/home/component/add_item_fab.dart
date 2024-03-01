import 'package:flutter/material.dart';

class AddItemFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const AddItemFAB({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 20),
        child: FloatingActionButton(
          onPressed: onPressed,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
