// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:synqer_io/core/enums/leadfilter_tabs_enum.dart';
import 'package:synqer_io/core/model/navbar_item_model.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/custom_appbar.dart';
import 'package:synqer_io/core/widgets/icon_button.dart';
import 'package:synqer_io/core/widgets/theme_toggle_button.dart';
import 'package:synqer_io/features/all_leads/channel_leads/whatsapp_lead/whatsapp_leads_screen.dart';
import 'package:synqer_io/features/all_leads/website_lead/ai_lead/aiweb_leads_screen.dart';
import 'package:synqer_io/features/all_leads/widgets/lead_filter_sheet.dart';
import 'package:synqer_io/features/all_leads/channel_leads/rcs_lead/rcs_leads_screen.dart';
import 'package:synqer_io/features/all_leads/widgets/lead_tab_shell.dart';
import 'package:synqer_io/features/dashboard/widgets/header_section.dart';

class NavbarLeadsScreen extends StatefulWidget {
  const NavbarLeadsScreen({super.key});

  @override
  State<NavbarLeadsScreen> createState() => _NavbarLeadsScreenState();
}

class _NavbarLeadsScreenState extends State<NavbarLeadsScreen> {
  final _leadNavIndex = ValueNotifier(0);
  final _channelTabIndex = ValueNotifier(0);
  final _webTabIndex = ValueNotifier(0);

  final ValueNotifier<bool> _showTabBar = ValueNotifier(true);

  final _whatsappFilters = ValueNotifier<Map<String, dynamic>>({
    'status': 'All',
    'leadType': 'All',
  });
  final _rcsFilters = ValueNotifier<Map<String, dynamic>>({
    'eventType': 'All',
    'fromDate': null,
    'toDate': null,
  });
  final _aiAgentFilters = ValueNotifier<Map<String, dynamic>>({
    'isConnected': 'All',
  });
  final _webFormFilters = ValueNotifier<Map<String, dynamic>>({
    'isRead': 'All',
    'isConnected': 'All',
  });

  static const _webFormLeads = [
    {
      'name': 'Ishaan Gupta',
      'phone': '+91 66554 44332',
      'tag': 'Warm',
      'time': '4h ago',
    },
    {
      'name': 'Tara Menon',
      'phone': '+91 55443 33221',
      'tag': 'Hot',
      'time': '9h ago',
    },
    {
      'name': 'Kabir Sethi',
      'phone': '+91 44332 22110',
      'tag': 'Cold',
      'time': '2d ago',
    },
  ];

  bool _hasActive(Map<String, dynamic> f) => f.values.any((v) {
    if (v == null) return false;
    if (v is String) return v != 'All';
    if (v is DateTime) return true;
    return false;
  });

  @override
  void initState() {
    super.initState();
    _leadNavIndex.addListener(_showTabs);
  }

  bool get _currentFilterActive {
    if (_leadNavIndex.value == 0) {
      return _channelTabIndex.value == 0
          ? _hasActive(_whatsappFilters.value)
          : _hasActive(_rcsFilters.value);
    }
    return _webTabIndex.value == 0
        ? _hasActive(_aiAgentFilters.value)
        : _hasActive(_webFormFilters.value);
  }

  Future<void> _openFilter() async {
    final nav = _leadNavIndex.value;
    if (nav == 0) {
      if (_channelTabIndex.value == 0) {
        final result = await LeadFilterSheet.show(
          context,
          filterContext: LeadFilterContext.whatsapp,
          currentFilters: Map.from(_whatsappFilters.value),
        );
        if (result != null) _whatsappFilters.value = result;
      } else {
        final result = await LeadFilterSheet.show(
          context,
          filterContext: LeadFilterContext.rcs,
          currentFilters: Map.from(_rcsFilters.value),
        );
        if (result != null) _rcsFilters.value = result;
      }
    } else {
      if (_webTabIndex.value == 0) {
        final result = await LeadFilterSheet.show(
          context,
          filterContext: LeadFilterContext.aiWebAgent,
          currentFilters: Map.from(_aiAgentFilters.value),
        );
        if (result != null) _aiAgentFilters.value = result;
      } else {
        final result = await LeadFilterSheet.show(
          context,
          filterContext: LeadFilterContext.webForm,
          currentFilters: Map.from(_webFormFilters.value),
        );
        if (result != null) _webFormFilters.value = result;
      }
    }
  }

  void onScrollDirectionChanged(ScrollDirection direction) {
    if (direction == ScrollDirection.reverse && _showTabBar.value) {
      _showTabBar.value = false;
    } else if (direction == ScrollDirection.forward && !_showTabBar.value) {
      _showTabBar.value = true;
    }
  }

  void _showTabs() {
    if (!_showTabBar.value) _showTabBar.value = true;
  }

  @override
  void dispose() {
    _leadNavIndex.removeListener(_showTabs);
    _leadNavIndex.dispose();
    _channelTabIndex.dispose();
    _webTabIndex.dispose();
    _whatsappFilters.dispose();
    _rcsFilters.dispose();
    _aiAgentFilters.dispose();
    _webFormFilters.dispose();
    _showTabBar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,

      appBar: CustomAppBar(
        title: 'Leads',
        subtitle: 'All your lead activity in one place',
        backgroundColor: c.surface,
        titleColor: c.textPrimary,
        subtitleColor: c.textSecondary,
        onBack: () => Navigator.pop(context),

        trailing: Row(
          children: [
            ThemeToggleButton(),
            const SizedBox(width: 10),
            ListenableBuilder(
              listenable: Listenable.merge([
                _leadNavIndex,
                _channelTabIndex,
                _webTabIndex,
                _whatsappFilters,
                _rcsFilters,
                _aiAgentFilters,
                _webFormFilters,
              ]),
              builder: (ctx, _) {
                final lc = ctx.colors;
                final active = _currentFilterActive;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconBtn(
                      icon: Icons.tune_outlined,
                      onTap: () {
                        _openFilter();
                      },
                    ),
                    if (active)
                      Positioned(
                        top: 7,
                        right: 7,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: lc.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: lc.surface, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),

      body: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(top: 10),
        child: ValueListenableBuilder<int>(
          valueListenable: _leadNavIndex,
          builder: (context, selectedIndex, _) {
            if (selectedIndex == 0) {
              return LeadTabShell(
                key: const ValueKey('channel'),
                tabs: const ['WhatsApp Leads', 'RCS Leads'],
                showTabBar: _showTabBar,
                onScrollDirectionChanged: onScrollDirectionChanged,
                onTabChanged: (i) {
                  _channelTabIndex.value = i;
                  _showTabs();
                },
                children: [
                  WhatsappLeadsScreen(filtersNotifier: _whatsappFilters),
                  RcsLeadsScreen(filtersNotifier: _rcsFilters),
                ],
              );
            }

            return LeadTabShell(
              key: const ValueKey('web'),
              tabs: const ['AI Web Agent Leads', 'Web Form Leads'],
              showTabBar: _showTabBar,
              onScrollDirectionChanged: onScrollDirectionChanged,
              onTabChanged: (i) {
                _webTabIndex.value = i;
                _showTabs();
              },
              children: [
                AiwebLeadsScreen(filtersNotifier: _aiAgentFilters),
                const _LeadListView(
                  title: 'Web Form Leads',
                  searchHint: 'Search web form leads...',
                  leads: _webFormLeads,
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _LeadNavBar(selectedIndex: _leadNavIndex),
    );
  }
}

class _LeadNavBar extends StatelessWidget {
  final ValueNotifier<int> selectedIndex;

  const _LeadNavBar({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const items = [
      NavbarItem(icon: Icons.forum_rounded, label: 'Channel Leads'),
      NavbarItem(icon: Icons.language_rounded, label: 'Web Leads'),
    ];

    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (context, currentIndex, _) => SafeArea(
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
              final isActive = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => selectedIndex.value = i,
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
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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

class AllLeadsPage extends StatelessWidget {
  const AllLeadsPage({super.key});

  static const _allLeads = [
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

  @override
  Widget build(BuildContext context) {
    return const _LeadListView(
      title: 'All Leads',
      searchHint: 'Search leads...',
      leads: _allLeads,
      showHeader: true,
    );
  }
}

class _LeadListView extends StatelessWidget {
  final String title;
  final String searchHint;
  final List<Map<String, String>> leads;
  final bool showHeader;

  const _LeadListView({
    required this.title,
    required this.searchHint,
    required this.leads,
    this.showHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      children: [
        if (showHeader)
          HeaderSection(
            title: title,
            subtitle: '${leads.length} total contacts',
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${leads.length} leads',
                  style: TextStyle(color: c.textSecondary, fontSize: 12),
                ),
              ],
            ),
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
                  searchHint,
                  style: TextStyle(color: c.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
