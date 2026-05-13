import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';

class EmptyView extends StatelessWidget {
  final String title, subtitle;
  final Widget iconWidget;
  const EmptyView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'No leads match your current filters.\nTry adjusting the search or filter options.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
