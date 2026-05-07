import 'package:flutter/material.dart';

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
    return AppBar(
      automaticallyImplyLeading: false,

      elevation: elevation,

      scrolledUnderElevation: 0,

      backgroundColor: backgroundColor ?? Colors.white,

      toolbarHeight: 72,

      titleSpacing: 16,

      title: Row(
        children: [
          if (showBackButton) ...[
            _HeaderIconButton(
              icon: Icons.arrow_back_ios_new_rounded,

              onTap: onBack ?? () => Navigator.pop(context),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: titleColor ?? const Color(0xFF0F172A),

                    letterSpacing: -0.4,
                  ),
                ),

                if (subtitle != null) ...[
                  const SizedBox(height: 2),

                  Text(
                    subtitle!,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 12.5,

                      color: subtitleColor ?? const Color(0xFF64748B),

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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),

        side: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(12),

        child: SizedBox(
          width: 40,
          height: 40,

          child: Icon(icon, size: 18, color: const Color(0xFF334155)),
        ),
      ),
    );
  }
}
