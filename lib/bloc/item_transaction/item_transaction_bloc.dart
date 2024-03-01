import 'dart:async';

import 'package:are_doko_web/bloc/item_transaction/item_transaction_state.dart';
import 'package:are_doko_web/entity/item.dart';
import 'package:are_doko_web/entity/item_category.dart';
import 'package:are_doko_web/entity/location_category.dart';
import 'package:are_doko_web/repository/item_category_repository.dart';
import 'package:are_doko_web/repository/item_repository.dart';
import 'package:are_doko_web/repository/location_category_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemTransactionBloc extends Cubit<ItemTransactionState> {
  final ItemRepository itemRepository;
  final LocationCategoryRepository locationCategoryRepository;
  final ItemCategoryRepository itemCategoryRepository;

  ItemTransactionBloc(
    this.itemRepository,
    this.locationCategoryRepository,
    this.itemCategoryRepository,
  ) : super(
          const ItemTransactionState(),
        );

  @override
  String toString() => 'アイテムのトランザクション';

  Future<void> upsertItem(Item? item) async {
    emit(
      state.copyWith(
        status: ItemTransactionStatus.upsertItemInProgress,
        isInTransaction: true,
      ),
    );

    try {
      await itemRepository.upsertItem(item!);

      emit(
        state.copyWith(
          status: ItemTransactionStatus.upsertItemSuccess,
          upsertedItem: item,
          isInTransaction: false,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          status: ItemTransactionStatus.upsertItemFailure,
          errorMessage: e.toString(),
          isInTransaction: false,
        ),
      );
      addError(e, s);
    }

    emit(
      state.copyWith(
        status: ItemTransactionStatus.idle,
      ),
    );
  }

  Future<void> upsertItemCategoryIfNeeded(Item? upsertedItem) async {
    emit(
      state.copyWith(
        status: ItemTransactionStatus.upsertItemCategoryInProgress,
        isInTransaction: true,
      ),
    );

    try {
      // Noneのカテゴリーでなく、かつ選択したカテゴリーのidがnullならfirestoreに存在しないはずなので追加
      // （念の為実際の存在チェックを行う）
      final itemCategory = upsertedItem!.category;
      if (itemCategory != ItemCategory.none && itemCategory.id == null) {
        final categoryNameList =
            (await itemCategoryRepository.getItemCategories())
                .map((category) => category.categoryName);
        if (!categoryNameList.contains(itemCategory.categoryName)) {
          await itemCategoryRepository.upsertCategory(itemCategory);
        }
      }

      emit(
        state.copyWith(
          status: ItemTransactionStatus.upsertItemCategorySuccess,
          isInTransaction: false,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          status: ItemTransactionStatus.upsertItemCategoryFailure,
          errorMessage: e.toString(),
          isInTransaction: false,
        ),
      );
      addError(e, s);
    }

    emit(
      state.copyWith(
        status: ItemTransactionStatus.idle,
      ),
    );
  }

  // TODO: #24 upsertItemCategoryIfNeeded,upsertLocationCategoryIfNeeded のメソッドと共通化する？
  Future<void> upsertLocationCategoryIfNeeded(Item? upsertedItem) async {
    emit(
      state.copyWith(
        status: ItemTransactionStatus.upsertLocationCategoryInProgress,
        isInTransaction: true,
      ),
    );

    try {
      // Noneのカテゴリーでなく、かつ選択したカテゴリーのidがnullならfirestoreに存在しないはずなので追加
      // （念の為実際の存在チェックを行う）
      final locationCategory = upsertedItem!.locationCategory;
      if (locationCategory != LocationCategory.none &&
          locationCategory.id == null) {
        final categoryNameList =
            (await locationCategoryRepository.getLocationCategories())
                .map((category) => category.categoryName);
        if (!categoryNameList.contains(locationCategory.categoryName)) {
          await locationCategoryRepository.upsertCategory(locationCategory);
        }
      }

      emit(
        state.copyWith(
          status: ItemTransactionStatus.upsertLocationCategorySuccess,
          isInTransaction: false,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          status: ItemTransactionStatus.upsertLocationCategoryFailure,
          errorMessage: e.toString(),
          isInTransaction: false,
        ),
      );
      addError(e, s);
    }

    emit(
      state.copyWith(
        status: ItemTransactionStatus.idle,
      ),
    );
  }


  Future<void> deleteItem(Item? item) async {
    emit(
      state.copyWith(
        status: ItemTransactionStatus.deleteItemInProgress,
        isInTransaction: true,
      ),
    );

    try {
      await itemRepository.deleteItem(item!.id!);

      emit(
        state.copyWith(
          status: ItemTransactionStatus.deleteItemSuccess,
          isInTransaction: false,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          status: ItemTransactionStatus.deleteItemFailure,
          errorMessage: e.toString(),
          isInTransaction: false,
        ),
      );
      addError(e, s);
    }

    emit(
      state.copyWith(
        status: ItemTransactionStatus.idle,
      ),
    );
  }
}
