// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:synqer_io/core/theme/app_colors.dart';

// ─── Paste your real AppColors / ThemeScope imports here ─────────────────────
// import 'package:your_app/core/theme/app_colors.dart';
// import 'package:your_app/core/theme/theme_scope.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const _DemoApp());
}

class _DemoApp extends StatelessWidget {
  const _DemoApp();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.dark.bg,
      fontFamily: 'SF Pro Display',
      colorScheme: const ColorScheme.dark().copyWith(
        primary: Color(0xFF301BF3),
        secondary: Color(0xFF5E4AE5),
      ),
    ),
    home: const ProfileScreen(),
  );
}

// // ─── Inline AppColors (remove if importing from your package) ─────────────────
// class AppColors {
//   final Color primary, secondary, green, error, info;
//   final Color bg, surface, surfaceHigh;
//   final Color border, borderStrong;
//   final Color textPrimary, textSecondary, textMuted, onBrand;

//   const AppColors({
//     required this.primary,
//     required this.secondary,
//     required this.green,
//     required this.error,
//     required this.info,
//     required this.bg,
//     required this.surface,
//     required this.surfaceHigh,
//     required this.border,
//     required this.borderStrong,
//     required this.textPrimary,
//     required this.textSecondary,
//     required this.textMuted,
//     required this.onBrand,
//   });

//   static final AppColors dark = AppColors(
//     primary: const Color(0xFF301BF3),
//     secondary: const Color(0xFF5E4AE5),
//     green: const Color(0xFF27AE60),
//     error: Colors.redAccent,
//     info: const Color(0xFF413D81),
//     bg: const Color(0xFF000000),
//     surface: const Color(0xFF0A0A0A),
//     surfaceHigh: const Color(0xFF141414),
//     border: Colors.white.withOpacity(0.08),
//     borderStrong: Colors.white.withOpacity(0.14),
//     textPrimary: const Color(0xFFEFF3FF),
//     textSecondary: Colors.white.withOpacity(0.55),
//     textMuted: Colors.white.withOpacity(0.25),
//     onBrand: Colors.white,
//   );
// }

// ─── Data Models ──────────────────────────────────────────────────────────────
class _ServiceItem {
  final String name, latency, status;
  const _ServiceItem(this.name, this.latency, this.status);
}

class _PricingRow {
  final String channel, type, unit, bulk, intl, sla;
  final bool dlt;
  const _PricingRow(
    this.channel,
    this.type,
    this.unit,
    this.bulk,
    this.intl,
    this.sla,
    this.dlt,
  );
}

// ─── Profile Screen ───────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final AppColors c = AppColors.dark;
  late final AnimationController _headerCtrl;
  late final AnimationController _pulseCtrl;

  final _services = const [
    _ServiceItem('SMS Gateway', '98.9ms', 'active'),
    _ServiceItem('WhatsApp BSP', '112ms', 'active'),
    _ServiceItem('AI Chatbot', '44ms', 'active'),
    _ServiceItem('RCS Messaging', '310ms', 'degraded'),
    _ServiceItem('Push Notify', '67ms', 'active'),
    _ServiceItem('Email Service', '—', 'down'),
  ];

  final _pricing = const [
    _PricingRow('SMS', 'Transactional', '₹0.40', '₹0.32', '₹2.80', '~3s', true),
    _PricingRow('SMS', 'Promotional', '₹0.25', '₹0.18', '₹2.20', '~8s', true),
    _PricingRow('WhatsApp', 'Utility', '₹0.58', '₹0.47', '₹3.50', '~2s', false),
    _PricingRow(
      'WhatsApp',
      'Marketing',
      '₹0.85',
      '₹0.70',
      '₹5.20',
      '~5s',
      false,
    ),
    _PricingRow('RCS', 'A2P Business', '₹1.10', '₹0.88', '—', '~6s', false),
    _PricingRow('Push', 'FCM / APNs', '₹0.08', '₹0.05', '₹0.12', '~1s', false),
  ];

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF000000),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: c.bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _buildStatRow(),
                  const SizedBox(height: 16),
                  _buildDltCard(),
                  const SizedBox(height: 14),
                  _buildAiChatbotCard(),
                  const SizedBox(height: 14),
                  _buildServiceStatus(),
                  const SizedBox(height: 14),
                  _buildPricingSection(),
                  const SizedBox(height: 14),
                  _buildAccountDetails(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sliver App Bar ──────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: c.bg,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _GlassButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () {},
          colors: c,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: _GlassButton(
            icon: Icons.edit_outlined,
            onTap: () {},
            colors: c,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: _GlassButton(
            icon: Icons.more_vert_rounded,
            onTap: () {},
            colors: c,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _buildProfileHeader(),
      ),
    );
  }

  // ── Profile Header ──────────────────────────────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(color: c.bg),
      child: Stack(
        children: [
          // background glow
          Positioned(
            top: -40,
            right: -40,
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      c.primary.withOpacity(0.15 + 0.06 * _pulseCtrl.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [c.secondary.withOpacity(0.10), Colors.transparent],
                ),
              ),
            ),
          ),
          // content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [c.primary, c.secondary],
                          ),
                          border: Border.all(color: c.borderStrong, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: c.primary.withOpacity(0.35),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'AK',
                            style: TextStyle(
                              color: c.onBrand,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arjun Kumar',
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'arjun.kumar@msgplatform.in',
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 12,
                                fontFamily: 'Courier',
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Status pulse
                            AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (_, __) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: c.green.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: c.green.withOpacity(
                                      0.25 + 0.1 * _pulseCtrl.value,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: c.green,
                                        boxShadow: [
                                          BoxShadow(
                                            color: c.green.withOpacity(
                                              0.4 + 0.3 * _pulseCtrl.value,
                                            ),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        color: c.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.12,
                                        fontFamily: 'Courier',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Tags
                  Wrap(
                    spacing: 8,
                    children: [
                      _Tag(label: 'SUPER ADMIN', color: c.primary),
                      _Tag(label: 'DLT VERIFIED', color: c.green),
                      _Tag(label: 'TRAI REG.', color: const Color(0xFFF59E0B)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat Row ────────────────────────────────────────────────────────────────
  Widget _buildStatRow() {
    return Row(
      children: [
        Expanded(
          child: _StatMini(
            value: '24.8M',
            label: 'SMS (MTD)',
            change: '+12.4%',
            up: true,
            accentColor: c.primary,
            colors: c,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatMini(
            value: '99.3%',
            label: 'Delivery',
            change: '+0.7%',
            up: true,
            accentColor: c.green,
            colors: c,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatMini(
            value: '₹9,920',
            label: 'Wallet',
            change: '-₹3,200',
            up: false,
            accentColor: const Color(0xFFF59E0B),
            colors: c,
          ),
        ),
      ],
    );
  }

  // ── DLT Entity Card ─────────────────────────────────────────────────────────
  Widget _buildDltCard() {
    return _Card(
      colors: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            label: 'DLT ENTITY',
            icon: Icons.fingerprint_rounded,
            colors: c,
          ),
          const SizedBox(height: 12),
          // Entity ID block
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: c.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.primary.withOpacity(0.22)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '1701176606121742751',
                    style: TextStyle(
                      color: c.primary,
                      fontFamily: 'Courier',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(text: '1701176606121742751'),
                    );
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: c.surfaceHigh,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 11, color: c.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'COPY',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 9,
                            fontFamily: 'Courier',
                            letterSpacing: 0.08,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _DltRow(
            label: 'Entity Name',
            value: 'MSGCORE SOLUTIONS PVT LTD',
            colors: c,
          ),
          _DltRow(
            label: 'Reg. No',
            value: 'U74999WB2019PTC234511',
            colors: c,
            mono: true,
          ),
          _DltRow(
            label: 'DLT Status',
            value: '● ACTIVE',
            colors: c,
            valueColor: AppColors.dark.green,
          ),
          _DltRow(label: 'Operator', value: 'TRAI / Vodafone DLT', colors: c),
          _DltRow(
            label: 'KYC Level',
            value: 'FULL KYC',
            colors: c,
            valueColor: AppColors.dark.green,
          ),
          _DltRow(label: 'Headers', value: '14 / 14 Approved', colors: c),
          _DltRow(label: 'Templates', value: '87 Active', colors: c),
          _DltRow(
            label: 'Last Sync',
            value: '2 hrs ago',
            colors: c,
            valueColor: const Color(0xFFF59E0B),
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ── AI Chatbot Card (glow) ───────────────────────────────────────────────────
  Widget _buildAiChatbotCard() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: c.secondary.withOpacity(0.30 + 0.10 * _pulseCtrl.value),
          ),
          boxShadow: [
            BoxShadow(
              color: c.primary.withOpacity(0.10 + 0.06 * _pulseCtrl.value),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Top accent line
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      c.primary,
                      c.secondary,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Bottom-right ambient glow
            Positioned(
              bottom: -30,
              right: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [c.secondary.withOpacity(0.16), Colors.transparent],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [c.primary, c.secondary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: c.primary.withOpacity(0.40),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🤖', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Chatbot Engine',
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'gpt-4o · IN-CENTRAL · v2.4.1',
                              style: TextStyle(
                                color: c.textMuted,
                                fontSize: 10,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: c.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: c.primary.withOpacity(0.30),
                          ),
                        ),
                        child: Text(
                          '● LIVE',
                          style: TextStyle(
                            color: const Color(0xFF7B9FFF),
                            fontSize: 9,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.08,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _AiStat(
                          value: '1.24M',
                          label: 'Msg/Day',
                          colors: c,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _AiStat(
                          value: '98.1%',
                          label: 'Resolution',
                          colors: c,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _AiStat(
                          value: '44ms',
                          label: 'Latency',
                          colors: c,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: c.border, thickness: 0.5),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _AiMeta(
                        label: 'Model',
                        value: 'gpt-4o-mini-ft',
                        colors: c,
                      ),
                      _AiMeta(
                        label: 'Uptime',
                        value: '99.94%',
                        valueColor: c.green,
                        colors: c,
                      ),
                      _AiMeta(label: 'Flows', value: '34 active', colors: c),
                      _AiMeta(
                        label: 'Tokens/Mo',
                        value: '84.2B',
                        valueColor: const Color(0xFFF59E0B),
                        colors: c,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Service Status ──────────────────────────────────────────────────────────
  Widget _buildServiceStatus() {
    return _Card(
      colors: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            label: 'SERVICE STATUS',
            icon: Icons.sensors_rounded,
            colors: c,
          ),
          const SizedBox(height: 8),
          ..._services.map((s) => _ServiceRow(item: s, colors: c)),
        ],
      ),
    );
  }

  // ── Pricing ─────────────────────────────────────────────────────────────────
  Widget _buildPricingSection() {
    return _Card(
      colors: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            label: 'CHANNEL PRICING',
            icon: Icons.receipt_long_rounded,
            colors: c,
          ),
          const SizedBox(height: 12),
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'CHANNEL',
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 8,
                      fontFamily: 'Courier',
                      letterSpacing: 0.12,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'UNIT',
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 8,
                      fontFamily: 'Courier',
                      letterSpacing: 0.12,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'BULK',
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 8,
                      fontFamily: 'Courier',
                      letterSpacing: 0.12,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'INTL.',
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 8,
                      fontFamily: 'Courier',
                      letterSpacing: 0.12,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'SLA',
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 8,
                      fontFamily: 'Courier',
                      letterSpacing: 0.12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: c.border, thickness: 0.5, height: 10),
          ..._pricing.map((row) => _PricingRowWidget(row: row, colors: c)),
        ],
      ),
    );
  }

  // ── Account Details ─────────────────────────────────────────────────────────
  Widget _buildAccountDetails() {
    return _Card(
      colors: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            label: 'ACCOUNT',
            icon: Icons.manage_accounts_rounded,
            colors: c,
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            sub: '3 pending alerts',
            colors: c,
          ),
          _MenuTile(
            icon: Icons.security_rounded,
            label: 'Security & 2FA',
            sub: 'Enabled',
            statusColor: AppColors.dark.green,
            colors: c,
          ),
          _MenuTile(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Billing & Wallet',
            sub: '₹9,920 available',
            colors: c,
          ),
          _MenuTile(
            icon: Icons.api_rounded,
            label: 'API Keys',
            sub: '2 active keys',
            colors: c,
          ),
          _MenuTile(
            icon: Icons.logout_rounded,
            label: 'Logout',
            sub: 'Signed in as super_admin',
            isDestructive: true,
            colors: c,
          ),
        ],
      ),
    );
  }
}

// ─── Reusable Components ──────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final AppColors colors;
  const _GlassButton({
    required this.icon,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Icon(icon, color: colors.textSecondary, size: 17),
    ),
  );
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.28)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 9,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.10,
        fontFamily: 'Courier',
      ),
    ),
  );
}

class _StatMini extends StatelessWidget {
  final String value, label, change;
  final bool up;
  final Color accentColor;
  final AppColors colors;
  const _StatMini({
    required this.value,
    required this.label,
    required this.change,
    required this.up,
    required this.accentColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: colors.surfaceHigh,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: colors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: accentColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Courier',
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 9,
            letterSpacing: 0.08,
            fontFamily: 'Courier',
          ),
        ),
        const SizedBox(height: 5),
        Text(
          change,
          style: TextStyle(
            color: up ? colors.green : colors.error,
            fontSize: 9,
            fontFamily: 'Courier',
          ),
        ),
      ],
    ),
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  final AppColors colors;
  const _Card({required this.child, required this.colors});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: colors.border),
    ),
    child: child,
  );
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final IconData icon;
  final AppColors colors;
  const _SectionTitle({
    required this.label,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 13, color: colors.textMuted),
      const SizedBox(width: 7),
      Text(
        label,
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          fontFamily: 'Courier',
        ),
      ),
      const SizedBox(width: 10),
      Expanded(child: Divider(color: colors.border, thickness: 0.5)),
    ],
  );
}

class _DltRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool mono, isLast;
  final AppColors colors;
  const _DltRow({
    required this.label,
    required this.value,
    required this.colors,
    this.valueColor,
    this.mono = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : Border(bottom: BorderSide(color: colors.border, width: 0.5)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 10,
              fontFamily: 'Courier',
              letterSpacing: 0.05,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? colors.textPrimary,
              fontSize: 11,
              fontFamily: mono ? 'Courier' : null,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

class _AiStat extends StatelessWidget {
  final String value, label;
  final AppColors colors;
  const _AiStat({
    required this.value,
    required this.label,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: colors.primary.withOpacity(0.07),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: colors.primary.withOpacity(0.16)),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: colors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Courier',
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 9,
            letterSpacing: 0.05,
          ),
        ),
      ],
    ),
  );
}

class _AiMeta extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final AppColors colors;
  const _AiMeta({
    required this.label,
    required this.value,
    required this.colors,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 8,
          fontFamily: 'Courier',
          letterSpacing: 0.08,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: TextStyle(
          color: valueColor ?? colors.textPrimary,
          fontSize: 10,
          fontFamily: 'Courier',
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _ServiceRow extends StatelessWidget {
  final _ServiceItem item;
  final AppColors colors;
  const _ServiceRow({required this.item, required this.colors});

  Color get _dotColor {
    if (item.status == 'active') return AppColors.dark.green;
    if (item.status == 'degraded') return const Color(0xFFF59E0B);
    return AppColors.dark.error;
  }

  String get _statusLabel {
    if (item.status == 'active') return 'ACTIVE';
    if (item.status == 'degraded') return 'DEGRADED';
    return 'DOWN';
  }

  @override
  Widget build(BuildContext context) {
    final isLast = item == colors.hashCode.toString();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _dotColor,
              boxShadow: [
                BoxShadow(color: _dotColor.withOpacity(0.5), blurRadius: 5),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            item.latency,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 10,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _dotColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _dotColor.withOpacity(0.22)),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                color: _dotColor,
                fontSize: 8,
                fontFamily: 'Courier',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingRowWidget extends StatelessWidget {
  final _PricingRow row;
  final AppColors colors;
  const _PricingRowWidget({required this.row, required this.colors});

  Color get _chColor {
    if (row.channel == 'SMS') return const Color(0xFF7B9FFF);
    if (row.channel == 'WhatsApp') return AppColors.dark.green;
    if (row.channel == 'RCS') return const Color(0xFFF59E0B);
    return const Color(0xFFA599FF);
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: colors.border, width: 0.5)),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _chColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  row.channel,
                  style: TextStyle(
                    color: _chColor,
                    fontSize: 9,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                row.type,
                style: TextStyle(color: colors.textMuted, fontSize: 9),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            row.unit,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Courier',
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.bulk,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 11,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            row.intl,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 10,
              fontFamily: 'Courier',
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            row.sla,
            style: TextStyle(
              color: colors.green,
              fontSize: 10,
              fontFamily: 'Courier',
            ),
          ),
        ),
      ],
    ),
  );
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color? statusColor;
  final bool isDestructive;
  final AppColors colors;
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.colors,
    this.statusColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => HapticFeedback.selectionClick(),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDestructive
                  ? colors.error.withOpacity(0.10)
                  : colors.surfaceHigh,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: colors.border),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isDestructive ? colors.error : colors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDestructive ? colors.error : colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    color: statusColor ?? colors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.textMuted, size: 18),
        ],
      ),
    ),
  );
}
