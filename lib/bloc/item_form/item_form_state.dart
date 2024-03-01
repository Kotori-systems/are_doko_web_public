import 'package:are_doko_web/entity/item.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_form_state.freezed.dart';

enum ItemFormStatus {
  initial('初期状態'),

  initializeSuccess('初期化成功'),

  selectItemCategorySuccess('アイテムカテゴリー選択成功'),

  selectLocationCategorySuccess('場所カテゴリー選択成功'),

  validationSuccess('バリデーション成功'),
  validationFailure('バリデーション失敗'),

  idle('待機中');

  final String name;
  const ItemFormStatus(this.name);
}

@freezed
class ItemFormState with _$ItemFormState {
  const ItemFormState._();

  const factory ItemFormState({
    //
    @Default(ItemFormStatus.initial) ItemFormStatus status,

    //
    Item? targetItem,

    //
    @Default(true) bool isNewItem,

    //
    Item? upsertedItem,

    //
    TextEditingController? nameController,

    //
    TextEditingController? itemCategoryController,

    //
    TextEditingController? locationCategoryController,

    //
    String? warningMessage,
  }) = _ItemFormState;

  void clearController() {
    nameController?.clear();
    locationCategoryController?.clear();
    itemCategoryController?.clear();
  }
}
