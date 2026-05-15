import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';

class RcsTemplateEmpty extends StatelessWidget {
  const RcsTemplateEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              shape: BoxShape.circle,
              border: Border.all(color: c.border),
            ),
            child: Icon(
              Icons.description_outlined,
              color: c.textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No templates yet',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Approved RCS templates will appear here once they are created.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
