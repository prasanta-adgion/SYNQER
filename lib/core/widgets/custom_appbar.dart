import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87, // Use your app's primary color here
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0.5, // Subtle shadow for a clean look
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
              onPressed: onBackTap ?? () => Navigator.pop(context),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
