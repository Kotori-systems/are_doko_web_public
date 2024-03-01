import 'dart:async';
import 'dart:developer';

import 'package:are_doko_web/bloc/home/home_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// TODO(tanaka): #18 各メソッドについて、repository, data_providerを使うよう修正する？（またはUtilクラス直接呼ぶとかの方が良いかも）
class HomeBloc extends Cubit<HomeState> {
  final messaging = FirebaseMessaging.instance;

  HomeBloc()
      : super(
          const HomeState(),
        );

  @override
  String toString() => 'ホーム';

  Future<void> getAuthorizationStatus() async {
    emit(
      state.copyWith(
        status: HomeStatus.getAuthorizationStatusInProgress,
      ),
    );

    try {
      final authorizationStatus =
          (await messaging.getNotificationSettings()).authorizationStatus;
      emit(
        state.copyWith(
          status: HomeStatus.getAuthorizationStatusSuccess,
          shouldHideNotificationButton:
              authorizationStatus != AuthorizationStatus.notDetermined,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          status: HomeStatus.getAuthorizationStatusFailure,
          errorMessage: e.toString(),
        ),
      );
    }

    emit(
      state.copyWith(
        status: HomeStatus.idle,
      ),
    );
  }

  Future<void> requestFcmPermission() async {
    emit(
      state.copyWith(
        status: HomeStatus.requestFcmPermissionInProgress,
      ),
    );

    try {
      // パーミッションの設定
      final settings = await messaging.requestPermission(
          // TODO(tanaka): #21 FCMの権限要求時のパーミッションの設定詳細を確認
          // alert: true,
          // announcement: false,
          // badge: true,
          // carPlay: false,
          // criticalAlert: false,
          // provisional: false,
          // sound: true,
          );
      log('User granted permission: ${settings.authorizationStatus}');

      // トークン取得
      final token = (await messaging.getToken(
        vapidKey: dotenv.env['VAPID_KEY'],
      ))
          .toString();

      emit(
        state.copyWith(
          status: HomeStatus.requestFcmPermissionSuccess,
          token: token,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          status: HomeStatus.requestFcmPermissionFailure,
          errorMessage: e.toString(),
        ),
      );
    }

    emit(
      state.copyWith(
        status: HomeStatus.idle,
      ),
    );
  }

  Future<void> saveFcmToken(String? token) async {
    emit(
      state.copyWith(
        status: HomeStatus.saveFcmTokenInProgress,
      ),
    );

    try {
      final firestore = FirebaseFirestore.instance;
      final data = {
        'create_timestamp': FieldValue.serverTimestamp(),
      };
      await firestore.collection('notification').doc(token!).set(data);
      emit(
        state.copyWith(
          status: HomeStatus.saveFcmTokenSuccess,
          token: token,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          status: HomeStatus.saveFcmTokenFailure,
          token: token,
          errorMessage: e.toString(),
        ),
      );
    }

    emit(
      state.copyWith(
        status: HomeStatus.idle,
      ),
    );
  }

  void listenFcmMessage() {
    try {
      // メッセージのリッスン
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('Got a message whilst in the foreground!');

        if (message.notification != null) {
          log('onForegroundMessage Title: ${message.notification?.title}');
          log('onForegroundMessage Body: ${message.notification?.body}');
        }
      });
      emit(
        state.copyWith(
          status: HomeStatus.listenFcmMessageSuccess,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          status: HomeStatus.listenFcmMessageFailure,
          errorMessage: e.toString(),
        ),
      );
    }

    emit(
      state.copyWith(
        status: HomeStatus.idle,
      ),
    );
  }
}
