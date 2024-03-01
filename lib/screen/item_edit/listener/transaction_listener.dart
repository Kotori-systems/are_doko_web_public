import 'package:are_doko_web/bloc/item_form/item_form_bloc.dart';
import 'package:are_doko_web/bloc/item_transaction/item_transaction.dart';
import 'package:are_doko_web/util/dialog_util.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionListener extends BlocListener<ItemTransactionBloc, ItemTransactionState> {
  TransactionListener({
    super.key,
    super.child,
  }) : super(
          listener: (context, state) async {
            final bloc = context.read<ItemTransactionBloc>();
            switch (state.status) {
              case ItemTransactionStatus.initial:
              case ItemTransactionStatus.idle:
              case ItemTransactionStatus.upsertItemInProgress:
              case ItemTransactionStatus.upsertItemCategoryInProgress:
              case ItemTransactionStatus.upsertLocationCategoryInProgress:
              case ItemTransactionStatus.deleteItemInProgress:
                // do nothing
                break;
              case ItemTransactionStatus.upsertItemSuccess:
                context.read<ItemFormBloc>().state.clearController();
                bloc.upsertItemCategoryIfNeeded(state.upsertedItem).ignore();
                break;
              case ItemTransactionStatus.upsertItemCategorySuccess:
                bloc.upsertLocationCategoryIfNeeded(state.upsertedItem).ignore();
                break;
              case ItemTransactionStatus.upsertLocationCategorySuccess:
              case ItemTransactionStatus.deleteItemSuccess:
                Navigator.pop(context);
                break;
              case ItemTransactionStatus.upsertItemFailure:
              case ItemTransactionStatus.upsertItemCategoryFailure:
              case ItemTransactionStatus.upsertLocationCategoryFailure:
              case ItemTransactionStatus.deleteItemFailure:
                 DialogUtil.showErrorDialog(context, '${state.errorMessage}')
                    .ignore();
                break;
            }
          },
        );
}
