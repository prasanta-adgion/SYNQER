import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_picker_sheet.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final controller = context.themeController;

    return GestureDetector(
      onTap: controller.cycle,
      onLongPress: () => ThemePickerSheet.show(context),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: c.surface,
          shape: BoxShape.circle,
          border: Border.all(color: c.border),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            controller.mode.icon,
            key: ValueKey(controller.mode),
            color: c.textSecondary,
            size: 18,
          ),
        ),
      ),
    );
  }
}
