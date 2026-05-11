import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';

class LeadTabShell extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> children;
  final void Function(int index)? onTabChanged;

  const LeadTabShell({
    super.key,
    required this.tabs,
    required this.children,
    this.onTabChanged,
  });

  @override
  State<LeadTabShell> createState() => _LeadTabShellState();
}

class _LeadTabShellState extends State<LeadTabShell>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: widget.tabs.length, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) {
        widget.onTabChanged?.call(_tab.index);
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
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
            controller: _tab,
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
            tabs: widget.tabs.map((x) => Tab(text: x)).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TabBarView(controller: _tab, children: widget.children),
        ),
      ],
    );
  }
}
