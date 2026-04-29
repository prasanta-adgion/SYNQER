// lib/core/theme/theme_controller.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  light,
  dark,
  system;

  String get label => switch (this) {
    AppThemeMode.light => 'Light',
    AppThemeMode.dark => 'Dark',
    AppThemeMode.system => 'System',
  };

  IconData get icon => switch (this) {
    AppThemeMode.light => Icons.light_mode_rounded,
    AppThemeMode.dark => Icons.dark_mode_rounded,
    AppThemeMode.system => Icons.brightness_auto_rounded,
  };

  ThemeMode get materialThemeMode => switch (this) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
  };
}

/// Owns the user's theme preference and persists it.
///
/// Exposed via [ThemeScope] (an InheritedNotifier) so widgets can:
///   - read the current mode:        `ThemeScope.of(context).mode`
///   - toggle / change mode:         `ThemeScope.of(context).setMode(...)`
///   - get resolved colors anywhere: `context.colors`
class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'app_theme_mode_v1';

  AppThemeMode _mode = AppThemeMode.system;
  AppThemeMode get mode => _mode;

  bool _initialized = false;
  bool get initialized => _initialized;

  /// Call once during app startup before `runApp` to avoid a flash of the
  /// default theme on first frame.
  Future<void> load() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        _mode = AppThemeMode.values.firstWhere(
          (m) => m.name == raw,
          orElse: () => AppThemeMode.system,
        );
      }
    } catch (e) {
      debugPrint('ThemeController: failed to load preference: $e');
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> setMode(AppThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();

    // Fire-and-forget; persistence failure shouldn't break UI
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, mode.name);
    } catch (e) {
      debugPrint('ThemeController: failed to persist preference: $e');
    }
  }

  /// Cycle: system → light → dark → system
  Future<void> cycle() async {
    final next = switch (_mode) {
      AppThemeMode.system => AppThemeMode.light,
      AppThemeMode.light => AppThemeMode.dark,
      AppThemeMode.dark => AppThemeMode.system,
    };
    await setMode(next);
  }

  /// Resolve the effective brightness given the user's preference + system.
  Brightness resolveBrightness(Brightness platformBrightness) {
    return switch (_mode) {
      AppThemeMode.light => Brightness.light,
      AppThemeMode.dark => Brightness.dark,
      AppThemeMode.system => platformBrightness,
    };
  }
}
