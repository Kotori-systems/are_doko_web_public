// import 'package:are_doko_web/screen/exchangers_test/exchangers_test.dart';
import 'package:are_doko_web/firebase_options.dart';
import 'package:are_doko_web/screen/home/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // イニシャライズ
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

    // カスタムdebugPrintを設定
  debugPrint = (String? message, {int? wrapWidth}) {
    // 特定のログを無視
    if (message != null && !message.contains('framework.dart')) {
      // 標準のdebugPrintを使用
      const defaultPrint = debugPrintThrottled;
      defaultPrint(message, wrapWidth: wrapWidth);
    }
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // エラー時に表示するWidget
        if (snapshot.hasError) {
          return Container(color: Colors.white);
        }

        // Firebaseのinitialize完了したら表示したいWidget
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.blue,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            // home: const ExchangersTest(),
            home: const HomePage(),
          );
        }

        // Firebaseのinitializeが完了するのを待つ間に表示するWidget
        return const CircularProgressIndicator();
      },
    );
  }
}
