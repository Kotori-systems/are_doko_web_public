import 'package:are_doko_web/bloc/item_fetch/item_fetch.dart';
import 'package:are_doko_web/bloc/item_form/item_form_bloc.dart';
import 'package:are_doko_web/entity/item_category.dart';
import 'package:are_doko_web/screen/common/dropdown_menu.dart';
import 'package:are_doko_web/screen/item_edit/component/item_category_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemCategoryRow extends StatelessWidget {
  const ItemCategoryRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final fetchState = context.select(
      (ItemFetchBloc bloc) => bloc.state,
    );
    final formState = context.select(
      (ItemFormBloc bloc) => bloc.state,
    );

    return Row(
      children: [
        SizedBox(
          width: 200,
          child: DropdownButtonMenu(
            choices: ItemCategory.getDisplayNameList(
              categories: fetchState.itemCategories,
              currentCategoryName: formState.targetItem!.category.displayName,
              shouldInsertNone: true,
            ),
            initialValue: formState.targetItem!.category.displayName,
            onChanged: (categoryName) => context
                .read<ItemFormBloc>()
                .selectItemCategory(categoryName, fetchState.itemCategories),
          ),
        ),
        Flexible(
          child: ItemCategoryField(
            controller: formState.itemCategoryController,
          ),
        ),
      ],
    );
  }
}
