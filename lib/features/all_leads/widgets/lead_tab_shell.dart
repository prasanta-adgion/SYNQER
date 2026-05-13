import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';

class LeadTabShell extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> children;
  final void Function(int index)? onTabChanged;
  final ValueListenable<bool>? showTabBar;
  final void Function(ScrollDirection direction)? onScrollDirectionChanged;

  const LeadTabShell({
    super.key,
    required this.tabs,
    required this.children,
    this.onTabChanged,
    this.showTabBar,
    this.onScrollDirectionChanged,
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
        _AnimatedTabBar(
          visibleListenable: widget.showTabBar,
          child: Container(
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
        ),
        Expanded(
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              widget.onScrollDirectionChanged?.call(notification.direction);
              return false;
            },
            child: TabBarView(controller: _tab, children: widget.children),
          ),
        ),
      ],
    );
  }
}

class _AnimatedTabBar extends StatelessWidget {
  final ValueListenable<bool>? visibleListenable;
  final Widget child;

  const _AnimatedTabBar({required this.visibleListenable, required this.child});

  @override
  Widget build(BuildContext context) {
    final listenable = visibleListenable;

    if (listenable == null) {
      return Padding(padding: const EdgeInsets.only(bottom: 12), child: child);
    }

    return ValueListenableBuilder<bool>(
      valueListenable: listenable,
      builder: (context, visible, _) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: visible
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: child,
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
