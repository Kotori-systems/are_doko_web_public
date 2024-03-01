import 'package:are_doko_web/bloc/item_fetch/item_fetch.dart';
import 'package:are_doko_web/bloc/item_form/item_form_bloc.dart';
import 'package:are_doko_web/entity/location_category.dart';
import 'package:are_doko_web/screen/common/dropdown_menu.dart';
import 'package:are_doko_web/screen/item_edit/component/location_category_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationCategoryRow extends StatelessWidget {
  const LocationCategoryRow({
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
            choices: LocationCategory.getDisplayNameList(
              categories: fetchState.locationCategories,
              currentCategoryName:
                  formState.targetItem!.locationCategory.displayName,
              shouldInsertNone: true,
            ),
            initialValue: formState.targetItem!.locationCategory.displayName,
            onChanged: (categoryName) =>
                context.read<ItemFormBloc>().selectLocationCategory(
                      categoryName,
                      fetchState.locationCategories,
                    ),
          ),
        ),
        Expanded(
          child: LocationCategoryField(
            controller: formState.locationCategoryController,
          ),
        ),
      ],
    );
  }
}
