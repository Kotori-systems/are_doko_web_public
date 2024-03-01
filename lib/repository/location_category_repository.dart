import 'package:are_doko_web/data_provider/firestore_collections.dart';
import 'package:are_doko_web/data_provider/firestore_data_provider.dart';
import 'package:are_doko_web/entity/location_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationCategoryRepository {
  factory LocationCategoryRepository() {
    return _singleton;
  }

  LocationCategoryRepository.forTest({
    required FirestoreDataProvider cloudFirestoreDataProvider,
  }) : _itemDataProvider = cloudFirestoreDataProvider;

  LocationCategoryRepository._internal()
      : _itemDataProvider = FirestoreDataProvider();

  static final LocationCategoryRepository _singleton =
      LocationCategoryRepository._internal();

  final FirestoreDataProvider _itemDataProvider;

  Future<List<LocationCategory>> getLocationCategories() async {
    final documents = await _itemDataProvider
        .fetchDocuments(FirestoreCollections.locationCategories.name);

    return documents.docs.map((snapshot) {
      final data = snapshot.data();
      data['id'] = snapshot.id;
      return LocationCategory.fromJson(data);
    }).toList();
  }

  Future<void> upsertCategory(LocationCategory category) async {
    final data = category.toJson();

    // Documentのdata内にidは不要のため削除する
    data['id'] = FieldValue.delete();

    await _itemDataProvider.upsertDocument(
      FirestoreCollections.locationCategories.name,
      category.id,
      data,
    );
  }
}
