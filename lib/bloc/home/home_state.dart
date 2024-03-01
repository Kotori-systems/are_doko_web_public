import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

enum HomeStatus {
  initial('初期状態'),

  getAuthorizationStatusInProgress('FCMの権限取得中'),
  getAuthorizationStatusSuccess('FCMの権限取得成功'),
  getAuthorizationStatusFailure('FCMの権限取得失敗'),

  requestFcmPermissionInProgress('FCMの権限要求中'),
  requestFcmPermissionSuccess('FCMの権限要求成功'),
  requestFcmPermissionFailure('FCMの権限要求失敗'),

  saveFcmTokenInProgress('FCMのトークン保存中'),
  saveFcmTokenSuccess('FCMのトークン保存成功'),
  saveFcmTokenFailure('FCMのトークン保存失敗'),

  listenFcmMessageSuccess('FCMのメッセージ監視登録成功'),
  listenFcmMessageFailure('FCMのメッセージ監視登録失敗'),

  idle('待機中');

  final String name;
  const HomeStatus(this.name);
}

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    //
    @Default(HomeStatus.initial) HomeStatus status,

    //
    String? token,

    //
    @Default(false) bool shouldHideNotificationButton,

    //
    String? errorMessage,
  }) = _HomeState;
}
