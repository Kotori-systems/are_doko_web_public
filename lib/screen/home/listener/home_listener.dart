import 'package:are_doko_web/bloc/home/home.dart';
import 'package:are_doko_web/util/dialog_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeListener extends BlocListener<HomeBloc, HomeState> {
  HomeListener({
    super.key,
    super.child,
  }) : super(
          listener: (context, state) async {
            final bloc = context.read<HomeBloc>();
            switch (state.status) {
              case HomeStatus.initial:
              case HomeStatus.idle:
              case HomeStatus.requestFcmPermissionInProgress:
              case HomeStatus.saveFcmTokenInProgress:
              case HomeStatus.getAuthorizationStatusInProgress:
              case HomeStatus.listenFcmMessageSuccess:
              case HomeStatus.getAuthorizationStatusSuccess:
                // do nothing
                break;
              case HomeStatus.requestFcmPermissionSuccess:
                bloc.saveFcmToken(state.token).ignore();
                break;
              case HomeStatus.saveFcmTokenSuccess:
                bloc.listenFcmMessage();
                break;
              case HomeStatus.requestFcmPermissionFailure:
              case HomeStatus.saveFcmTokenFailure:
              case HomeStatus.listenFcmMessageFailure:
              case HomeStatus.getAuthorizationStatusFailure:
                // TODO(tanaka): #20 各画面のエラーダイアログの共通化
                DialogUtil.showErrorDialog(
                  context,
                  '${state.status}:${state.errorMessage}',
                ).ignore();
                break;
            }
          },
        );
}
