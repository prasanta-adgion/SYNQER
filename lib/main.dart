import 'package:flutter/material.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/token_storage.dart';
import 'package:synqer_io/core/theme/theme_controller.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/features/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Theme Controller ─────────────────────────────
  final themeController = ThemeController();
  await themeController.load();

  // ── Auth Token ───────────────────────────────────
  final token = await TokenStorage.getToken();
  if (token != null) {
    AppInjector.dio.updateToken(token);
  }

  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;

  const MyApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: themeController,
      builder: (context, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Synqer',

          // ── Theme from ThemeScope ─────────────────
          theme: theme,

          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },

          home: const SplashScreen(),
        );
      },
    );
  }
}
