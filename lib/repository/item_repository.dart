import 'package:are_doko_web/data_provider/firestore_collections.dart';
import 'package:are_doko_web/data_provider/firestore_data_provider.dart';
import 'package:are_doko_web/entity/item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemRepository {
  factory ItemRepository() {
    return _singleton;
  }

  ItemRepository.forTest({
    required FirestoreDataProvider cloudFirestoreDataProvider,
  }) : _itemDataProvider = cloudFirestoreDataProvider;

  ItemRepository._internal() : _itemDataProvider = FirestoreDataProvider();

  static final ItemRepository _singleton = ItemRepository._internal();

  final FirestoreDataProvider _itemDataProvider;

  Future<List<Item>> getItems() async {
    // 現在のユーザーを取得する
    final documents =
        await _itemDataProvider.fetchDocuments(FirestoreCollections.items.name);

    return documents.docs.map((snapshot) {
      final data = snapshot.data();
      data['id'] = snapshot.id;
      return Item.fromJson(data);
    }).toList();
  }

  Future<void> upsertItem(Item item) async {
    final data = item.toJson();

    // Documentのdata内にidは不要のため削除する
    data['id'] = FieldValue.delete();

    await _itemDataProvider.upsertDocument(
      FirestoreCollections.items.name,
      item.id,
      data,
    );
  }

  Future<void> deleteItem(String itemId) async {
    await _itemDataProvider.deleteDocument(
      FirestoreCollections.items.name,
      itemId,
    );
  }
}
