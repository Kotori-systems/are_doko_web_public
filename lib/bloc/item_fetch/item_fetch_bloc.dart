import 'dart:async';

import 'package:are_doko_web/bloc/item_fetch/item_fetch.dart';
import 'package:are_doko_web/repository/item_category_repository.dart';
import 'package:are_doko_web/repository/item_repository.dart';
import 'package:are_doko_web/repository/location_category_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemFetchBloc extends Cubit<ItemFetchState> {
  final ItemRepository _itemRepository;
  final LocationCategoryRepository _locationCategoryRepository;
  final ItemCategoryRepository _itemCategoryRepository;

  ItemFetchBloc(
    this._itemRepository,
    this._locationCategoryRepository,
    this._itemCategoryRepository,
  ) : super(
          const ItemFetchState(),
        );

  @override
  String toString() => 'アイテム取得';

  Future<void> fetchItemList() async {
    emit(
      state.copyWith(
        status: ItemFetchStatus.fetchItemListInProgress,
      ),
    );

    try {
      final items = await _itemRepository.getItems();

      emit(
        state.copyWith(
          status: ItemFetchStatus.fetchItemCategoryListSuccess,
          items: items,
          filteredItems: items,
        ),
      );
    } catch (e, s) {
      // 例外時は空の配列を返し、エラーレポートを上げる
      emit(
        state.copyWith(
          status: ItemFetchStatus.fetchItemCategoryListFailure,
          items: [],
          errorMessage: e.toString(),
        ),
      );

      addError(e, s);
    }

    emit(
      state.copyWith(
        status: ItemFetchStatus.idle,
      ),
    );
  }

  Future<void> fetchItemCategoryList() async {
    emit(
      state.copyWith(
        status: ItemFetchStatus.fetchItemCategoryListInProgress,
      ),
    );

    try {
      final itemCategories = await _itemCategoryRepository.getItemCategories();
      emit(
        state.copyWith(
          status: ItemFetchStatus.fetchItemCategoryListSuccess,
          itemCategories: itemCategories,
        ),
      );
    } catch (e, s) {
      // 例外時は空の配列を返し、エラーレポートを上げる
      emit(
        state.copyWith(
          status: ItemFetchStatus.fetchItemCategoryListFailure,
          itemCategories: [],
          errorMessage: e.toString(),
        ),
      );

      addError(e, s);
    }
  }

  Future<void> fetchLocationCategoryList() async {
    emit(
      state.copyWith(
        status: ItemFetchStatus.fetchLocationCategoryListInProgress,
      ),
    );

    try {
      final locationCategories =
          await _locationCategoryRepository.getLocationCategories();
      emit(
        state.copyWith(
          status: ItemFetchStatus.fetchLocationCategoryListSuccess,
          locationCategories: locationCategories,
        ),
      );
    } catch (e, s) {
      // 例外時は空の配列を返し、エラーレポートを上げる
      emit(
        state.copyWith(
          status: ItemFetchStatus.fetchLocationCategoryListFailure,
          locationCategories: [],
          errorMessage: e.toString(),
        ),
      );

      addError(e, s);
    }

    emit(
      state.copyWith(
        status: ItemFetchStatus.idle,
      ),
    );
  }

  void filterItems(String inputText) {
    final filteredItems = state.items?.where((item) {
      final lowerInputText = inputText.toLowerCase();
      final itemNameMatch = item.name.toLowerCase().contains(lowerInputText);
      final itemCategoryNameMatch =
          item.category.categoryName?.toLowerCase().contains(lowerInputText) ??
              false;
      final locationCategoryNameMatch = item.locationCategory.categoryName
              ?.toLowerCase()
              .contains(lowerInputText) ??
          false;

      return itemNameMatch ||
          itemCategoryNameMatch ||
          locationCategoryNameMatch;
    }).toList();

    emit(
      state.copyWith(
        status: ItemFetchStatus.filterItemsSuccess,
        filteredItems: filteredItems,
      ),
    );

    emit(
      state.copyWith(
        status: ItemFetchStatus.idle,
      ),
    );
  }
}
