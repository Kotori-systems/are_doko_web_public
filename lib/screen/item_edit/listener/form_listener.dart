import 'package:are_doko_web/bloc/item_form/item_form.dart';
import 'package:are_doko_web/bloc/item_transaction/item_transaction_bloc.dart';
import 'package:are_doko_web/util/dialog_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormListener extends BlocListener<ItemFormBloc, ItemFormState> {
  FormListener({
    super.key,
    super.child,
  }) : super(
          listener: (context, state) async {
            switch (state.status) {
              case ItemFormStatus.initial:
              case ItemFormStatus.idle:
              case ItemFormStatus.initializeSuccess:
              case ItemFormStatus.selectItemCategorySuccess:
              case ItemFormStatus.selectLocationCategorySuccess:
                // do nothing
                break;
              case ItemFormStatus.validationSuccess:
                 context.read<ItemTransactionBloc>().upsertItem(state.targetItem).ignore();
                break;
              case ItemFormStatus.validationFailure:
                 DialogUtil.showWarningDialog(context, '${state.warningMessage}')
                    .ignore();
            }
          },
        );
}
