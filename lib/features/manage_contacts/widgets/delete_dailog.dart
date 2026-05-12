import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/app_custom_button.dart';

class DeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final ValueListenable<bool>? isLoading;
  final VoidCallback onConfirm;

  const DeleteDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    this.isLoading,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5, tileMode: TileMode.clamp),
      child: Dialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
          side: BorderSide(color: c.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: c.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      bgColor: c.surfaceHigh,
                      textColor: c.textSecondary,
                      borderWidth: 1,
                      borderColor: c.border,
                      borderRadius: 35,
                      btnHeight: 45,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: isLoading == null
                        ? _ConfirmButton(
                            label: confirmLabel,
                            color: confirmColor,
                            onConfirm: onConfirm,
                          )
                        : ValueListenableBuilder<bool>(
                            valueListenable: isLoading!,
                            builder: (context, loading, _) => _ConfirmButton(
                              label: loading ? 'Deleting...' : confirmLabel,
                              color: confirmColor,
                              loading: loading,
                              onConfirm: loading ? null : onConfirm,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback? onConfirm;

  const _ConfirmButton({
    required this.label,
    required this.color,
    required this.onConfirm,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: label,
      onPressed: onConfirm,
      loading: loading,
      loaderColor: color,
      bgColor: color.withOpacity(0.15),
      textColor: color,
      borderWidth: 1,
      borderColor: color.withOpacity(0.4),
      borderRadius: 35,
      btnHeight: 45,
    );
  }
}
