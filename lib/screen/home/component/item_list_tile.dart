import 'package:are_doko_web/entity/item.dart';
import 'package:are_doko_web/entity/item_category.dart';
import 'package:flutter/material.dart';

class ItemListTile extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ItemListTile({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        item.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          item.category == ItemCategory.none
              ? const SizedBox.shrink()
              : Text(
                  'Category: ${item.category.displayName}',
                ),
          Text(
            'Location: ${item.locationCategory.displayName}',
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
