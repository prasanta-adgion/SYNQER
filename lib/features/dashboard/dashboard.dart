// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messaging Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        fontFamily: 'SF Pro Display',
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xFF888888),
          surface: Color(0xFF141414),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// ─── Data Models ──────────────────────────────────────────────────────────────

class StatCard {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final double changePercent;

  const StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.changePercent,
  });
}

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

// ─── Main Screen ──────────────────────────────────────────────────────────────

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _fabOpen = false;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  final List<Widget> _pages = const [
    DashboardPage(),
    AllLeadsPage(),
    ConversionsPage(),
    ContactPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: _pages[_currentIndex],
      floatingActionButton: _buildFabMenu(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(child: _buildBottomNav()),
    );
  }

  Widget _buildFabMenu() {
    // Bulk SMS = blue, RCS = violet, WhatsApp = green (brand-accurate, professional)
    final fabItems = [
      {
        'icon': Icons.sms_rounded,
        'label': 'Bulk SMS',
        'iconColor': const Color(0xFF4FC3F7), // sky blue
        'bgColor': const Color(0xFF0D2033),
        'borderColor': const Color(0xFF4FC3F7),
      },
      {
        'icon': Icons.messenger_sharp,
        'label': 'RCS',
        'iconColor': const Color(0xFFB39DDB), // soft violet
        'bgColor': const Color(0xFF1A1030),
        'borderColor': const Color(0xFFB39DDB),
      },
      {
        'icon': CupertinoIcons.chat_bubble_text_fill,
        'label': 'WhatsApp',
        'iconColor': const Color(0xFF66BB6A), // WhatsApp green
        'bgColor': const Color(0xFF0D2010),
        'borderColor': const Color(0xFF66BB6A),
      },
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Sub FAB items
        ...fabItems
            .asMap()
            .entries
            .map((entry) {
              final i = entry.key;
              final item = entry.value;
              return AnimatedBuilder(
                animation: _fabAnimation,
                builder: (context, child) {
                  final delay = i * 0.15;
                  final adjustedValue = math.max(
                    0.0,
                    math.min(1.0, (_fabAnimation.value - delay) / (1 - delay)),
                  );
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - adjustedValue)),
                    child: Opacity(opacity: adjustedValue, child: child),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          item['label'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _SubFabButton(
                        icon: item['icon'] as IconData,
                        iconColor: item['iconColor'] as Color,
                        bgColor: item['bgColor'] as Color,
                        borderColor: item['borderColor'] as Color,
                        onTap: () {
                          _toggleFab();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item['label']} selected'),
                              backgroundColor: const Color(0xFF1E1E1E),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            })
            .toList()
            .reversed
            .toList(),

        // Main FAB
        GestureDetector(
          onTap: _toggleFab,
          child: AnimatedBuilder(
            animation: _fabAnimation,
            builder: (context, child) => Transform.rotate(
              angle: _fabAnimation.value * math.pi * 0.75,
              child: child,
            ),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    const navItems = [
      {
        'icon': Icons.dashboard_outlined,
        'activeIcon': Icons.dashboard_rounded,
        'label': 'Dashboard',
      },
      {
        'icon': Icons.people_outline_rounded,
        'activeIcon': Icons.people_rounded,
        'label': 'All Leads',
      },
      {
        'icon': Icons.trending_up_rounded,
        'activeIcon': Icons.trending_up_rounded,
        'label': 'Conversions',
      },
      {
        'icon': Icons.contacts_outlined,
        'activeIcon': Icons.contacts_rounded,
        'label': 'Contact',
      },
    ];

    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: navItems.asMap().entries.map((entry) {
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isActive
                            ? item['activeIcon'] as IconData
                            : item['icon'] as IconData,
                        key: ValueKey(isActive),
                        color: isActive ? Colors.white : Colors.white38,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white38,
                        fontSize: 10.5,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isActive ? 18 : 0,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Sub FAB Button ───────────────────────────────────────────────────────────

class _SubFabButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _SubFabButton({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.25),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

// ─── Shared AppBar ─────────────────────────────────────────────────────────────

class DashboardAppBar extends StatelessWidget {
  final String greeting;
  final String userName;

  const DashboardAppBar({
    super.key,
    required this.greeting,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1E1E1E),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning 👋';
  if (hour < 17) return 'Good Afternoon 👋';
  return 'Good Evening 👋';
}

// ─── Dashboard Page ───────────────────────────────────────────────────────────

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardAppBar(greeting: _getGreeting(), userName: 'Rajesh Kumar'),
          const _TotalSentCard(),
          const SizedBox(height: 16),
          const _ChannelBreakdownRow(),
          const SizedBox(height: 16),
          const _ServiceCardsRow(),
          const SizedBox(height: 16),
          const _RCSPreviewCard(),
          const SizedBox(height: 16),
          const _LiveActivitySection(),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class _TotalSentCard extends StatelessWidget {
  const _TotalSentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL SENT TODAY',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Delivery Rate',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  const Text(
                    '98.1%',
                    style: TextStyle(
                      color: Color(0xFF66BB6A), // green = positive
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.arrow_upward_rounded,
                        color: Color(0xFF66BB6A),
                        size: 11,
                      ),
                      const Text(
                        '+0.4%',
                        style: TextStyle(
                          color: Color(0xFF66BB6A),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '2.4M',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Live · Updated just now',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SparklineChart(),
        ],
      ),
    );
  }
}

class _SparklineChart extends StatelessWidget {
  const _SparklineChart();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: CustomPaint(
        painter: _SparklinePainter(),
        size: Size(MediaQuery.of(context).size.width - 72, 50),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [0.4, 0.55, 0.45, 0.7, 0.6, 0.8, 0.65, 0.85, 0.75, 0.9];
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < points.length; i++) {
      final x = i * size.width / (points.length - 1);
      final y = size.height * (1 - points[i]);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * size.width / (points.length - 1);
        final prevY = size.height * (1 - points[i - 1]);
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withOpacity(0.12), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChannelBreakdownRow extends StatelessWidget {
  const _ChannelBreakdownRow();

  @override
  Widget build(BuildContext context) {
    const channels = [
      {'label': 'SMS', 'value': '1.2M', 'color': 0xFFFFFFFF},
      {'label': 'RCS', 'value': '640K', 'color': 0xFFBBBBBB},
      {'label': 'WA', 'value': '580K', 'color': 0xFF888888},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: channels.map((c) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Text(
                    c['label'] as String,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c['value'] as String,
                    style: TextStyle(
                      color: Color(c['color'] as int),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ServiceCardsRow extends StatelessWidget {
  const _ServiceCardsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _ServiceCard(
              title: 'Bulk SMS',
              value: '84,210',
              subtitle: 'Sent Today',
              statusLabel: 'Active',
              statusDot: Colors.white,
              actionLabel: 'Quick Send',
              icon: Icons.sms_outlined,
              onAction: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ServiceCard(
              title: 'WhatsApp',
              value: '1,284',
              subtitle: 'Active Convos',
              statusLabel: 'Healthy',
              statusDot: Colors.white,
              actionLabel: 'New Message',
              icon: Icons.chat_bubble_outline_rounded,
              onAction: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String statusLabel;
  final Color statusDot;
  final String actionLabel;
  final IconData icon;
  final VoidCallback onAction;

  const _ServiceCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.statusLabel,
    required this.statusDot,
    required this.actionLabel,
    required this.icon,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white54, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusDot,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                statusLabel,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onAction,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                actionLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RCSPreviewCard extends StatelessWidget {
  const _RCSPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.rss_feed_rounded,
                    color: Colors.white60,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'RCS Messaging',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Live',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    '640K',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'sent today',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RICH CARD PREVIEW',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Sale',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Flash',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '50% off today only',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'OPEN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'SHARE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveActivitySection extends StatelessWidget {
  const _LiveActivitySection();

  @override
  Widget build(BuildContext context) {
    const activities = [
      ActivityItem(
        title: 'Campaign «April Sale» sent',
        time: '2m ago',
        icon: Icons.send_rounded,
        isSuccess: true,
      ),
      ActivityItem(
        title: 'DLT template approved',
        time: '14m ago',
        icon: Icons.check_circle_outline_rounded,
        isSuccess: true,
      ),
      ActivityItem(
        title: 'Bulk SMS batch queued',
        time: '28m ago',
        icon: Icons.schedule_rounded,
        isSuccess: false,
      ),
      ActivityItem(
        title: 'WhatsApp opt-in received',
        time: '1h ago',
        icon: Icons.person_add_outlined,
        isSuccess: true,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Text(
                  'Live Activity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 8),
                _LiveDot(),
              ],
            ),
          ),
          ...activities.map((a) => _ActivityTile(item: a)).toList(),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4 + _a.value * 0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityItem item;

  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final iconColor = item.isSuccess
        ? const Color(0xFF66BB6A) // green
        : const Color(0xFFFFA726); // amber/orange for pending
    final iconBg = item.isSuccess
        ? const Color(0xFF0D2010)
        : const Color(0xFF231A05);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: iconColor.withOpacity(0.25)),
            ),
            child: Icon(item.icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Text(
            item.time,
            style: const TextStyle(color: Colors.white30, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─── All Leads Page ────────────────────────────────────────────────────────────

class AllLeadsPage extends StatelessWidget {
  const AllLeadsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        DashboardAppBar(greeting: _getGreeting(), userName: 'Rajesh Kumar'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Row(
              children: [
                Icon(Icons.search_rounded, color: Colors.white38, size: 20),
                SizedBox(width: 10),
                Text(
                  'Search leads...',
                  style: TextStyle(color: Colors.white30, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: leads.length,
            itemBuilder: (ctx, i) {
              final l = leads[i];
              final tagColor = l['tag'] == 'Hot'
                  ? const Color(0xFFEF5350) // red
                  : l['tag'] == 'Warm'
                  ? const Color(0xFFFFA726) // amber
                  : const Color(0xFF4FC3F7); // cold blue
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF222222),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Center(
                        child: Text(
                          (l['name'] as String)[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            l['phone']!,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: tagColor.withOpacity(0.12),
                            border: Border.all(
                              color: tagColor.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l['tag']!,
                            style: TextStyle(
                              color: tagColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l['time']!,
                          style: const TextStyle(
                            color: Colors.white30,
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

// ─── Conversions Page ──────────────────────────────────────────────────────────

class ConversionsPage extends StatelessWidget {
  const ConversionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const metrics = [
      {'label': 'Total Leads', 'value': '12,480', 'change': '+8.2%'},
      {'label': 'Converted', 'value': '3,641', 'change': '+12.1%'},
      {'label': 'Conv. Rate', 'value': '29.2%', 'change': '+3.4%'},
      {'label': 'Avg. Time', 'value': '3.4d', 'change': '-0.5d'},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardAppBar(greeting: _getGreeting(), userName: 'Rajesh Kumar'),
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: metrics.length,
            itemBuilder: (ctx, i) {
              final m = metrics[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      m['label']!,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      m['value']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      m['change']!,
                      style: TextStyle(
                        color: (m['change'] as String).startsWith('+')
                            ? const Color(0xFF66BB6A)
                            : const Color(0xFFEF5350),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Funnel Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _FunnelBar(
                  label: 'Reached',
                  value: 1.0,
                  count: '12,480',
                  barColor: const Color(0xFF4FC3F7),
                ),
                const SizedBox(height: 8),
                _FunnelBar(
                  label: 'Opened',
                  value: 0.68,
                  count: '8,486',
                  barColor: const Color(0xFF66BB6A),
                ),
                const SizedBox(height: 8),
                _FunnelBar(
                  label: 'Clicked',
                  value: 0.41,
                  count: '5,117',
                  barColor: const Color(0xFFFFA726),
                ),
                const SizedBox(height: 8),
                _FunnelBar(
                  label: 'Converted',
                  value: 0.29,
                  count: '3,641',
                  barColor: const Color(0xFFEF5350),
                ),
              ],
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class _FunnelBar extends StatelessWidget {
  final String label;
  final double value;
  final String count;
  final Color barColor;

  const _FunnelBar({
    required this.label,
    required this.value,
    required this.count,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: barColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
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
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contact Page ─────────────────────────────────────────────────────────────

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        DashboardAppBar(greeting: _getGreeting(), userName: 'Rajesh Kumar'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: Colors.white38,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Search contacts...',
                        style: TextStyle(color: Colors.white30, fontSize: 14),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.filter_list_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: contacts.length,
            itemBuilder: (ctx, i) {
              final c = contacts[i];
              final groupColor = c['group'] == 'VIP'
                  ? const Color(0xFFFFD54F) // gold
                  : c['group'] == 'Retail'
                  ? const Color(0xFF4FC3F7) // blue
                  : const Color(0xFFB39DDB); // violet for B2B
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF222222),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (c['name'] as String)[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
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
                            c['name']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            c['phone']!,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: groupColor.withOpacity(0.12),
                        border: Border.all(color: groupColor.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        c['group']!,
                        style: TextStyle(
                          color: groupColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white24,
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
