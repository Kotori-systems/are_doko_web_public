import 'package:are_doko_web/entity/item.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_transaction_state.freezed.dart';

enum ItemTransactionStatus {
  initial('初期状態'),

  upsertItemInProgress('アイテム追加/変更中'),
  upsertItemSuccess('アイテム追加/変更完了'),
  upsertItemFailure('アイテム追加/変更失敗'),

  upsertItemCategoryInProgress('アイテムカテゴリ追加/変更中'),
  upsertItemCategorySuccess('アイテムカテゴリ追加/変更完了'),
  upsertItemCategoryFailure('アイテムカテゴリ追加/変更失敗'),

  upsertLocationCategoryInProgress('場所カテゴリ追加/変更中'),
  upsertLocationCategorySuccess('場所カテゴリ追加/変更完了'),
  upsertLocationCategoryFailure('場所カテゴリ追加/変更失敗'),

  deleteItemInProgress('アイテム削除中'),
  deleteItemSuccess('アイテム削除完了'),
  deleteItemFailure('アイテム削除失敗'),

  idle('待機中');

  final String name;
  const ItemTransactionStatus(this.name);
}

@freezed
class ItemTransactionState with _$ItemTransactionState {
  const ItemTransactionState._();

  const factory ItemTransactionState({
    //
    @Default(ItemTransactionStatus.initial) ItemTransactionStatus status,

    //
    Item? upsertedItem,

    //
    @Default(false) bool isInTransaction,

    //
    String? errorMessage,
  }) = _ItemTransactionState;
}
