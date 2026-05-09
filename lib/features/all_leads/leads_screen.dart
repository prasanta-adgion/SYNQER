// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:synqer_io/core/model/navbar_item_model.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/custom_appbar.dart';
import 'package:synqer_io/features/dashboard/widgets/header_section.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final ValueNotifier<int> _leadNavIndex = ValueNotifier(0);

  static const _rcsLeads = [
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
      'name': 'Karan Mehta',
      'phone': '+91 65432 10987',
      'tag': 'Hot',
      'time': '1d ago',
    },
  ];

  static const _whatsappLeads = [
    {
      'name': 'Priya Nair',
      'phone': '+91 76543 21098',
      'tag': 'Cold',
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

  static const _aiAgentLeads = [
    {
      'name': 'Meera Kapoor',
      'phone': '+91 99887 77665',
      'tag': 'Hot',
      'time': '18m ago',
    },
    {
      'name': 'Dev Malhotra',
      'phone': '+91 88776 66554',
      'tag': 'Warm',
      'time': '3h ago',
    },
    {
      'name': 'Nisha Rao',
      'phone': '+91 77665 55443',
      'tag': 'Cold',
      'time': '7h ago',
    },
  ];

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

  @override
  void dispose() {
    _leadNavIndex.dispose();
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
      ),

      body: SafeArea(
        top: false,
        minimum: EdgeInsets.only(top: 10),
        child: ValueListenableBuilder<int>(
          valueListenable: _leadNavIndex,
          builder: (context, selectedIndex, _) {
            if (selectedIndex == 0) {
              return const _LeadTabShell(
                tabs: ['WhatsApp Leads', 'RCS Leads'],
                children: [
                  _LeadListView(
                    title: 'WhatsApp Leads',
                    searchHint: 'Search WhatsApp leads...',
                    leads: _whatsappLeads,
                  ),
                  _LeadListView(
                    title: 'RCS Leads',
                    searchHint: 'Search RCS leads...',
                    leads: _rcsLeads,
                  ),
                ],
              );
            }

            return const _LeadTabShell(
              tabs: ['AI Web Agent Leads', 'Web Form Leads'],
              children: [
                _LeadListView(
                  title: 'AI Web Agent Leads',
                  searchHint: 'Search AI web agent leads...',
                  leads: _aiAgentLeads,
                ),
                _LeadListView(
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

class _LeadTabShell extends StatelessWidget {
  final List<String> tabs;
  final List<Widget> children;

  const _LeadTabShell({required this.tabs, required this.children});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          Container(
            height: 45,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: c.border),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: c.primary,
                borderRadius: BorderRadius.circular(35),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: c.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              tabs: tabs.map((x) => Tab(text: x)).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: TabBarView(children: children)),
        ],
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
              return _LeadCard(lead: leads[i]);
            },
          ),
        ),
      ],
    );
  }
}

class _LeadCard extends StatelessWidget {
  final Map<String, String> lead;

  const _LeadCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tag = lead['tag'] ?? '';
    final tagColor = tag == 'Hot'
        ? c.error
        : tag == 'Warm'
        ? c.primary
        : c.textSecondary;
    final name = lead['name'] ?? '';

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
                name.isEmpty ? '?' : name[0],
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
                  name,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lead['phone'] ?? '',
                  style: TextStyle(color: c.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Badge(label: tag, color: tagColor),
              const SizedBox(height: 5),
              Text(
                lead['time'] ?? '',
                style: TextStyle(color: c.textSecondary, fontSize: 10),
              ),
            ],
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
