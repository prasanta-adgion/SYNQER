// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:synqer_io/core/theme/app_colors.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/features/dashboard/widgets/header_section.dart';
import 'package:synqer_io/features/live_chat/live_conversions/live_convertsions_screen.dart';

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

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _fabOpen = false;
  late final AnimationController _fabController;
  late final Animation<double> _fabAnimation;

  final List<Widget> _pages = const [
    DashboardPage(),
    AllLeadsPage(),
    // ConversionsPage(),
    LiveConversionsScreen(),
    ContactPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _fabOpen = !_fabOpen;
      _fabOpen ? _fabController.forward() : _fabController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: _pages[_currentIndex],
      floatingActionButton: _buildFab(c),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(c),
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────────────

  Widget _buildFab(AppColors c) {
    final items = const [
      _FabItem(icon: Icons.sms_rounded, label: 'Bulk SMS'),
      _FabItem(icon: Icons.messenger_sharp, label: 'RCS'),
      _FabItem(icon: CupertinoIcons.chat_bubble_text_fill, label: 'WhatsApp'),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...items
            .asMap()
            .entries
            .map((entry) {
              final i = entry.key;
              final item = entry.value;
              return AnimatedBuilder(
                animation: _fabAnimation,
                builder: (context, child) {
                  final delay = i * 0.18;
                  final v = math.max(
                    0.0,
                    math.min(1.0, (_fabAnimation.value - delay) / (1 - delay)),
                  );
                  return Transform.translate(
                    offset: Offset(0, 16 * (1 - v)),
                    child: Opacity(opacity: v, child: child),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: c.surfaceHigh,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: c.border),
                        ),
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          _toggleFab();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.label} selected'),
                              backgroundColor: c.surfaceHigh,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: c.surfaceHigh,
                            shape: BoxShape.circle,
                            border: Border.all(color: c.borderStrong),
                          ),
                          child: Icon(
                            item.icon,
                            color: c.textPrimary,
                            size: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })
            .toList()
            .reversed,

        GestureDetector(
          onTap: _toggleFab,
          child: AnimatedBuilder(
            animation: _fabAnimation,
            builder: (_, child) => Transform.rotate(
              angle: _fabAnimation.value * math.pi * 0.75,
              child: child,
            ),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [c.primary, c.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(Icons.add_rounded, color: c.onBrand, size: 26),
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────

  Widget _buildBottomNav(AppColors c) {
    const items = [
      _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
      _NavItem(icon: Icons.people_outline_rounded, label: 'Leads'),
      _NavItem(icon: Icons.trending_up_rounded, label: 'Conversions'),
      _NavItem(icon: Icons.contacts_rounded, label: 'Contacts'),
    ];

    return SafeArea(
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.border, width: 1)),
        ),
        child: Row(
          children: items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isActive = _currentIndex == i;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_fabOpen) _toggleFab();
                  setState(() => _currentIndex = i);
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
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _FabItem {
  final IconData icon;
  final String label;
  const _FabItem({required this.icon, required this.label});
}

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

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
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

// ─────────────────────────────────────────────────────────────────────────────
// ALL LEADS PAGE
// ─────────────────────────────────────────────────────────────────────────────

class AllLeadsPage extends StatelessWidget {
  const AllLeadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    const leads = [
      {
        'name': 'Ananya Sharma',
        'phone': '+91 98765 43210',
        'tag': 'Hot',
        'time': '2h ago',
      },
      {
        'name': 'Rohan Verma',
        'phone': '+91 87654 32109',
        'tag': 'Warm',
        'time': '5h ago',
      },
      {
        'name': 'Priya Nair',
        'phone': '+91 76543 21098',
        'tag': 'Cold',
        'time': '1d ago',
      },
      {
        'name': 'Karan Mehta',
        'phone': '+91 65432 10987',
        'tag': 'Hot',
        'time': '1d ago',
      },
      {
        'name': 'Sneha Iyer',
        'phone': '+91 54321 09876',
        'tag': 'Warm',
        'time': '2d ago',
      },
      {
        'name': 'Amit Patel',
        'phone': '+91 43210 98765',
        'tag': 'Cold',
        'time': '3d ago',
      },
    ];

    return Column(
      children: [
        HeaderSection(
          title: 'All Leads',
          subtitle: '${leads.length} total contacts',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: c.textSecondary, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Search leads...',
                  style: TextStyle(color: c.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 34,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: const [
              _FilterChip(label: 'All', selected: true),
              _FilterChip(label: 'Hot'),
              _FilterChip(label: 'Warm'),
              _FilterChip(label: 'Cold'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: leads.length,
            itemBuilder: (ctx, i) {
              final l = leads[i];
              final tagColor = l['tag'] == 'Hot'
                  ? c.error
                  : l['tag'] == 'Warm'
                  ? c.primary
                  : c.textSecondary;
              return Container(
                margin: const EdgeInsets.only(bottom: 9),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c.surfaceHigh,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.border),
                      ),
                      child: Center(
                        child: Text(
                          (l['name'] as String)[0],
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l['name']!,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l['phone']!,
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Badge(label: l['tag']!, color: tagColor),
                        const SizedBox(height: 5),
                        Text(
                          l['time']!,
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _FilterChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? c.primary : c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? c.primary : c.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? c.onBrand : c.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONVERSIONS PAGE
// ─────────────────────────────────────────────────────────────────────────────

class ConversionsPage extends StatelessWidget {
  const ConversionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    const metrics = [
      {
        'label': 'Total Leads',
        'value': '12,480',
        'change': '+8.2%',
        'up': true,
      },
      {'label': 'Converted', 'value': '3,641', 'change': '+12.1%', 'up': true},
      {'label': 'Conv. Rate', 'value': '29.2%', 'change': '+3.4%', 'up': true},
      {'label': 'Avg. Time', 'value': '3.4d', 'change': '-0.5d', 'up': false},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderSection(title: 'Conversions', subtitle: 'Performance overview'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
              ),
              itemCount: metrics.length,
              itemBuilder: (ctx, i) {
                final m = metrics[i];
                final isUp = m['up'] as bool;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        m['label'] as String,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        m['value'] as String,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            isUp
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: isUp ? c.green : c.error,
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            m['change'] as String,
                            style: TextStyle(
                              color: isUp ? c.green : c.error,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),
          const _SectionTitle(title: 'Conversion Funnel'),

          _Card(
            child: Column(
              children: [
                _FunnelBar(
                  label: 'Reached',
                  value: 1.0,
                  count: '12,480',
                  color: c.textPrimary,
                ),
                const SizedBox(height: 10),
                _FunnelBar(
                  label: 'Opened',
                  value: 0.68,
                  count: '8,486',
                  color: c.green,
                ),
                const SizedBox(height: 10),
                _FunnelBar(
                  label: 'Clicked',
                  value: 0.41,
                  count: '5,117',
                  color: c.secondary,
                ),
                const SizedBox(height: 10),
                _FunnelBar(
                  label: 'Converted',
                  value: 0.29,
                  count: '3,641',
                  color: c.primary,
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

class _FunnelBar extends StatelessWidget {
  final String label;
  final double value;
  final String count;
  final Color color;

  const _FunnelBar({
    required this.label,
    required this.value,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              count,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: c.surfaceHigh,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTACTS PAGE
// ─────────────────────────────────────────────────────────────────────────────

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    const contacts = [
      {'name': 'Ananya Sharma', 'phone': '+91 98765 43210', 'group': 'VIP'},
      {'name': 'Rohan Verma', 'phone': '+91 87654 32109', 'group': 'Retail'},
      {'name': 'Priya Nair', 'phone': '+91 76543 21098', 'group': 'B2B'},
      {'name': 'Karan Mehta', 'phone': '+91 65432 10987', 'group': 'VIP'},
      {'name': 'Sneha Iyer', 'phone': '+91 54321 09876', 'group': 'Retail'},
      {'name': 'Amit Patel', 'phone': '+91 43210 98765', 'group': 'B2B'},
      {'name': 'Deepa Rao', 'phone': '+91 32109 87654', 'group': 'VIP'},
    ];

    return Column(
      children: [
        HeaderSection(
          title: 'Contacts',
          subtitle: '${contacts.length} contacts',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: c.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Search contacts...',
                        style: TextStyle(color: c.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [c.primary, c.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.filter_list_rounded,
                  color: c.onBrand,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: contacts.length,
            itemBuilder: (ctx, i) {
              final contact = contacts[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 9),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c.surfaceHigh,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.border),
                      ),
                      child: Center(
                        child: Text(
                          (contact['name'] as String)[0],
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact['name']!,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            contact['phone']!,
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: c.surfaceHigh,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: c.border),
                      ),
                      child: Text(
                        contact['group']!,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: c.textMuted,
                      size: 18,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
