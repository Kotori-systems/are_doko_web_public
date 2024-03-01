import 'package:are_doko_web/data_provider/firestore_collections.dart';
import 'package:are_doko_web/data_provider/firestore_data_provider.dart';
import 'package:are_doko_web/entity/item_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemCategoryRepository {
  factory ItemCategoryRepository() {
    return _singleton;
  }

  ItemCategoryRepository.forTest({
    required FirestoreDataProvider cloudFirestoreDataProvider,
  }) : _itemDataProvider = cloudFirestoreDataProvider;

  ItemCategoryRepository._internal()
      : _itemDataProvider = FirestoreDataProvider();

  static final ItemCategoryRepository _singleton =
      ItemCategoryRepository._internal();

  final FirestoreDataProvider _itemDataProvider;

  Future<List<ItemCategory>> getItemCategories() async {
    final documents = await _itemDataProvider
        .fetchDocuments(FirestoreCollections.itemCategories.name);

    return documents.docs.map((snapshot) {
      final data = snapshot.data();
      data['id'] = snapshot.id;
      return ItemCategory.fromJson(data);
    }).toList();
  }

  Future<void> upsertCategory(ItemCategory category) async {
    final data = category.toJson();

    // Documentのdata内にidは不要のため削除する
    data['id'] = FieldValue.delete();

    await _itemDataProvider.upsertDocument(
      FirestoreCollections.itemCategories.name,
      category.id,
      data,
    );
  }
}
