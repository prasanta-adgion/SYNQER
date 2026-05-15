import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/custom_appbar.dart';
import 'package:synqer_io/core/widgets/theme_toggle_button.dart';
import 'package:synqer_io/features/all_leads/channel_leads/rcs_lead/rcs_leads_screen.dart';
import 'package:synqer_io/features/rcs_sms/create_campaign/create_campaign_screen.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/all_rcs_templates.dart';
import 'package:synqer_io/features/rcs_sms/rcs_reports_manage/rcs_report.dart';

enum _RcsDrawerDestination {
  createCampaign(
    title: 'Create Campaign',
    subtitle: 'Build and send an RCS campaign',
    icon: Icons.campaign_rounded,
    isReady: true,
  ),
  allTemplates(
    title: 'All Templates',
    subtitle: 'Manage approved templates',
    icon: Icons.article_outlined,
    isReady: true,
  ),
  textTemplate(
    title: 'Text SMS',
    subtitle: 'Create a simple text template',
    icon: Icons.sms_outlined,
    isReady: false,
  ),
  richCardTemplate(
    title: 'Rich Card',
    subtitle: 'Create a media rich card',
    icon: Icons.view_agenda_outlined,
    isReady: false,
  ),
  carouselTemplate(
    title: 'Carousel',
    subtitle: 'Create a carousel template',
    icon: Icons.view_carousel_outlined,
    isReady: false,
  ),
  reportSummary(
    title: 'RCS Report',
    subtitle: 'Summary dashboard',
    icon: Icons.bar_chart_rounded,
    isReady: true,
  ),
  detailedReports(
    title: 'Detailed Reports',
    subtitle: 'Inspect campaign performance',
    icon: Icons.insights_outlined,
    isReady: false,
  ),
  leads(
    title: 'RCS Leads',
    subtitle: 'Review customer interactions',
    icon: Icons.groups_2_outlined,
    isReady: true,
  );

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isReady;

  const _RcsDrawerDestination({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isReady,
  });
}

class RcsScreen extends StatefulWidget {
  const RcsScreen({super.key});

  @override
  State<RcsScreen> createState() => _RcsScreenState();
}

class _RcsScreenState extends State<RcsScreen> {
  final _drawerKey = GlobalKey<SliderDrawerState>();
  final _selectedDestination = ValueNotifier<_RcsDrawerDestination>(
    _RcsDrawerDestination.reportSummary,
  );

  @override
  void dispose() {
    _selectedDestination.dispose();
    super.dispose();
  }

  void _selectDestination(_RcsDrawerDestination destination) {
    _selectedDestination.value = destination;
    _drawerKey.currentState?.closeSlider();
  }

  Future<void> _openDestination(_RcsDrawerDestination destination) async {
    _selectDestination(destination);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _RcsPageBody(
          destination: destination,
          showPageAppBars: true,
          onShowReports: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            _selectDestination(_RcsDrawerDestination.reportSummary);
          },
        ),
      ),
    );
    if (!mounted) return;
    _selectDestination(_RcsDrawerDestination.reportSummary);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ValueListenableBuilder<_RcsDrawerDestination>(
      valueListenable: _selectedDestination,
      builder: (context, destination, _) {
        return Scaffold(
          backgroundColor: c.bg,
          appBar: _RcsScaffoldAppBar(
            destination: destination,
            onMenuTap: () => _drawerKey.currentState?.toggle(),
          ),
          body: SliderDrawer(
            key: _drawerKey,
            sliderOpenSize: 300,
            animationDuration: 280,
            backgroundColor: c.bg,
            appBar: const SizedBox.shrink(),
            slider: _RcsDrawerPanel(
              selectedDestination: destination,
              onDestinationSelected: (destination) {
                _openDestination(destination);
              },
            ),
            child: const RcsReportDashboard(showAppBar: false),
          ),
        );
      },
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────

class _RcsScaffoldAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final _RcsDrawerDestination destination;
  final VoidCallback onMenuTap;

  const _RcsScaffoldAppBar({
    required this.destination,
    required this.onMenuTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(73);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: c.surface,
      toolbarHeight: 72,
      titleSpacing: 0,
      leadingWidth: 62,
      leading: Center(child: _RcsMenuButton(onTap: onMenuTap)),
      title: _RcsAppBarTitle(destination: destination),
      actions: [ThemeToggleButton(), const SizedBox(width: 10)],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: c.border),
      ),
    );
  }
}

class _RcsMenuButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RcsMenuButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.border),
        ),
        child: Icon(Icons.menu_rounded, color: c.textSecondary, size: 20),
      ),
    );
  }
}

class _RcsAppBarTitle extends StatelessWidget {
  final _RcsDrawerDestination destination;

  const _RcsAppBarTitle({required this.destination});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      children: [
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                destination.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                destination.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: c.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Page Body ───────────────────────────────────────────────────────────────

class _RcsPageBody extends StatelessWidget {
  final _RcsDrawerDestination destination;
  final bool showPageAppBars;
  final VoidCallback onShowReports;

  const _RcsPageBody({
    required this.destination,
    required this.onShowReports,
    this.showPageAppBars = false,
  });

  @override
  Widget build(BuildContext context) {
    return switch (destination) {
      _RcsDrawerDestination.createCampaign => CreateCampaignView(
        // showAppBar: showPageAppBars,
        onShowReports: onShowReports,
      ),
      _RcsDrawerDestination.allTemplates => AllRcsTemplateScreen(
        showAppBar: showPageAppBars,
      ),
      _RcsDrawerDestination.textTemplate => const _ComingSoonView(
        destination: _RcsDrawerDestination.textTemplate,
        showAppBar: true,
      ),
      _RcsDrawerDestination.richCardTemplate => const _ComingSoonView(
        destination: _RcsDrawerDestination.richCardTemplate,
        showAppBar: true,
      ),
      _RcsDrawerDestination.carouselTemplate => const _ComingSoonView(
        destination: _RcsDrawerDestination.carouselTemplate,
        showAppBar: true,
      ),
      _RcsDrawerDestination.reportSummary => RcsReportDashboard(
        showAppBar: showPageAppBars,
      ),
      _RcsDrawerDestination.detailedReports => const _ComingSoonView(
        destination: _RcsDrawerDestination.detailedReports,
        showAppBar: true,
      ),
      _RcsDrawerDestination.leads => _RcsLeadsPage(showAppBar: showPageAppBars),
    };
  }
}

class _RcsLeadsPage extends StatelessWidget {
  final bool showAppBar;

  const _RcsLeadsPage({required this.showAppBar});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: showAppBar
          ? CustomAppBar(
              title: 'RCS Leads',
              subtitle: 'Manage and track all RCS customer leads',
              backgroundColor: c.surface,
              titleColor: c.textPrimary,
              subtitleColor: c.textSecondary,
              onBack: () => Navigator.pop(context),
            )
          : null,
      body: const RcsLeadsScreen(),
    );
  }
}

// ─── Drawer Panel ────────────────────────────────────────────────────────────

class _RcsDrawerPanel extends StatelessWidget {
  final _RcsDrawerDestination selectedDestination;
  final ValueChanged<_RcsDrawerDestination> onDestinationSelected;

  const _RcsDrawerPanel({
    required this.selectedDestination,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Material(
      color: c.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _DrawerBrand(),
            Container(height: 1, color: c.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
                children: [
                  _DrawerSection(
                    title: 'Create Campaign',
                    icon: Icons.campaign_rounded,
                    destinations: const [_RcsDrawerDestination.createCampaign],
                    selected: selectedDestination,
                    onTap: onDestinationSelected,
                  ),
                  _DrawerSection(
                    title: 'Manage Template',
                    icon: Icons.article_outlined,
                    destinations: const [
                      _RcsDrawerDestination.allTemplates,
                      _RcsDrawerDestination.textTemplate,
                      _RcsDrawerDestination.richCardTemplate,
                      _RcsDrawerDestination.carouselTemplate,
                    ],
                    selected: selectedDestination,
                    onTap: onDestinationSelected,
                  ),
                  _DrawerSection(
                    title: 'Report',
                    icon: Icons.bar_chart_rounded,
                    destinations: const [
                      _RcsDrawerDestination.reportSummary,
                      _RcsDrawerDestination.detailedReports,
                    ],
                    selected: selectedDestination,
                    onTap: onDestinationSelected,
                  ),
                  _DrawerSection(
                    title: 'Leads',
                    icon: Icons.groups_2_outlined,
                    destinations: const [_RcsDrawerDestination.leads],
                    selected: selectedDestination,
                    onTap: onDestinationSelected,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerBrand extends StatelessWidget {
  const _DrawerBrand();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.primary, c.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.forum_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'RCS Module',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: c.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: c.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        'BETA',
                        style: TextStyle(
                          color: c.primary,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Campaigns · Templates · Reports',
                  style: TextStyle(
                    color: c.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_RcsDrawerDestination> destinations;
  final _RcsDrawerDestination selected;
  final ValueChanged<_RcsDrawerDestination> onTap;

  const _DrawerSection({
    required this.title,
    required this.icon,
    required this.destinations,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isActive = destinations.contains(selected);

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isActive,
          tilePadding: const EdgeInsets.symmetric(horizontal: 10),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: c.border),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isActive ? c.primary.withValues(alpha: 0.35) : c.border,
            ),
          ),
          backgroundColor: isActive ? c.accentSoft : Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          iconColor: c.primary,
          collapsedIconColor: c.textSecondary,
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isActive ? c.primary : c.surfaceHigh,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 17,
              color: isActive ? Colors.white : c.textSecondary,
            ),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isActive ? c.primary : c.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
            ),
          ),
          children: destinations
              .map(
                (destination) => _DrawerNavItem(
                  destination: destination,
                  selected: selected,
                  onTap: onTap,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final _RcsDrawerDestination destination;
  final _RcsDrawerDestination selected;
  final ValueChanged<_RcsDrawerDestination> onTap;

  const _DrawerNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isActive = destination == selected;
    final isLocked = !destination.isReady;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onTap(destination),
          splashColor: c.primary.withValues(alpha: 0.06),
          highlightColor: c.primary.withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            // decoration: BoxDecoration(
            //   color: isActive ? c.accentSoft : Colors.transparent,
            //   borderRadius: BorderRadius.circular(10),
            //   border: Border.all(
            //     color: isActive ? c.primary.withValues(alpha: 0.3) : c.border,
            //   ),
            // ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isActive ? c.primary : c.surfaceHigh,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    destination.icon,
                    size: 17,
                    color: isActive
                        ? Colors.white
                        : isLocked
                        ? c.textMuted
                        : c.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isActive
                              ? c.primary
                              : isLocked
                              ? c.textMuted
                              : c.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        destination.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: c.textMuted, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
                if (isLocked) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: c.warningSoft,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: c.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'SOON',
                      style: TextStyle(
                        color: c.warning,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ] else if (isActive) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: c.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Coming Soon View ────────────────────────────────────────────────────────

class _ComingSoonView extends StatelessWidget {
  final _RcsDrawerDestination destination;
  final bool showAppBar;

  const _ComingSoonView({required this.destination, this.showAppBar = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: showAppBar
          ? CustomAppBar(
              title: destination.title,
              subtitle: destination.subtitle,
              backgroundColor: c.surface,
              titleColor: c.textPrimary,
              subtitleColor: c.textSecondary,
              onBack: () => Navigator.pop(context),
            )
          : null,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      c.primary.withValues(alpha: 0.15),
                      c.secondary.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.primary.withValues(alpha: 0.2)),
                ),
                child: Icon(destination.icon, color: c.primary, size: 30),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: c.warningSoft,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: c.warning.withValues(alpha: 0.35)),
                ),
                child: Text(
                  'COMING SOON',
                  style: TextStyle(
                    color: c.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                destination.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                destination.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 16,
                      color: c.textSecondary,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      "We'll notify you when this is ready",
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
