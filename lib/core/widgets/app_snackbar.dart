import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import '../theme/app_colors.dart';

enum SnackbarType { success, error, info }

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
  }) {
    final Color bgColor;
    final IconData icon;

    switch (type) {
      case SnackbarType.success:
        bgColor = context.colors.green;
        icon = Icons.check_circle_outline;
        break;

      case SnackbarType.error:
        bgColor = context.colors.error;
        icon = Icons.error_outline;
        break;

      case SnackbarType.info:
        bgColor = context.colors.info;
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        backgroundColor: bgColor,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
