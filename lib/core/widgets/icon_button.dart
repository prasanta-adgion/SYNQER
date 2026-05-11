import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';

class IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const IconBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: c.textSecondary),
        ),
      ),
    );
  }
}
