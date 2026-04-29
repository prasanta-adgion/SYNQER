// lib/core/theme/theme_picker_sheet.dart

import 'package:flutter/material.dart';

import 'theme_controller.dart';
import 'theme_scope.dart';

/// Bottom sheet that lets the user pick Light / Dark / System.
class ThemePickerSheet extends StatelessWidget {
  const ThemePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ThemePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final controller = context.themeController;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Appearance',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose how Synqer looks to you',
              style: TextStyle(color: c.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),
            for (final mode in AppThemeMode.values)
              _ThemeOptionTile(
                mode: mode,
                selected: controller.mode == mode,
                onTap: () async {
                  await controller.setMode(mode);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final AppThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: selected ? c.primary.withOpacity(0.10) : c.surfaceHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? c.primary.withOpacity(0.45) : c.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  mode.icon,
                  color: selected ? c.primary : c.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    mode.label,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? c.primary : Colors.transparent,
                    border: Border.all(
                      color: selected ? c.primary : c.borderStrong,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? Icon(Icons.check, size: 14, color: c.onBrand)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
