import 'dart:math';

import 'package:are_doko_web/bloc/item_fetch/item_fetch.dart';
import 'package:are_doko_web/bloc/item_form/item_form.dart';
import 'package:are_doko_web/bloc/item_transaction/item_transaction.dart';
import 'package:are_doko_web/entity/item.dart';
import 'package:are_doko_web/repository/item_category_repository.dart';
import 'package:are_doko_web/repository/item_repository.dart';
import 'package:are_doko_web/repository/location_category_repository.dart';
import 'package:are_doko_web/screen/common/stateful_twin_triple_wrapper.dart';
import 'package:are_doko_web/screen/item_edit/component/add_or_edit_button.dart';
import 'package:are_doko_web/screen/item_edit/component/delete_button.dart';
import 'package:are_doko_web/screen/item_edit/component/item_name_field.dart';
import 'package:are_doko_web/screen/item_edit/listener/form_listener.dart';
import 'package:are_doko_web/screen/item_edit/listener/transaction_listener.dart';
import 'package:are_doko_web/screen/item_edit/template/item_category_row.dart';
import 'package:are_doko_web/screen/item_edit/template/location_category_row.dart';
import 'package:are_doko_web/util/dialog_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemEditScreenPage extends StatelessWidget {
  const ItemEditScreenPage({
    super.key,
    required this.selectedItem,
  });
  final Item? selectedItem;

  @override
  Widget build(BuildContext context) {
    return StatefulTwinTripleWrapper<ItemFetchBloc, ItemFetchState,
        ItemFormBloc, ItemFormState, ItemTransactionBloc, ItemTransactionState>(
      providers: [
        BlocProvider<ItemFetchBloc>(
          create: (context) => ItemFetchBloc(
            ItemRepository(),
            LocationCategoryRepository(),
            ItemCategoryRepository(),
          ),
        ),
        BlocProvider<ItemFormBloc>(
          create: (context) => ItemFormBloc(),
        ),
        BlocProvider<ItemTransactionBloc>(
          create: (context) => ItemTransactionBloc(
            ItemRepository(),
            LocationCategoryRepository(),
            ItemCategoryRepository(),
          ),
        ),
      ],
      onInit: (context) => {
        context.read<ItemFormBloc>().initialize(selectedItem),
        context.read<ItemFetchBloc>().fetchItemCategoryList(),
        context.read<ItemFetchBloc>().fetchLocationCategoryList(),
      },
      listeners: [
        // FetchListener は監視する必要がなさそうなので不要そう。
        FormListener(),
        TransactionListener(),
      ],
      childBuilder: (context) {
        final transactionState = context.select(
          (ItemTransactionBloc bloc) => bloc.state,
        );
        final formState = context.select(
          (ItemFormBloc bloc) => bloc.state,
        );
        return formState.targetItem == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
              padding: EdgeInsets.only(
                top: 16,
                right: 16,
                left: 16,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom, // keyboard pop up
              ),
              shrinkWrap: true,
              children: [
                ItemNameField(controller: formState.nameController),
                const ItemCategoryRow(),
                const LocationCategoryRow(),
                const SizedBox(height: 15),
                AddOrEditButton(
                  isNewItem: formState.isNewItem,
                  onPressed: transactionState.isInTransaction
                      ? null
                      : () => context.read<ItemFormBloc>().validate(),
                ),
                if (!formState.isNewItem)
                  DeleteButton(
                    onPressed: transactionState.isInTransaction
                        ? null
                        : () {
                            DialogUtil.showConfirmationDialog(
                              context,
                              'Are you sure of deleting this item?',
                              () {
                                context
                                    .read<ItemTransactionBloc>()
                                    .deleteItem(formState.targetItem);
                              },
                            );
                          },
                  ),
              ],
            );
      },
    );
  }
}
