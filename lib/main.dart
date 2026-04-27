import 'package:flutter/material.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/token_storage.dart';
import 'package:synqer_io/features/user_login/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final token = await TokenStorage.getToken();

  if (token != null) {
    AppInjector.dio.updateToken(token);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Synqer',
      theme: ThemeData(fontFamily: 'Lato', useMaterial3: true),

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },

      home: LoginScreen(),
    );
  }
}
