import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDataProvider {
  factory FirestoreDataProvider() {
    return _singleton;
  }

  FirestoreDataProvider._internal();
  static final FirestoreDataProvider _singleton = FirestoreDataProvider._internal();

  final _firestoreInstance = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> fetchDocuments(
    String collectionName,
  ) async {
    return await _firestoreInstance.collection(collectionName).get();
  }

  /// 指定した documentId に紐づくDocumentを更新する。
  /// Documentが存在しなければ追加する
  ///
  /// @param [documentId] Document ID。追加する時はnullを指定する（そうすることでfirestore側でキーが自動生成されるようだ）
  /// @param [document] 更新/追加するDocumentのデータ
  Future<void> upsertDocument(
    String collectionName,
    String? documentId,
    Map<String, dynamic> document,
  ) async {
    document['create_timestamp'] = FieldValue.serverTimestamp();
    await _firestoreInstance
        .collection(collectionName)
        .doc(documentId)
        .set(
          document,
          SetOptions(merge: true),
        );
  }

  /// 指定した documentId に紐づくDocumentを削除する。
  ///
  /// @param [documentId] Document ID
  Future<void> deleteDocument(
    String collectionName,
    String? documentId,
  ) async {
    await _firestoreInstance
        .collection(collectionName)
        .doc(documentId)
        .delete();
  }
}
