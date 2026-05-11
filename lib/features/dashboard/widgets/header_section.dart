import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/theme_toggle_button.dart';
import 'package:synqer_io/features/profile/profile_screen.dart';

class HeaderSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const HeaderSection({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // ── Theme toggle ────────────────────────────────────────────────
          ThemeToggleButton(),
          // const SizedBox(width: 10),
          // const _IconBtn(icon: Icons.notifications_none_rounded, badge: true),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [c.primary, c.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: c.border, width: 2),
              ),
              child: Center(
                child: Text(
                  'R',
                  style: TextStyle(
                    color: c.onBrand,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
