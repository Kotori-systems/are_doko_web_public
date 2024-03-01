import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_category.freezed.dart';

part 'item_category.g.dart';

/// 各アイテムのカテゴリーを保持するクラス
@freezed
class ItemCategory with _$ItemCategory {
  const ItemCategory._();

  static const String _noneString = 'None';

  const factory ItemCategory._internal(
    String? id,
    String? categoryName,
  ) = _ItemCategory;

  /// region factory methods

  factory ItemCategory({
    String? id,
    required String? categoryName,
  }) {
    if (categoryName == _noneString) {
      return ItemCategory.none;
    } else {
      return ItemCategory._internal(id, categoryName);
    }
  }

  factory ItemCategory.fromJson(Map<String, dynamic> json) =>
      _$ItemCategoryFromJson(json);

  /// endregion

  /// region getter methods

  String get displayName => categoryName ?? _noneString;

  static ItemCategory get none => ItemCategory(categoryName: null);

  /// endregion

  /// region public methods

  /// カテゴリー名の一覧を取得する
  /// 必要な場合は、画面表示用にカテゴリーなしの'None'を先頭に追加する
  /// （稀なケースだが、firestore上に'None'というカテゴリーがあった場合は追加しないようにする）
  ///
  /// @param [categories] 対象のカテゴリー一覧
  /// @param [currentCategoryName] 追加・編集中のアイテムのカテゴリ名
  /// @param [shouldInsertNone] カテゴリーなしの'None'を追加するかどうか
  static List<String> getDisplayNameList({
    required List<ItemCategory> categories,
    required String currentCategoryName,
    bool shouldInsertNone = false,
  }) {
    final categoryNameList =
        categories.map((category) => category.displayName).toSet().toList();
    if (shouldInsertNone &&
        !categoryNameList.contains(ItemCategory.none.displayName)) {
      categoryNameList.insert(0, ItemCategory.none.displayName);
    }
    if (!categoryNameList.contains(currentCategoryName)) {
      categoryNameList.insert(0, currentCategoryName);
    }
    return categoryNameList;
  }

  /// endregion
}

class ItemCategoryConverter implements JsonConverter<ItemCategory, String?> {
  const ItemCategoryConverter();

  @override
  ItemCategory fromJson(String? json) {
    return ItemCategory(categoryName: json);
  }

  @override
  String? toJson(ItemCategory object) {
    return object.categoryName;
  }
}
