import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/app_colors.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;

  final VoidCallback? onBack;

  final Widget? trailing;

  final Color? backgroundColor;

  final Color? titleColor;
  final Color? subtitleColor;

  final bool showBackButton;

  final double elevation;

  const CustomAppBar({
    super.key,

    this.title,
    this.subtitle,

    this.onBack,

    this.trailing,

    this.backgroundColor,

    this.titleColor,
    this.subtitleColor,

    this.showBackButton = true,

    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppBar(
      automaticallyImplyLeading: false,

      elevation: elevation,

      scrolledUnderElevation: 0,

      backgroundColor: backgroundColor ?? c.surface,

      toolbarHeight: 72,

      titleSpacing: 16,

      title: Row(
        children: [
          if (showBackButton) ...[
            _GlassBtn(
              icon: Icons.arrow_back_ios_new_rounded,

              c: c,

              onTap: (_) {
                if (onBack != null) {
                  onBack!();
                } else {
                  Navigator.pop(context);
                }
              },
            ),

            const SizedBox(width: 12),
          ],

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title ?? '',

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    // fontSize: 20,
                    // fontWeight: FontWeight.w700,

                    // color: titleColor ?? c.textPrimary,

                    // letterSpacing: -0.4,
                    color: titleColor ?? c.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (subtitle != null) ...[
                  const SizedBox(height: 2),

                  Text(
                    subtitle!,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 12,

                      color: subtitleColor ?? c.textSecondary,

                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: c.border),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _GlassBtn extends StatelessWidget {
  final IconData icon;

  // FIXED
  final Function(BuildContext buttonContext) onTap;

  final AppColors c;

  const _GlassBtn({required this.icon, required this.onTap, required this.c});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (buttonContext) {
        return GestureDetector(
          onTap: () => onTap(buttonContext),

          child: Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: c.surface,

              borderRadius: BorderRadius.circular(10),

              border: Border.all(color: c.border),
            ),

            child: Icon(icon, color: c.textSecondary, size: 17),
          ),
        );
      },
    );
  }
}
