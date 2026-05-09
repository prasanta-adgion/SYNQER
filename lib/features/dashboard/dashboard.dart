// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:synqer_io/core/model/navbar_item_model.dart';

import 'package:synqer_io/core/theme/app_colors.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/utils/app_configarations.dart';
import 'package:synqer_io/features/all_leads/leads_screen.dart';
import 'package:synqer_io/features/bulk_sms/bulk_sms_screen.dart';
import 'package:synqer_io/features/dashboard/widgets/header_section.dart';
import 'package:synqer_io/features/live_chat/live_conversions/live_convertsions_screen.dart';
import 'package:synqer_io/features/manage_contacts/contacts_screen.dart';
import 'package:synqer_io/features/rcs_messages/rcs_screen.dart';
import 'package:synqer_io/features/whatsapp/whatsapp_screen.dart';

class ActivityItem {
  final String title;
  final String time;
  final IconData icon;
  final bool isSuccess;
  const ActivityItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.isSuccess,
  });
}

// ────────────────
// MAIN SCREEN
// ────────────────

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _fabNotifier = ValueNotifier(false);

  @override
  void dispose() {
    _currentIndexNotifier.dispose();
    _fabNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,

      body: ValueListenableBuilder<bool>(
        valueListenable: _fabNotifier,

        builder: (context, fabOpen, _) {
          return Stack(
            children: [
              ValueListenableBuilder<int>(
                valueListenable: _currentIndexNotifier,
                builder: (context, currentIndex, _) =>
                    _pageForIndex(currentIndex),
              ),

              if (fabOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      _fabNotifier.value = false;
                    },

                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 4,
                        sigmaY: 4,
                        tileMode: TileMode.clamp,
                      ),

                      child: Container(
                        color: Colors.black.withOpacity(
                          context.isDark ? 0.25 : 0.08,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _fabNotifier,
        builder: (context, fabOpen, _) {
          return SpeedDial(
            openCloseDial: _fabNotifier,
            icon: Icons.speaker_notes_rounded,
            activeIcon: Icons.close_rounded,
            backgroundColor: c.primary,
            foregroundColor: c.onBrand,
            elevation: 6,
            spacing: 14,
            spaceBetweenChildren: 10,
            animationCurve: Curves.easeOutCubic,
            animationDuration: const Duration(milliseconds: 260),
            overlayColor: Colors.black,
            overlayOpacity: 0.35,
            childrenButtonSize: const Size(56, 56),
            buttonSize: const Size(60, 60),
            shape: const CircleBorder(),
            children: [
              _buildDialChild(
                context: context,
                c: c,
                serviceKey: 'bulk sms',
                label: 'Bulk SMS',
                subtitle: 'Send to multiple contacts',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BulkSmsScreen()),
                ),
              ),
              _buildDialChild(
                context: context,
                c: c,
                serviceKey: 'rcs',
                label: 'RCS',
                subtitle: 'Rich communication',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RcsScreen()),
                ),
              ),
              _buildDialChild(
                context: context,
                c: c,
                serviceKey: 'whatsapp',
                label: 'WhatsApp',
                subtitle: 'Business messaging',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WhatsAppScreen()),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(c),
    );
  }

  Widget _pageForIndex(int index) {
    return switch (index) {
      2 => const LiveConversionsScreen(),
      3 => const ContactsScreen(),
      _ => const DashboardPage(),
    };
  }

  SpeedDialChild _buildDialChild({
    required BuildContext context,
    required AppColors c,
    required String serviceKey,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final serviceColor = AppConfig.serviceColor(serviceKey);

    return SpeedDialChild(
      backgroundColor: Colors.transparent,
      elevation: 0,
      labelWidget: Container(
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: c.borderStrong, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                letterSpacing: 0.1,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: c.textPrimary.withOpacity(0.55),
                fontWeight: FontWeight.w400,
                fontSize: 11,
                letterSpacing: 0.1,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
      shape: const CircleBorder(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: serviceColor.withOpacity(0.08),

          shape: BoxShape.circle,
          border: Border.all(color: serviceColor, width: 1.2),
        ),
        child: Center(
          child: AppConfig.serviceIcon(
            serviceKey,
            size: 22,
            color: serviceColor,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildBottomNav(AppColors c) {
    const items = [
      NavbarItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
      NavbarItem(icon: Icons.people_outline_rounded, label: 'Leads'),
      NavbarItem(icon: Icons.trending_up_rounded, label: 'Conversions'),
      NavbarItem(icon: Icons.contacts_rounded, label: 'Contacts'),
    ];

    return SafeArea(
      child: ValueListenableBuilder<int>(
        valueListenable: _currentIndexNotifier,
        builder: (context, currentIndex, _) => Container(
          height: 68,
          decoration: BoxDecoration(
            color: c.surface,
            border: Border(top: BorderSide(color: c.border, width: 1)),
          ),
          child: Row(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isActive = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_fabNotifier.value) {
                      _fabNotifier.value = false;
                    }
                    if (item.label == 'Leads') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LeadsScreen()),
                      );
                      return;
                    }
                    _currentIndexNotifier.value = i;
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: isActive
                              ? c.primary.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isActive ? c.primary : Colors.transparent,
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          size: 21,
                          color: isActive ? c.primary : c.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: isActive ? c.primary : c.textSecondary,
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                          letterSpacing: 0.1,
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// class _NavItem {
//   final IconData icon;
//   final String label;
//   const _NavItem({required this.icon, required this.label});
// }

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}
// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;

  const _Card({required this.child, this.padding, this.margin, this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16),
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  const _SectionTitle({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          if (action != null)
            Text(
              action!,
              style: TextStyle(
                color: c.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD PAGE
// ─────────────────────────────────────────────────────────────────────────────

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderSection(title: 'Rajesh Kumar', subtitle: _greeting()),

          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('TOTAL SENT TODAY'),
                        const SizedBox(height: 6),
                        Text(
                          '2,418,340',
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              color: c.green,
                              size: 13,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '+14.2% from yesterday',
                              style: TextStyle(
                                color: c.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const _Label('DELIVERY RATE'),
                        const SizedBox(height: 6),
                        Text(
                          '98.1%',
                          style: TextStyle(
                            color: c.green,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const _LiveChip(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _SparklineChart(),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    _ChannelPill(label: 'SMS', value: '1.2M'),
                    SizedBox(width: 8),
                    _ChannelPill(label: 'RCS', value: '640K'),
                    SizedBox(width: 8),
                    _ChannelPill(label: 'WA', value: '580K'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const _SectionTitle(title: 'Services', action: 'View all'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _ServiceCard(
                    title: 'Bulk SMS',
                    value: '84,210',
                    sub: 'Sent Today',
                    icon: Icons.sms_rounded,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ServiceCard(
                    title: 'WhatsApp',
                    value: '1,284',
                    sub: 'Active Convos',
                    icon: CupertinoIcons.chat_bubble_text_fill,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const _SectionTitle(title: 'RCS Messaging'),
          _Card(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: c.border)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: c.surfaceHigh,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: c.border),
                        ),
                        child: Icon(
                          Icons.rss_feed_rounded,
                          color: c.textPrimary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'RCS Messaging',
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const _LiveChip(),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '640K',
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'sent today',
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.surfaceHigh,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RICH CARD PREVIEW',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [c.primary, c.secondary],
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Sale',
                                style: TextStyle(
                                  color: c.onBrand,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Flash Sale',
                                    style: TextStyle(
                                      color: c.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '50% off today only',
                                    style: TextStyle(
                                      color: c.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: const [
                            Expanded(
                              child: _RcsBtn(label: 'OPEN', filled: true),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _RcsBtn(label: 'SHARE', filled: false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const _SectionTitle(title: 'Live Activity', action: 'See all'),
          _Card(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: const [
                _ActivityTile(
                  item: ActivityItem(
                    title: 'Campaign «April Sale» sent',
                    time: '2m ago',
                    icon: Icons.send_rounded,
                    isSuccess: true,
                  ),
                ),
                _ActivityTile(
                  item: ActivityItem(
                    title: 'DLT template approved',
                    time: '14m ago',
                    icon: Icons.check_circle_outline_rounded,
                    isSuccess: true,
                  ),
                ),
                _ActivityTile(
                  item: ActivityItem(
                    title: 'Bulk SMS batch queued',
                    time: '28m ago',
                    icon: Icons.schedule_rounded,
                    isSuccess: false,
                  ),
                ),
                _ActivityTile(
                  item: ActivityItem(
                    title: 'WhatsApp opt-in received',
                    time: '1h ago',
                    icon: Icons.person_add_outlined,
                    isSuccess: true,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Text(
      text,
      style: TextStyle(
        color: c.textSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _LiveChip extends StatelessWidget {
  const _LiveChip();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.green.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 5,
            height: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(color: c.green, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Live',
            style: TextStyle(
              color: c.green,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelPill extends StatelessWidget {
  final String label;
  final String value;
  const _ChannelPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  final IconData icon;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.value,
    required this.sub,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: c.surfaceHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.border),
              ),
              child: Icon(icon, color: c.textPrimary, size: 16),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(color: c.textSecondary, fontSize: 11)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: c.surfaceHigh,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: c.border),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: c.textPrimary,
                    size: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RcsBtn extends StatelessWidget {
  final String label;
  final bool filled;
  const _RcsBtn({required this.label, required this.filled});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        gradient: filled
            ? LinearGradient(
                colors: [c.primary, c.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: filled ? null : Border.all(color: c.borderStrong),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: filled ? c.onBrand : c.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SparklineChart extends StatelessWidget {
  const _SparklineChart();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 44,
      child: CustomPaint(
        painter: _SparklinePainter(primary: c.primary),
        size: Size.infinite,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final Color primary;
  _SparklinePainter({required this.primary});

  @override
  void paint(Canvas canvas, Size size) {
    final pts = [0.38, 0.52, 0.44, 0.68, 0.58, 0.78, 0.62, 0.84, 0.72, 0.92];
    final path = Path();
    final fill = Path();

    for (int i = 0; i < pts.length; i++) {
      final x = i * size.width / (pts.length - 1);
      final y = size.height * (1 - pts[i]);
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        final px = (i - 1) * size.width / (pts.length - 1);
        final py = size.height * (1 - pts[i - 1]);
        final cx = (px + x) / 2;
        path.cubicTo(cx, py, cx, y, x, y);
        fill.cubicTo(cx, py, cx, y, x, y);
      }
    }
    fill.lineTo(size.width, size.height);
    fill.close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primary.withOpacity(0.25), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = primary
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.primary != primary;
}

class _ActivityTile extends StatelessWidget {
  final ActivityItem item;
  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = item.isSuccess ? c.green : c.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.border),
            ),
            child: Icon(item.icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            item.time,
            style: TextStyle(color: c.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
