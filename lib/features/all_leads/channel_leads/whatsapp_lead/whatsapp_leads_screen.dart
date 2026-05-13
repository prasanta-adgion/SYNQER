// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/features/all_leads/channel_leads/whatsapp_lead/bloc/whatsappleads_get_bloc.dart';
import 'package:synqer_io/features/all_leads/channel_leads/whatsapp_lead/model/whatsappleads_data_model.dart';
import 'package:synqer_io/features/all_leads/channel_leads/whatsapp_lead/widgets/lead_card_tile.dart';
import 'package:synqer_io/features/all_leads/widgets/empty_view.dart';
import 'package:synqer_io/features/search_bar/search_bar_screen.dart';

// ─── Filter value mappers ──────────────────────────────────────────────────────

String? _mapStatus(String? raw) {
  switch (raw) {
    case null:
    case 'All':
      return null;
    case 'Follow Up':
      return 'Follow Up';
    case 'Not Interested':
      return 'Not+Interested';
    // case 'Interested':
    //   return 'Interested';
    // case 'Closed':
    //   return 'Closed';
    default:
      return raw; // Pending, Interested, Closed pass through
  }
}

String? _mapLeadType(String? raw) {
  switch (raw) {
    case null:
    case 'All':
      return null;
    case 'General Enquiry':
      return 'general enquiry';
    case 'Lead':
      return 'lead';
    default:
      return null;
  }
}

class WhatsappLeadsScreen extends StatelessWidget {
  final ValueNotifier<Map<String, dynamic>>? filtersNotifier;

  const WhatsappLeadsScreen({super.key, this.filtersNotifier});

  @override
  Widget build(BuildContext context) {
    final initialFilters = filtersNotifier?.value ?? const {};
    return BlocProvider(
      create: (_) =>
          WhatsappleadsGetBloc(whatsappLeadsRepo: AppInjector.whatsappLeadsRepo)
            ..add(
              FetchWhatsappLeadsEvent(
                status: _mapStatus(initialFilters['status'] as String?),
                leadType: _mapLeadType(initialFilters['leadType'] as String?),
              ),
            ),
      child: _WhatsappLeadsView(filtersNotifier: filtersNotifier),
    );
  }
}

// ─── View ───────

class _WhatsappLeadsView extends StatefulWidget {
  final ValueNotifier<Map<String, dynamic>>? filtersNotifier;

  const _WhatsappLeadsView({this.filtersNotifier});

  @override
  State<_WhatsappLeadsView> createState() => _WhatsappLeadsViewState();
}

class _WhatsappLeadsViewState extends State<_WhatsappLeadsView> {
  static const int _pageSize = 20;
  static const double _scrollTriggerOffset = 200.0;

  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  int? _trackedLoadPage;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    widget.filtersNotifier?.addListener(_onFiltersChanged);
  }

  @override
  void dispose() {
    widget.filtersNotifier?.removeListener(_onFiltersChanged);
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onFiltersChanged() {
    if (!mounted) return;
    final filters = widget.filtersNotifier!.value;
    _searchCtrl.clear();
    _trackedLoadPage = null;
    context.read<WhatsappleadsGetBloc>().add(
      FetchWhatsappLeadsEvent(
        status: _mapStatus(filters['status'] as String?),
        leadType: _mapLeadType(filters['leadType'] as String?),
      ),
    );
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final offset = _scrollCtrl.offset;
    final max = _scrollCtrl.position.maxScrollExtent;
    if (offset < max - _scrollTriggerOffset) return;

    final bloc = context.read<WhatsappleadsGetBloc>();
    final state = bloc.state;
    if (state is! WhatsappleadsLoaded ||
        !state.hasMore ||
        state.isLoadingMore) {
      return;
    }

    final nextPage = state.currentPage + 1;
    if (_trackedLoadPage == nextPage) return;
    _trackedLoadPage = nextPage;

    bloc.add(
      LoadMoreWhatsappLeads(
        page: nextPage,
        limit: _pageSize,
        searchValue: state.searchValue,
        status: state.status,
        leadType: state.leadType,
      ),
    );
  }

  void _onSearchChanged(String query) {
    _trackedLoadPage = null;
    final filters = widget.filtersNotifier?.value ?? const {};
    context.read<WhatsappleadsGetBloc>().add(
      FetchWhatsappLeadsEvent(
        searchValue: query.trim().isEmpty ? null : query.trim(),
        status: _mapStatus(filters['status'] as String?),
        leadType: _mapLeadType(filters['leadType'] as String?),
      ),
    );
  }

  void _retry() {
    _trackedLoadPage = null;
    final filters = widget.filtersNotifier?.value ?? const {};
    context.read<WhatsappleadsGetBloc>().add(
      FetchWhatsappLeadsEvent(
        status: _mapStatus(filters['status'] as String?),
        leadType: _mapLeadType(filters['leadType'] as String?),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      children: [
        // ── Header + Search ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'WhatsApp Leads',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  BlocBuilder<WhatsappleadsGetBloc, WhatsappleadsGetState>(
                    buildWhen: (p, n) =>
                        (p is WhatsappleadsLoaded) !=
                            (n is WhatsappleadsLoaded) ||
                        (n is WhatsappleadsLoaded &&
                            p is WhatsappleadsLoaded &&
                            p.leads.length != n.leads.length),
                    builder: (_, state) {
                      if (state is! WhatsappleadsLoaded) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x26059669),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${state.leads.length} leads',
                          style: const TextStyle(
                            color: Color(0xFF059669),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ReusableSearchBar(
                controller: _searchCtrl,
                hintText: 'Search by name or phone...',
                debounceDuration: const Duration(milliseconds: 500),
                onChanged: _onSearchChanged,
              ),
            ],
          ),
        ),

        // ── Content ────────────────────────────────────────────────────────────
        Expanded(
          child: BlocBuilder<WhatsappleadsGetBloc, WhatsappleadsGetState>(
            builder: (context, state) {
              if (state is WhatsappleadsGetInitial ||
                  state is WhatsappleadsGetLoading) {
                return const _LoadingView();
              }
              if (state is WhatsappleadsGetError) {
                return _ErrorView(message: state.errorMessage, onRetry: _retry);
              }
              if (state is WhatsappleadsLoaded) {
                if (state.leads.isEmpty) {
                  return EmptyView(
                    title: 'No WhatsApp Leads Found',
                    subtitle:
                        'No leads match your current filters.\nTry adjusting the search or filter options.',
                    iconWidget: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0x26059669),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.inbox_rounded,
                        color: Color(0xFF059669),
                        size: 32,
                      ),
                    ),
                  );
                }
                return _LeadsList(
                  leads: state.leads,
                  hasMore: state.hasMore,
                  isLoadingMore: state.isLoadingMore,
                  scrollController: _scrollCtrl,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

// ─── Leads list ─────

class _LeadsList extends StatelessWidget {
  final List<WhatsappLeadsDataModel> leads;
  final bool hasMore;
  final bool isLoadingMore;
  final ScrollController scrollController;

  const _LeadsList({
    required this.leads,
    required this.hasMore,
    required this.isLoadingMore,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: leads.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index >= leads.length) return const _LoadMoreIndicator();
        return LeadCardTile(
          lead: leads[index],
          onRefresh: () async {
            context.read<WhatsappleadsGetBloc>().add(FetchWhatsappLeadsEvent());
          },
        );
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => const _ShimmerCard(),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.4,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
      animation: _anim,
      builder: (_, _) {
        final shim = c.surfaceHigh.withOpacity(_anim.value);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bone(width: 44, height: 44, borderRadius: 13, color: shim),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _Bone(width: 130, height: 13, color: shim),
                            const Spacer(),
                            _Bone(
                              width: 60,
                              height: 20,
                              borderRadius: 20,
                              color: shim,
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        _Bone(width: 100, height: 11, color: shim),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Bone(height: 1, color: shim),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Bone(width: 90, height: 20, borderRadius: 8, color: shim),
                  const Spacer(),
                  _Bone(width: 70, height: 11, color: shim),
                ],
              ),
              const SizedBox(height: 10),
              _Bone(height: 1, color: shim),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _Bone(height: 32, borderRadius: 10, color: shim),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Bone(height: 32, borderRadius: 10, color: shim),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Bone extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color color;

  const _Bone({
    this.width,
    required this.height,
    this.borderRadius = 6,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ─── Load more indicator ──────────────────────────────────────────────────────

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: c.primary),
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
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: c.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, color: c.error, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load leads',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
