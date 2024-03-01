import 'package:are_doko_web/bloc/item_form/item_form_state.dart';
import 'package:are_doko_web/entity/item.dart';
import 'package:are_doko_web/entity/item_category.dart';
import 'package:are_doko_web/entity/location_category.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemFormBloc extends Cubit<ItemFormState> {
  ItemFormBloc()
      : super(
          const ItemFormState(),
        );

  @override
  String toString() => 'アイテム編集';

  void initialize(Item? selectedItem) {
    final isNewItem = selectedItem == null;
    final targetItem = selectedItem ?? Item.newItem();
    final nameController = TextEditingController(
      text: targetItem.name,
    );

    emit(
      state.copyWith(
        status: ItemFormStatus.initializeSuccess,
        isNewItem: isNewItem,
        targetItem: targetItem,
        nameController: nameController,
        itemCategoryController: TextEditingController(),
        locationCategoryController: TextEditingController(),
      ),
    );
  }

  ///  選択されたカテゴリー名から、選択状態を更新する
  void selectItemCategory(
    String categoryName,
    List<ItemCategory> itemCategories,
  ) {
    var selectedCategory = itemCategories.firstWhereOrNull(
      (category) => category.categoryName == categoryName,
    );
    // カテゴリー一覧に存在しなければ、新カテゴリーとする。（カテゴリーを追加した場合）
    selectedCategory ??= ItemCategory(categoryName: categoryName);
    // 選択状態を更新
    emit(
      state.copyWith(
        status: ItemFormStatus.selectItemCategorySuccess,
        targetItem: state.targetItem?.copyWith(category: selectedCategory),
      ),
    );
  }

  ///  選択されたカテゴリー名から、選択状態を更新する
  void selectLocationCategory(
    String categoryName,
    List<LocationCategory> locationCategories,
  ) {
    var selectedCategory = locationCategories.firstWhereOrNull(
      (category) => category.categoryName == categoryName,
    );
    // カテゴリー一覧に存在しなければ、新カテゴリーとする。（カテゴリーを追加した場合）
    selectedCategory ??= LocationCategory(categoryName: categoryName);
    // 選択状態を更新
    emit(
      state.copyWith(
        status: ItemFormStatus.selectItemCategorySuccess,
        targetItem:
            state.targetItem?.copyWith(locationCategory: selectedCategory),
      ),
    );
  }

  void validate() {
    if (state.nameController?.text.isEmpty ?? true) {
      emit(
        state.copyWith(
          status: ItemFormStatus.validationFailure,
          warningMessage: 'Input item name!!',
        ),
      );
    } else {
      var targetItem = state.targetItem!;

      // Item Name
      targetItem = targetItem.copyWith(name: state.nameController!.text);

      // Item Category
      final inputtedItemCategoryName = state.itemCategoryController?.text;
      if (inputtedItemCategoryName?.isNotEmpty ?? false) {
        targetItem = targetItem.copyWith(
          category: ItemCategory(categoryName: inputtedItemCategoryName),
        );
      }

      // Location Category
      final inputtedLocationCategoryName =
          state.locationCategoryController?.text;
      if (inputtedLocationCategoryName?.isNotEmpty ?? false) {
        targetItem = targetItem.copyWith(
          locationCategory:
              LocationCategory(categoryName: inputtedLocationCategoryName),
        );
      }
      emit(
        state.copyWith(
          status: ItemFormStatus.validationSuccess,
          targetItem: targetItem,
        ),
      );
    }
  }
}
