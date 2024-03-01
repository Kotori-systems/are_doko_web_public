import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_category.freezed.dart';

part 'location_category.g.dart';

/// Locationのカテゴリーを保持するクラス
@freezed
class LocationCategory with _$LocationCategory {
  const LocationCategory._();

  static const String _noneString = 'None';

  const factory LocationCategory._internal(
    String? id,
    String? categoryName,
  ) = _LocationCategory;

  /// region factory methods

  factory LocationCategory({
    String? id,
    required String? categoryName,
  }) {
    if (categoryName == _noneString) {
      return LocationCategory.none;
    } else {
      return LocationCategory._internal(id, categoryName);
    }
  }

  factory LocationCategory.fromJson(Map<String, dynamic> json) =>
      _$LocationCategoryFromJson(json);

  /// endregion

  /// region getter methods

  String get displayName => categoryName ?? _noneString;

  static LocationCategory get none => LocationCategory(categoryName: null);

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
    required List<LocationCategory> categories,
    required String currentCategoryName,
    bool shouldInsertNone = false,
  }) {
    final categoryNameList =
        categories.map((category) => category.displayName).toSet().toList();
    if (shouldInsertNone &&
        !categoryNameList.contains(LocationCategory.none.displayName)) {
      categoryNameList.insert(0, LocationCategory.none.displayName);
    }
    if (!categoryNameList.contains(currentCategoryName)) {
      categoryNameList.insert(0, currentCategoryName);
    }
    return categoryNameList;
  }

  /// endregion
}

class LocationCategoryConverter
    implements JsonConverter<LocationCategory, String?> {
  const LocationCategoryConverter();

  @override
  LocationCategory fromJson(String? json) {
    return LocationCategory(categoryName: json);
  }

  @override
  String? toJson(LocationCategory object) {
    return object.categoryName;
  }
}
