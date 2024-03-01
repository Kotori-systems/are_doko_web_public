import 'package:are_doko_web/entity/item.dart';
import 'package:are_doko_web/entity/item_category.dart';
import 'package:are_doko_web/entity/location_category.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_fetch_state.freezed.dart';

enum ItemFetchStatus {
  initial('初期状態'),

  fetchItemListInProgress('アイテム一覧取得中'),
  fetchItemListSuccess('アイテム一覧取得成功'),
  fetchItemListFailure('アイテム一覧取得失敗'),

  fetchItemCategoryListInProgress('アイテムカテゴリ一覧取得中'),
  fetchItemCategoryListSuccess('アイテムカテゴリ一覧取得成功'),
  fetchItemCategoryListFailure('アイテムカテゴリ一覧取得成功'),

  fetchLocationCategoryListInProgress('場所カテゴリ一覧取得中'),
  fetchLocationCategoryListSuccess('場所カテゴリ一覧取得成功'),
  fetchLocationCategoryListFailure('場所カテゴリ一覧取得成功'),

  filterItemsSuccess('アイテム検索成功'),

  idle('待機中');

  final String name;
  const ItemFetchStatus(this.name);
}

@freezed
class ItemFetchState with _$ItemFetchState {
  const ItemFetchState._();

  const factory ItemFetchState({
    //
    @Default(ItemFetchStatus.initial) ItemFetchStatus status,

    //
    List<Item>? items,

    //
    List<Item>? filteredItems,

    //
    @Default([]) List<LocationCategory> locationCategories,

    //
    @Default([]) List<ItemCategory> itemCategories,

    //
    String? errorMessage,
  }) = _ItemFetchState;
}
