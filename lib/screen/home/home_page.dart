import 'dart:async';

import 'package:are_doko_web/bloc/home/home.dart';
import 'package:are_doko_web/bloc/item_fetch/item_fetch.dart';
import 'package:are_doko_web/entity/item.dart';
import 'package:are_doko_web/repository/item_category_repository.dart';
import 'package:are_doko_web/repository/item_repository.dart';
import 'package:are_doko_web/repository/location_category_repository.dart';
import 'package:are_doko_web/screen/common/stateful_twin_cubit_wrapper.dart';
import 'package:are_doko_web/screen/home/component/add_item_fab.dart';
import 'package:are_doko_web/screen/home/component/item_list_tile.dart';
import 'package:are_doko_web/screen/home/component/search_text_field.dart';
import 'package:are_doko_web/screen/home/listener/fetch_listener.dart';
import 'package:are_doko_web/screen/home/listener/home_listener.dart';
import 'package:are_doko_web/screen/item_edit/item_edit_screen_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    return StatefulTwinCubitWrapper<ItemFetchBloc, ItemFetchState, HomeBloc,
        HomeState>(
      providers: [
        BlocProvider<ItemFetchBloc>(
          create: (context) => ItemFetchBloc(
            ItemRepository(),
            LocationCategoryRepository(),
            ItemCategoryRepository(),
          ),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(),
        ),
      ],
      onInit: (context) => {
        context.read<ItemFetchBloc>().fetchItemList(),
        context.read<HomeBloc>().getAuthorizationStatus(),
      },
      listeners: [
        HomeListener(),
        FetchListener(),
      ],
      childBuilder: (context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Are Doko Web'),
          toolbarHeight: 30,
          actions: [
            TextButton(
              onPressed: () {
                context.read<ItemFetchBloc>().fetchItemList();
              },
              child: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: Stack(
          children: [
            if (context
                    .select(
                      (ItemFetchBloc bloc) => bloc.state,
                    )
                    .filteredItems ==
                null) ...[
              const Center(
                child: CircularProgressIndicator(),
              ),
            ] else ...[
              Align(
                alignment: Alignment.topCenter,
                child: SearchTextField(
                  searchController: searchController,
                  onChanged: (value) =>
                      context.read<ItemFetchBloc>().filterItems(value),
                ),
              ),
              if (context
                  .select(
                    (ItemFetchBloc bloc) => bloc.state,
                  )
                  .filteredItems!
                  .isEmpty) ...[
                const Center(
                  child: Text('No item'),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: ListView.builder(
                    itemCount: context
                        .select(
                          (ItemFetchBloc bloc) => bloc.state,
                        )
                        .filteredItems!
                        .length,
                    itemBuilder: (context, index) {
                      final item = context
                          .read<ItemFetchBloc>()
                          .state
                          .filteredItems![index];
                      return ItemListTile(
                        item: item,
                        onTap: () => _navigateToItemEditScreen(context, item),
                      );
                    },
                  ),
                ),
              ],
              AddItemFAB(
                onPressed: () => _navigateToItemEditScreen(context, null),
              ),
            ],
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: context
                .select(
                  (HomeBloc bloc) => bloc.state,
                )
                .shouldHideNotificationButton
            ? const SizedBox.shrink()
            : FloatingActionButton(
                mini: true,
                onPressed: () =>
                    context.read<HomeBloc>().requestFcmPermission(),
                child: const Icon(Icons.notification_add),
              ),
      ),
    );
  }

  Future<void> _navigateToItemEditScreen(
    BuildContext context,
    Item? item,
  ) async {
    // 編集画面にページ遷移（モーダル表示）
    showModalBottomSheet<Item>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ItemEditScreenPage(selectedItem: item),
    )
        // fetch item list when closing the modal sheet
        .then((_) => context.read<ItemFetchBloc>().fetchItemList().ignore())
        .ignore();
    ;
  }
}
