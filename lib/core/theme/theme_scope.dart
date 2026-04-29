// lib/core/theme/theme_scope.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'theme_controller.dart';

/// Wraps the app and exposes [ThemeController] + resolved [AppColors] via
/// [BuildContext]. Rebuilds dependents only when the theme actually changes.
class ThemeScope extends StatefulWidget {
  final ThemeController controller;
  final Widget Function(BuildContext context, ThemeData theme) builder;

  const ThemeScope({
    super.key,
    required this.controller,
    required this.builder,
  });

  /// Reads the controller and triggers rebuilds on theme changes.
  static _ThemeScopeData of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_ThemeScopeInherited>();
    assert(scope != null, 'ThemeScope.of() called with no ThemeScope above');
    return scope!.data;
  }

  /// Same as [of] but does NOT subscribe to rebuilds. Use in callbacks.
  static _ThemeScopeData read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<_ThemeScopeInherited>();
    assert(scope != null, 'ThemeScope.read() called with no ThemeScope above');
    return scope!.data;
  }

  @override
  State<ThemeScope> createState() => _ThemeScopeState();
}

class _ThemeScopeState extends State<ThemeScope> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  /// Picks up live OS theme changes when the user is on `system` mode.
  @override
  void didChangePlatformBrightness() {
    if (widget.controller.mode == AppThemeMode.system && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final effectiveBrightness = widget.controller.resolveBrightness(
      platformBrightness,
    );
    final isDark = effectiveBrightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    // Keep system bars in sync with the active theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: colors.bg,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    final theme = _buildThemeData(colors, isDark);

    final data = _ThemeScopeData(
      controller: widget.controller,
      colors: colors,
      isDark: isDark,
    );

    return _ThemeScopeInherited(
      data: data,
      child: Builder(
        builder: (innerContext) => widget.builder(innerContext, theme),
      ),
    );
  }

  ThemeData _buildThemeData(AppColors c, bool isDark) {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: c.bg,
      fontFamily: 'SF Pro Display',
      colorScheme:
          (isDark ? const ColorScheme.dark() : const ColorScheme.light())
              .copyWith(
                primary: c.primary,
                secondary: c.secondary,
                surface: c.surface,
                error: c.error,
              ),
    );
  }
}

class _ThemeScopeData {
  final ThemeController controller;
  final AppColors colors;
  final bool isDark;

  const _ThemeScopeData({
    required this.controller,
    required this.colors,
    required this.isDark,
  });
}

class _ThemeScopeInherited extends InheritedWidget {
  final _ThemeScopeData data;

  const _ThemeScopeInherited({required this.data, required super.child});

  @override
  bool updateShouldNotify(_ThemeScopeInherited oldWidget) {
    // Compare the cheap, stable fields. AppColors is immutable per theme.
    return oldWidget.data.isDark != data.isDark ||
        oldWidget.data.controller != data.controller;
  }
}

/// Ergonomic accessors. Lets you write `context.colors.primary` everywhere.
extension ThemeContextX on BuildContext {
  AppColors get colors => ThemeScope.of(this).colors;
  bool get isDark => ThemeScope.of(this).isDark;
  ThemeController get themeController => ThemeScope.of(this).controller;
}
