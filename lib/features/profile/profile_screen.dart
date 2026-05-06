// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/app_colors.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/features/profile/bloc/profile_bloc.dart';
import 'package:synqer_io/features/profile/model/user_profile_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProfileBloc(profileRepo: AppInjector.profileRepo)
            ..add(const FetchProfileEvent()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView>
    with TickerProviderStateMixin {
  late final AnimationController _headerCtrl;
  late final AnimationController _pulseCtrl;

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
    final c = context.colors;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: c.bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: c.bg,
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileError) {
              return _ErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<ProfileBloc>().add(const FetchProfileEvent()),
              );
            }

            final user = state is ProfileLoaded ? state.profile.user : null;

            return RefreshIndicator(
              color: c.primary,
              backgroundColor: c.surface,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  _buildAppBar(c, user),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 50),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // const SizedBox(height: 16),
                        if (state is ProfileLoading || state is ProfileInitial)
                          _LoadingCard(c: c),
                        _buildBalanceSection(c, user),
                        const SizedBox(height: 14),
                        _buildPlanCard(c, user),
                        if (user?.dltEntity != null) ...[
                          const SizedBox(height: 14),
                          _buildDltCard(c, user!.dltEntity!),
                        ],

                        const SizedBox(height: 14),
                        _buildServicesCard(c, user),
                        const SizedBox(height: 14),
                        _buildPricingSection(c, user),
                        const SizedBox(height: 14),
                        _buildAccountInfoCard(c, user),
                        const SizedBox(height: 14),
                        _buildActionsCard(c, user),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    context.read<ProfileBloc>().add(const FetchProfileEvent());
    await context.read<ProfileBloc>().stream.firstWhere(
      (s) => s is! ProfileLoading,
    );
  }

  // ── Sliver App Bar ──────────────────────────────────────────────────────────
  Widget _buildAppBar(AppColors c, User? user) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: c.bg,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _GlassBtn(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.maybePop(context),
          c: c,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: _GlassBtn(icon: Icons.more_vert_rounded, onTap: () {}, c: c),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _buildHeader(c, user),
      ),
    );
  }

  // ── Profile Header ──────────────────────────────────────────────────────────
  Widget _buildHeader(AppColors c, User? user) {
    final name = _pick(user?.fullName, user?.userName) ?? '--';
    final email = _pick(user?.email) ?? '--';
    final rawStatus = _pick(user?.status) ?? 'active';
    final status = rawStatus.toUpperCase();
    final statusColor = status == 'ACTIVE' ? c.green : const Color(0xFFF59E0B);

    return Container(
      color: c.bg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [c.primary, c.secondary],
                      ),
                      border: Border.all(color: c.borderStrong, width: 2),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: c.primary.withOpacity(0.35),
                      //     blurRadius: 20,
                      //     spreadRadius: 2,
                      //   ),
                      // ],
                    ),
                    child: ClipOval(
                      child: _pick(user?.profilePicture) == null
                          ? Center(
                              child: Text(
                                _initials(name),
                                style: TextStyle(
                                  color: c.onBrand,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : Image.network(
                              user!.profilePicture!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  _initials(name),
                                  style: TextStyle(
                                    color: c.onBrand,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        if (_pick(user?.mobileNumber) != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            user!.mobileNumber!,
                            style: TextStyle(
                              color: c.textMuted,
                              fontSize: 11,
                              // fontFamily: 'Courier',
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, __) => _StatusBadge(
                            label: status,
                            color: statusColor,
                            pulse: _pulseCtrl.value,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Wrap(
              //   spacing: 6,
              //   runSpacing: 6,
              //   children: [
              //     if (_pick(user?.planName) != null)
              //       _Chip(
              //         label: user!.planName!.toUpperCase(),
              //         color: c.primary,
              //       ),
              //     if (user?.dltEntity != null)
              //       _Chip(label: 'DLT VERIFIED', color: c.green),
              //     if (_pick(user?.country) != null)
              //       _Chip(
              //         label: user!.country!.toUpperCase(),
              //         color: const Color(0xFFF59E0B),
              //       ),
              //     if (user?.services?.rcs == true)
              //       _Chip(label: 'RCS', color: const Color(0xFFF59E0B)),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── BALANCE SECTION (REDESIGNED) ────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBalanceSection(AppColors c, User? user) {
    final currency = _currencySymbol(user?.currency);
    final hasRcs = user?.rcsBalance != null;
    final totalBalance =
        (user?.smsBalance ?? 0) +
        (user?.whatsappBalance ?? 0) +
        (user?.rcsBalance?.text ?? 0) +
        (user?.rcsBalance?.richMedia ?? 0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.primary.withOpacity(0.08),
            c.secondary.withOpacity(0.04),
            c.surface,
          ],
        ),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: c.primary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Total Balance Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: c.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: c.primary.withOpacity(0.25)),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 16,
                        color: c.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Balance',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Across all channels',
                          style: TextStyle(
                            color: c.textMuted,
                            fontSize: 9,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: c.green.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: c.green.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 11,
                            color: c.green,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: c.green,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _fmtMoney(totalBalance, currency),
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        user?.currency?.toUpperCase() ?? '',
                        style: TextStyle(
                          color: c.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── Divider ──────────────────────────────────────────────────────
          Container(height: 0.5, color: c.border),
          // ── Channel Breakdown ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Row(
                    children: [
                      Text(
                        'Channel Breakdown',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.pie_chart_outline_rounded,
                        size: 13,
                        color: c.textMuted,
                      ),
                    ],
                  ),
                ),
                _BalanceChannelRow(
                  icon: Icons.sms_rounded,
                  label: 'SMS Balance',
                  sublabel: 'Text messaging',
                  amount: _fmtMoney(user?.smsBalance, currency),
                  accent: c.primary,
                  c: c,
                ),
                const SizedBox(height: 8),
                _BalanceChannelRow(
                  icon: Icons.chat_rounded,
                  label: 'WhatsApp Balance',
                  sublabel: 'Business messaging',
                  amount: _fmtMoney(user?.whatsappBalance, currency),
                  accent: c.green,
                  c: c,
                ),
                if (hasRcs) ...[
                  const SizedBox(height: 8),
                  _BalanceRcsRow(
                    label: 'RCS Balance',
                    sublabel: 'Rich communication',
                    textValue: _fmtMoney(user!.rcsBalance!.text, currency),
                    richValue: _fmtMoney(user.rcsBalance!.richMedia, currency),
                    accent: const Color(0xFFF59E0B),
                    c: c,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── PRICING SECTION (REDESIGNED) ────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPricingSection(AppColors c, User? user) {
    final currency = _currencySymbol(user?.currency);
    final hasRcs = user?.rcsPricing != null;
    final hasSms = user?.smsPricing != null;
    final hasWa = user?.whatsappPricing != null;

    if (!hasSms && !hasWa && !hasRcs) {
      return _Card(
        c: c,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PremiumSectionHeader(
              label: 'Pricing',
              sublabel: 'Per-message rates',
              icon: Icons.receipt_long_rounded,
              c: c,
            ),
            const SizedBox(height: 16),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: c.textMuted,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pricing data unavailable',
                      style: TextStyle(color: c.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _Card(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PremiumSectionHeader(
            label: 'Pricing',
            sublabel: 'Per-message rates',
            icon: Icons.receipt_long_rounded,
            c: c,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: c.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.primary.withOpacity(0.22)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, size: 11, color: c.primary),
                  const SizedBox(width: 3),
                  Text(
                    user?.currency?.toUpperCase() ?? 'RATE',
                    style: TextStyle(
                      color: c.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (hasSms)
            _PricingRow(
              icon: Icons.sms_rounded,
              label: 'SMS',
              sublabel: 'Standard text messaging',
              value: _fmtPriceShort(user!.smsPricing, currency),
              unit: '/msg',
              accent: c.primary,
              c: c,
            ),
          if (hasSms && (hasWa || hasRcs)) const SizedBox(height: 8),
          if (hasWa)
            _PricingRow(
              icon: Icons.chat_rounded,
              label: 'WhatsApp',
              sublabel: 'Business API messaging',
              value: _fmtPriceShort(user!.whatsappPricing, currency),
              unit: '/msg',
              accent: c.green,
              c: c,
            ),
          if (hasWa && hasRcs) const SizedBox(height: 8),
          if (hasRcs)
            _PricingRcsRow(
              label: 'RCS',
              sublabel: 'Rich communication services',
              textValue: _fmtPriceShort(user!.rcsPricing!.text, currency),
              richValue: _fmtPriceShort(user.rcsPricing!.richMedia, currency),
              accent: const Color(0xFFF59E0B),
              c: c,
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 12, color: c.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rates may vary based on destination and message type',
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Plan Card ───────────────────────────────────────────────────────────────
  Widget _buildPlanCard(AppColors c, User? user) {
    final currency = _currencySymbol(user?.currency);
    return _Card(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PremiumSectionHeader(
            label: 'Plan & Subscription',
            sublabel: 'Your active plan details',
            icon: Icons.workspace_premium_rounded,
            c: c,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Plan',
                  value: _pick(user?.planName) ?? '--',
                  c: c,
                  valueColor: c.primary,
                  bold: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  label: 'Price',
                  value: user?.planPrice != null
                      ? '$currency${user!.planPrice}'
                      : '--',
                  c: c,
                  bold: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Panel Expiry',
                  value: "${user!.expiryDate.toString()}\n${user.expiryTime}",
                  c: c,
                  // valueColor: _expiryColor(c, user.expiryDate),
                  valueColor: c.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  label: 'AI Credits',
                  value: user.aiCredits != null ? '${user.aiCredits}' : '--',
                  c: c,
                  valueColor: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          if (_pick(user.userName) != null ||
              _pick(user.rmlTransUsername) != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (_pick(user.userName) != null)
                  Expanded(
                    child: _InfoTile(
                      label: 'Username',
                      value: user.userName!,
                      c: c,
                      mono: true,
                    ),
                  ),
                if (_pick(user.rmlTransUsername) != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoTile(
                      label: 'RML Trans.',
                      value: user.rmlTransUsername!,
                      c: c,
                      mono: true,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── DLT Entity Card ─────────────────────────────────────────────────────────
  Widget _buildDltCard(AppColors c, DltEntity dlt) {
    return _Card(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PremiumSectionHeader(
            label: 'DLT Entity',
            sublabel: 'Verified registration details',
            icon: Icons.verified_user_rounded,
            c: c,
          ),
          const SizedBox(height: 14),
          if (_pick(dlt.entityId) != null)
            _CopyableField(label: 'Entity ID', value: dlt.entityId!, c: c),
          if (_pick(dlt.companyName) != null) ...[
            const SizedBox(height: 10),
            _RowDetail(label: 'Company', value: dlt.companyName!, c: c),
          ],
          if (_pick(dlt.date) != null) ...[
            const SizedBox(height: 6),
            _RowDetail(
              label: 'Registered',
              value: dlt.date.toString(),
              c: c,
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }

  // ── Services Status Card ────────────────────────────────────────────────────
  Widget _buildServicesCard(AppColors c, User? user) {
    final s = user?.services;
    final items = <_SvcEntry>[
      if (s?.sms == true) _SvcEntry('SMS', Icons.sms_outlined, c.primary),
      if (s?.whatsapp == true)
        _SvcEntry('WhatsApp', Icons.chat_bubble_outline_rounded, c.green),
      if (s?.chatbot == true)
        _SvcEntry('AI Chatbot', Icons.smart_toy_outlined, c.secondary),
      if (s?.rcs == true)
        _SvcEntry('RCS', Icons.rss_feed_rounded, const Color(0xFFF59E0B)),
    ];

    return _Card(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PremiumSectionHeader(
            label: 'Active Services',
            sublabel: 'Currently enabled features',
            icon: Icons.sensors_rounded,
            c: c,
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No services enabled',
                style: TextStyle(color: c.textMuted, fontSize: 13),
              ),
            )
          else
            ...items.asMap().entries.map((e) {
              return _ServiceRowTile(
                entry: e.value,
                c: c,
                isLast: e.key == items.length - 1,
              );
            }),
        ],
      ),
    );
  }

  // ── Account Info Card ───────────────────────────────────────────────────────
  Widget _buildAccountInfoCard(AppColors c, User? user) {
    return _Card(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PremiumSectionHeader(
            label: 'Account Info',
            sublabel: 'Your account details',
            icon: Icons.badge_outlined,
            c: c,
          ),
          const SizedBox(height: 12),
          if (_pick(user?.sId) != null || _pick(user?.id) != null)
            _CopyableField(
              label: 'User ID',
              value: (_pick(user?.id) ?? user!.sId)!,
              c: c,
            ),
          const SizedBox(height: 10),
          if (_pick(user?.mobileNumber) != null)
            _RowDetail(
              label: 'Mobile',
              value: user!.mobileNumber!,
              c: c,
              mono: true,
            ),
          if (_pick(user?.country) != null)
            _RowDetail(label: 'Country', value: user!.country!, c: c),
          if (_pick(user?.currency) != null)
            _RowDetail(label: 'Currency', value: user!.currency!, c: c),
          if (_pick(user?.createdAt) != null)
            _RowDetail(
              label: 'Joined',
              value: user!.createDate.toString(),
              c: c,
            ),
          if (_pick(user?.updatedAt) != null)
            _RowDetail(
              label: 'Last Updated',
              value: user!.updateDate.toString(),
              c: c,
              isLast: true,
            ),
        ],
      ),
    );
  }

  // ── Actions Card ────────────────────────────────────────────────────────────
  Widget _buildActionsCard(AppColors c, User? user) {
    final currency = _currencySymbol(user?.currency);
    final wallet = (user?.smsBalance ?? 0) + (user?.whatsappBalance ?? 0);

    return _Card(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PremiumSectionHeader(
            label: 'Account',
            sublabel: 'Manage settings & access',
            icon: Icons.manage_accounts_rounded,
            c: c,
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            sub: 'Manage alerts',
            c: c,
          ),
          _ActionTile(
            icon: Icons.security_rounded,
            label: 'Security & 2FA',
            sub: 'Protect your account',
            c: c,
          ),
          _ActionTile(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Billing & Wallet',
            sub: '${_fmtMoney(wallet, currency)} available',
            c: c,
          ),
          _ActionTile(
            icon: Icons.api_rounded,
            label: 'API Keys',
            sub: 'Manage access keys',
            c: c,
          ),
          _ActionTile(
            icon: Icons.logout_rounded,
            label: 'Logout',
            sub:
                'Signed in as ${_pick(user?.userName) ?? _pick(user?.email) ?? '--'}',
            c: c,
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

String _fmtMoney(num? value, String currency) {
  final v = value ?? 0;
  if (v >= 1000000) return '$currency${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '$currency${(v / 1000).toStringAsFixed(1)}K';
  return '$currency${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)}';
}

String _fmtPriceShort(num? value, String currency) {
  if (value == null) return '--';
  final s = value.toStringAsFixed(2);
  final trimmed = s
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
  return '$currency$trimmed';
}

String _currencySymbol(String? c) {
  final n = c?.toUpperCase().trim();
  if (n == 'INR') return '₹';
  if (n == 'USD') return '\$';
  if (n == 'EUR') return '€';
  if (n == 'GBP') return '£';
  return n == null || n.isEmpty ? '' : '$n ';
}

String? _pick(String? a, [String? b]) {
  final ta = a?.trim();
  if (ta != null && ta.isNotEmpty) return ta;
  final tb = b?.trim();
  if (tb != null && tb.isNotEmpty) return tb;
  return null;
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'U';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── BALANCE WIDGETS (NEW) ────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _BalanceChannelRow extends StatelessWidget {
  final IconData icon;
  final String label, sublabel, amount;
  final Color accent;
  final AppColors c;
  const _BalanceChannelRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.amount,
    required this.accent,
    required this.c,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: c.surfaceHigh,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: c.border),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent.withOpacity(0.18), accent.withOpacity(0.08)],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withOpacity(0.25)),
          ),
          child: Icon(icon, size: 18, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                sublabel,
                style: TextStyle(color: c.textMuted, fontSize: 10),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              'available',
              style: TextStyle(
                color: c.textMuted,
                fontSize: 9,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _BalanceRcsRow extends StatelessWidget {
  final String label, sublabel;
  final String textValue, richValue;
  final Color accent;
  final AppColors c;
  const _BalanceRcsRow({
    required this.label,
    required this.sublabel,
    required this.textValue,
    required this.richValue,
    required this.accent,
    required this.c,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    decoration: BoxDecoration(
      color: c.surfaceHigh,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: c.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent.withOpacity(0.18), accent.withOpacity(0.08)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withOpacity(0.25)),
              ),
              child: Icon(Icons.rss_feed_rounded, size: 18, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    sublabel,
                    style: TextStyle(color: c.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: c.bg.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Text',
                          style: TextStyle(
                            color: c.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      textValue,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 0.5, height: 30, color: c.border),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Rich Media',
                            style: TextStyle(
                              color: c.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        richValue,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── PRICING WIDGETS (NEW) ────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _PricingRow extends StatelessWidget {
  final IconData icon;
  final String label, sublabel, value, unit;
  final Color accent;
  final AppColors c;
  const _PricingRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.unit,
    required this.accent,
    required this.c,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: c.surfaceHigh,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: c.border),
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withOpacity(0.22)),
          ),
          child: Icon(icon, size: 17, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                sublabel,
                style: TextStyle(color: c.textMuted, fontSize: 10),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                unit,
                style: TextStyle(
                  color: c.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PricingRcsRow extends StatelessWidget {
  final String label, sublabel;
  final String textValue, richValue;
  final Color accent;
  final AppColors c;
  const _PricingRcsRow({
    required this.label,
    required this.sublabel,
    required this.textValue,
    required this.richValue,
    required this.accent,
    required this.c,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    decoration: BoxDecoration(
      color: c.surfaceHigh,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: c.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withOpacity(0.22)),
              ),
              child: Icon(Icons.rss_feed_rounded, size: 17, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    sublabel,
                    style: TextStyle(color: c.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: c.bg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: c.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Text',
                          style: TextStyle(
                            color: c.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          textValue,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Text(
                            '/msg',
                            style: TextStyle(color: c.textMuted, fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: c.bg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: c.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Rich Media',
                          style: TextStyle(
                            color: c.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          richValue,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Text(
                            '/msg',
                            style: TextStyle(color: c.textMuted, fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── PREMIUM SECTION HEADER (NEW) ─────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _PremiumSectionHeader extends StatelessWidget {
  final String label;
  final String? sublabel;
  final IconData icon;
  final AppColors c;
  final Widget? trailing;
  const _PremiumSectionHeader({
    required this.label,
    required this.icon,
    required this.c,
    this.sublabel,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.border),
        ),
        child: Icon(icon, size: 14, color: c.textSecondary),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
              ),
            ),
            if (sublabel != null) ...[
              const SizedBox(height: 1),
              Text(
                sublabel!,
                style: TextStyle(
                  color: c.textMuted,
                  fontSize: 10,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ],
        ),
      ),
      if (trailing != null) trailing!,
    ],
  );
}

// ─── Data entries ─────────────────────────────────────────────────────────────

class _SvcEntry {
  final String name;
  final IconData icon;
  final Color color;
  const _SvcEntry(this.name, this.icon, this.color);
}

// ─── Loading / Error ──────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  final AppColors c;
  const _LoadingCard({required this.c});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: c.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: c.border),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: c.primary),
        ),
        const SizedBox(width: 12),
        Text(
          'Loading profile…',
          style: TextStyle(color: c.textSecondary, fontSize: 13),
        ),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: c.error, size: 52),
            const SizedBox(height: 16),
            Text(
              'Unable to load profile',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final AppColors c;
  const _Card({required this.child, required this.c});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: c.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: c.border),
    ),
    child: child,
  );
}

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final AppColors c;
  const _GlassBtn({required this.icon, required this.onTap, required this.c});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
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
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double pulse;
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.25 + 0.10 * pulse)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4 + 0.3 * pulse),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.12,
            fontFamily: 'Courier',
          ),
        ),
      ],
    ),
  );
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  final AppColors c;
  final Color? valueColor;
  final bool bold, mono;
  const _InfoTile({
    required this.label,
    required this.value,
    required this.c,
    this.valueColor,
    this.bold = false,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: c.surfaceHigh,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: c.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? c.textPrimary,
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            fontFamily: mono ? 'Courier' : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class _CopyableField extends StatelessWidget {
  final String label, value;
  final AppColors c;
  final bool mask;
  const _CopyableField({
    required this.label,
    required this.value,
    required this.c,
    this.mask = false,
  });

  String get _display => mask && value.length > 12
      ? '${value.substring(0, 6)}••••••${value.substring(value.length - 4)}'
      : value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: c.primary.withOpacity(0.06),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.primary.withOpacity(0.20)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: c.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                _display,
                style: TextStyle(
                  color: c.primary,
                  fontFamily: 'Courier',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copied'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
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
      ],
    ),
  );
}

class _RowDetail extends StatelessWidget {
  final String label, value;
  final AppColors c;
  final bool mono, isLast;
  const _RowDetail({
    required this.label,
    required this.value,
    required this.c,
    this.mono = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: isLast
        ? null
        : BoxDecoration(
            border: Border(bottom: BorderSide(color: c.border, width: 0.5)),
          ),
    child: Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              color: c.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: mono ? 'Courier' : null,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ServiceRowTile extends StatelessWidget {
  final _SvcEntry entry;
  final AppColors c;
  final bool isLast;
  const _ServiceRowTile({
    required this.entry,
    required this.c,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: isLast
        ? null
        : BoxDecoration(
            border: Border(bottom: BorderSide(color: c.border, width: 0.5)),
          ),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: entry.color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: entry.color.withOpacity(0.22)),
          ),
          child: Icon(entry.icon, size: 15, color: entry.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            entry.name,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.green,
            boxShadow: [
              BoxShadow(color: c.green.withOpacity(0.5), blurRadius: 5),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: c.green.withOpacity(0.10),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: c.green.withOpacity(0.22)),
          ),
          child: Text(
            'ACTIVE',
            style: TextStyle(
              color: c.green,
              fontSize: 8,
              fontFamily: 'Courier',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final AppColors c;
  final bool isDestructive;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.c,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => HapticFeedback.selectionClick(),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDestructive ? c.error.withOpacity(0.10) : c.surfaceHigh,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: c.border),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isDestructive ? c.error : c.textSecondary,
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
                    color: isDestructive ? c.error : c.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(color: c.textMuted, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textMuted, size: 18),
        ],
      ),
    ),
  );
}
