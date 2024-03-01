import 'package:are_doko_web/entity/item_category.dart';
import 'package:are_doko_web/entity/location_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item.freezed.dart';

part 'item.g.dart';

@freezed
class Item with _$Item {
  const Item._();

  const factory Item({
    String? id,
    required String name,
    @LocationCategoryConverter() required LocationCategory locationCategory,
    @ItemCategoryConverter() required ItemCategory category,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  factory Item.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    data['id'] = snapshot.id;
    return Item.fromJson(data);
  }

  static Item newItem() {
    return Item(
      name: '',
      locationCategory: LocationCategory.none,
      category: ItemCategory.none,
    );
  }
}
