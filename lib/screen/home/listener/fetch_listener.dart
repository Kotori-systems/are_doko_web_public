import 'package:are_doko_web/bloc/item_fetch/item_fetch.dart';
import 'package:are_doko_web/util/dialog_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FetchListener extends BlocListener<ItemFetchBloc, ItemFetchState> {
  FetchListener({
    super.key,
    super.child,
  }) : super(
          listener: (context, state) async {
            switch (state.status) {
              case ItemFetchStatus.initial:
              case ItemFetchStatus.idle:
              case ItemFetchStatus.fetchItemListInProgress:
              case ItemFetchStatus.fetchLocationCategoryListInProgress:
              case ItemFetchStatus.fetchItemCategoryListInProgress:
              case ItemFetchStatus.fetchItemListSuccess:
              case ItemFetchStatus.fetchItemCategoryListSuccess:
              case ItemFetchStatus.fetchLocationCategoryListSuccess:
              case ItemFetchStatus.filterItemsSuccess:
                // do nothing
                break;
              case ItemFetchStatus.fetchItemListFailure:
              case ItemFetchStatus.fetchItemCategoryListFailure:
              case ItemFetchStatus.fetchLocationCategoryListFailure:
                DialogUtil.showErrorDialog(
                  context,
                  '${state.status}:${state.errorMessage}',
                ).ignore();
                break;
            }
          },
        );
}
