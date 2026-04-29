import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/features/live_conversions/bloc/live_convertsions_bloc.dart';
import 'package:synqer_io/features/live_conversions/model/live_conversions_model.dart';
import 'package:synqer_io/features/live_conversions/widgets/conversions_card_tile.dart';

class LiveConversionsScreen extends StatelessWidget {
  const LiveConversionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LiveConvertsionsBloc(conversionsRepo: AppInjector.conversionsRepo)
            ..add(
              const FetchLiveConvertionsEvent(
                limit: '20',
                page: '1',
                isUnread: 'false',
              ),
            ),
      child: const _LiveConversionsView(),
    );
  }
}

class _LiveConversionsView extends StatefulWidget {
  const _LiveConversionsView();

  @override
  State<_LiveConversionsView> createState() => _LiveConversionsViewState();
}

class _LiveConversionsViewState extends State<_LiveConversionsView> {
  static const _pageSize = '20';

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  Timer? _debounce;
  Timer? _timeUpdateTimer;

  final _queryNotifier = ValueNotifier<String>('');
  final _onlyUnreadNotifier = ValueNotifier<bool>(false);
  final _currentTimeNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    _updateCurrentTime();
    _startTimeUpdater();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _timeUpdateTimer?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _queryNotifier.dispose();
    _onlyUnreadNotifier.dispose();
    _currentTimeNotifier.dispose();
    super.dispose();
  }

  void _startTimeUpdater() {
    _timeUpdateTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _updateCurrentTime(),
    );
  }

  void _updateCurrentTime() {
    _currentTimeNotifier.value = DateFormat('h:mm a').format(DateTime.now());
  }

  void _dispatchFetch() {
    context.read<LiveConvertsionsBloc>().add(
      FetchLiveConvertionsEvent(
        limit: _pageSize,
        page: '1',
        searchValue: _queryNotifier.value.isEmpty ? null : _queryNotifier.value,
        isUnread: _onlyUnreadNotifier.value ? 'true' : 'false',
      ),
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      _queryNotifier.value = value.trim();
      _dispatchFetch();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();

    _queryNotifier.value = '';

    _dispatchFetch();
  }

  Future<void> _onRefresh() async {
    _dispatchFetch();

    await context.read<LiveConvertsionsBloc>().stream.firstWhere(
      (s) => s is! LiveConvertsionsLoading,
    );
  }

  void _onCallTap(ConversionsChatData chat) {
    final mobile = chat.customerMobile;

    if (mobile == null || mobile.isEmpty) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Calling $mobile...')));
  }

  void _onTileTap(ConversionsChatData chat) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open chat with ${chat.customerName ?? "--"}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      children: [
        ValueListenableBuilder<String>(
          valueListenable: _currentTimeNotifier,
          builder: (context, currentTime, _) {
            return _ConversionsHeader(
              title: 'Live Conversations',
              subtitle: 'Recent customer activity',
              currentTime: currentTime,
            );
          },
        ),

        ValueListenableBuilder<bool>(
          valueListenable: _onlyUnreadNotifier,
          builder: (context, onlyUnread, _) {
            return _SearchBar(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
            );
          },
        ),

        const SizedBox(height: 12),

        ValueListenableBuilder<bool>(
          valueListenable: _onlyUnreadNotifier,
          builder: (context, onlyUnread, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterTab(
                    title: 'All',
                    selected: !onlyUnread,
                    onTap: () {
                      _onlyUnreadNotifier.value = false;
                      _dispatchFetch();
                    },
                  ),
                  const SizedBox(width: 10),
                  _FilterTab(
                    title: 'Unread',
                    selected: onlyUnread,
                    onTap: () {
                      _onlyUnreadNotifier.value = true;
                      _dispatchFetch();
                    },
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        Expanded(
          child: BlocBuilder<LiveConvertsionsBloc, LiveConvertsionsState>(
            builder: (context, state) {
              return switch (state) {
                LiveConvertsionsInitial() ||
                LiveConvertsionsLoading() => const _LoadingList(),

                LiveConvertsionsError(:final message) => _ErrorView(
                  message: message,
                  onRetry: _dispatchFetch,
                ),

                LiveConvertsionsLoaded(:final conversions) =>
                  ValueListenableBuilder2<String, bool>(
                    first: _queryNotifier,
                    second: _onlyUnreadNotifier,
                    builder: (context, query, onlyUnread, _) {
                      final hasFilter = query.isNotEmpty || onlyUnread;

                      if (conversions.isEmpty) {
                        return _EmptyView(
                          hasFilter: hasFilter,
                          onClearFilters: () {
                            _searchController.clear();

                            _queryNotifier.value = '';
                            _onlyUnreadNotifier.value = false;

                            _dispatchFetch();
                          },
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: c.primary,
                        backgroundColor: c.surface,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: conversions.length,
                          itemBuilder: (_, i) {
                            final chat = conversions[i];

                            return ConversionsCardTile(
                              chat: chat,
                              onTap: () => _onTileTap(chat),
                              onCallTap: () => _onCallTap(chat),
                            );
                          },
                        ),
                      );
                    },
                  ),
              };
            },
          ),
        ),
      ],
    );
  }
}

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> first;
  final ValueListenable<B> second;

  final Widget Function(BuildContext, A, B, Widget?) builder;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (_, a, __) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (_, b, __) {
            return builder(context, a, b, null);
          },
        );
      },
    );
  }
}

class _ConversionsHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String currentTime;

  const _ConversionsHeader({
    required this.title,
    required this.subtitle,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
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
                Row(
                  children: [
                    Text(
                      subtitle,
                      style: TextStyle(color: c.textSecondary, fontSize: 12),
                    ),
                    if (currentTime.isNotEmpty) ...[
                      Text(' • ', style: TextStyle(color: c.textSecondary)),
                      Text(
                        currentTime,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
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

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasText = controller.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: c.textSecondary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                cursorColor: c.primary,
                style: TextStyle(color: c.textPrimary, fontSize: 13.5),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: 'Search by name or number',
                  hintStyle: TextStyle(color: c.textSecondary, fontSize: 13),
                ),
              ),
            ),
            if (hasText)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  color: c.textSecondary,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? c.primary : c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? c.primary : c.border),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? c.onBrand : c.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// States: loading / empty / error
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: 8,
      itemBuilder: (_, __) => const _SkeletonTile(),
    );
  }
}

class _SkeletonTile extends StatefulWidget {
  const _SkeletonTile();

  @override
  State<_SkeletonTile> createState() => _SkeletonTileState();
}

class _SkeletonTileState extends State<_SkeletonTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = 0.4 + 0.4 * _ctrl.value;
        final base = c.surfaceHigh.withOpacity(t);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: base, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 12,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 10,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 38,
                height: 10,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onClearFilters;

  const _EmptyView({required this.hasFilter, required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.surfaceHigh,
                shape: BoxShape.circle,
                border: Border.all(color: c.border),
              ),
              child: Icon(
                hasFilter
                    ? Icons.search_off_rounded
                    : Icons.chat_bubble_outline_rounded,
                color: c.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter ? 'No matching conversations' : 'No conversations yet',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilter
                  ? 'Try a different search or clear filters'
                  : 'When customers message you, they\'ll show up here',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary, fontSize: 12.5),
            ),
            if (hasFilter) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onClearFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: c.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Clear filters',
                    style: TextStyle(
                      color: c.onBrand,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.error.withOpacity(0.10),
                shape: BoxShape.circle,
                border: Border.all(color: c.error.withOpacity(0.35)),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: c.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: c.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: c.onBrand, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Retry',
                      style: TextStyle(
                        color: c.onBrand,
                        fontSize: 13,
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
    );
  }
}
