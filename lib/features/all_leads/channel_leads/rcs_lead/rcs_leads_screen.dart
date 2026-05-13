// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/features/all_leads/channel_leads/rcs_lead/bloc/rcs_leadsget_bloc.dart';
import 'package:synqer_io/features/all_leads/channel_leads/rcs_lead/model/rcsleads_data_model.dart';
import 'package:synqer_io/features/all_leads/widgets/empty_view.dart';
import 'package:synqer_io/features/search_bar/search_bar_screen.dart';

// ─── Filter helpers ───────────────────────────────────────────────────────────

String? _mapEventType(String? raw) {
  switch (raw) {
    case 'Button Click':
      return 'response';
    case 'Text Message':
      return 'text_message';
    default:
      return null;
  }
}

String? _fmtDate(DateTime? date) =>
    date != null ? DateFormat('yyyy-MM-dd').format(date) : null;

// ─── Screen ───────────────────────────────────────────────────────────────────

class RcsLeadsScreen extends StatelessWidget {
  final ValueNotifier<Map<String, dynamic>>? filtersNotifier;

  const RcsLeadsScreen({super.key, this.filtersNotifier});

  @override
  Widget build(BuildContext context) {
    final initialFilters = filtersNotifier?.value ?? const {};
    return BlocProvider(
      create: (_) =>
          RcsLeadsgetBloc(rcsLeadsRepo: AppInjector.rcsLeadsRepo)..add(
            FetchRcsLeadsEvent(
              eventType: _mapEventType(initialFilters['eventType'] as String?),
              fromDate: _fmtDate(initialFilters['fromDate'] as DateTime?),
              toDate: _fmtDate(initialFilters['toDate'] as DateTime?),
            ),
          ),
      child: _RcsLeadsView(filtersNotifier: filtersNotifier),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────

class _RcsLeadsView extends StatefulWidget {
  final ValueNotifier<Map<String, dynamic>>? filtersNotifier;

  const _RcsLeadsView({this.filtersNotifier});

  @override
  State<_RcsLeadsView> createState() => _RcsLeadsViewState();
}

class _RcsLeadsViewState extends State<_RcsLeadsView> {
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
    context.read<RcsLeadsgetBloc>().add(
      FetchRcsLeadsEvent(
        eventType: _mapEventType(filters['eventType'] as String?),
        fromDate: _fmtDate(filters['fromDate'] as DateTime?),
        toDate: _fmtDate(filters['toDate'] as DateTime?),
      ),
    );
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final offset = _scrollCtrl.offset;
    final max = _scrollCtrl.position.maxScrollExtent;
    if (offset < max - _scrollTriggerOffset) return;

    final bloc = context.read<RcsLeadsgetBloc>();
    final state = bloc.state;
    if (state is! RcsLeadsLoaded || !state.hasMore || state.isLoadingMore) {
      return;
    }

    final nextPage = state.currentPage + 1;
    if (_trackedLoadPage == nextPage) return;
    _trackedLoadPage = nextPage;

    bloc.add(
      LoadMoreRcsLeads(
        page: nextPage,
        limit: _pageSize,
        searchValue: state.searchValue,
        eventType: state.eventType,
        fromDate: state.dateFrom,
        toDate: state.dateTo,
      ),
    );
  }

  void _onSearchChanged(String query) {
    _trackedLoadPage = null;
    final filters = widget.filtersNotifier?.value ?? const {};
    context.read<RcsLeadsgetBloc>().add(
      FetchRcsLeadsEvent(
        searchValue: query.trim().isEmpty ? null : query.trim(),
        eventType: _mapEventType(filters['eventType'] as String?),
        fromDate: _fmtDate(filters['fromDate'] as DateTime?),
        toDate: _fmtDate(filters['toDate'] as DateTime?),
      ),
    );
  }

  void _retry() {
    _trackedLoadPage = null;
    final filters = widget.filtersNotifier?.value ?? const {};
    context.read<RcsLeadsgetBloc>().add(
      FetchRcsLeadsEvent(
        eventType: _mapEventType(filters['eventType'] as String?),
        fromDate: _fmtDate(filters['fromDate'] as DateTime?),
        toDate: _fmtDate(filters['toDate'] as DateTime?),
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
                      'RCS Leads',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  BlocBuilder<RcsLeadsgetBloc, RcsLeadsgetState>(
                    buildWhen: (p, n) =>
                        (p is RcsLeadsLoaded) != (n is RcsLeadsLoaded) ||
                        (n is RcsLeadsLoaded &&
                            p is RcsLeadsLoaded &&
                            p.rcsLeads.length != n.rcsLeads.length),
                    builder: (_, state) {
                      if (state is! RcsLeadsLoaded) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: c.accentSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${state.rcsLeads.length} leads',
                          style: TextStyle(
                            color: c.primary,
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
                hintText: 'Search by mobile number...',
                debounceDuration: const Duration(milliseconds: 500),
                onChanged: _onSearchChanged,
              ),
            ],
          ),
        ),

        // ── Content ────────────────────────────────────────────────────────────
        Expanded(
          child: BlocBuilder<RcsLeadsgetBloc, RcsLeadsgetState>(
            builder: (context, state) {
              if (state is RcsLeadsgetInitial || state is RcsLeadsgetLoading) {
                return const _LoadingView();
              }
              if (state is RcsLeadsgetError) {
                return _ErrorView(message: state.errorMessage, onRetry: _retry);
              }
              if (state is RcsLeadsLoaded) {
                if (state.rcsLeads.isEmpty) {
                  return EmptyView(
                    title: 'No RCS Leads Found',
                    subtitle:
                        'No leads match your current filters.\nTry adjusting the search or filter options.',
                    iconWidget: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: c.accentSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.inbox_rounded,
                        color: c.primary,
                        size: 32,
                      ),
                    ),
                  );
                }
                return _LeadsList(
                  leads: state.rcsLeads,
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

// ─── Lead List ────────────────────────────────────────────────────────────────

class _LeadsList extends StatelessWidget {
  final List<RcsLeadsDataModel> leads;
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
        return _RcsLeadCard(lead: leads[index]);
      },
    );
  }
}

// ─── Lead Card ────────────────────────────────────────────────────────────────

class _RcsLeadCard extends StatelessWidget {
  final RcsLeadsDataModel lead;
  const _RcsLeadCard({required this.lead});

  Interaction? get _lastInteraction =>
      lead.interactions.isNotEmpty ? lead.interactions.last : null;

  String get _previewText {
    final last = _lastInteraction;
    if (last == null) return 'No interactions yet';
    if (last.isTextMessage && (last.textMessage?.isNotEmpty ?? false)) {
      return last.textMessage!;
    }
    if (last.isResponse && (last.responseText?.isNotEmpty ?? false)) {
      return last.responseText!;
    }
    return 'Interaction recorded';
  }

  String _formatTimestamp(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('dd MMM').format(dt);
    } catch (_) {
      return '';
    }
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => SafeArea(child: _RcsLeadDetailSheet(lead: lead)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final last = _lastInteraction;
    final timeStamp = last != null
        ? _formatTimestamp(last.eventTimestamp ?? last.createdAt)
        : '';
    final count = lead.interactions.length;

    return GestureDetector(
      onTap: () => _showDetailSheet(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: last == null
                    ? c.surfaceHigh
                    : last.isTextMessage
                    ? c.successSoft
                    : c.accentSoft,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: last == null
                      ? c.border
                      : last.isTextMessage
                      ? c.green.withOpacity(0.25)
                      : c.primary.withOpacity(0.25),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                last == null
                    ? Icons.phone_rounded
                    : last.isTextMessage
                    ? Icons.message_rounded
                    : Icons.touch_app_rounded,
                size: 20,
                color: last == null
                    ? c.textMuted
                    : last.isTextMessage
                    ? c.green
                    : c.primary,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mobile + timestamp row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          lead.mobile ?? 'Unknown',
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeStamp.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          timeStamp,
                          style: TextStyle(
                            color: c.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Last interaction preview
                  Text(
                    _previewText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 9),

                  // Footer: interaction count + event type chip
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 12,
                        color: c.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$count interaction${count == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: c.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (last != null) _EventTypeChip(interaction: last),
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
}

// ─── Event Type Chip ──────────────────────────────────────────────────────────

class _EventTypeChip extends StatelessWidget {
  final Interaction interaction;
  const _EventTypeChip({required this.interaction});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isText = interaction.isTextMessage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isText ? c.successSoft : c.accentSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isText
              ? c.green.withOpacity(0.25)
              : c.primary.withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isText ? Icons.message_rounded : Icons.touch_app_rounded,
            size: 10,
            color: isText ? c.green : c.primary,
          ),
          const SizedBox(width: 4),
          Text(
            isText ? 'Text' : 'Button',
            style: TextStyle(
              color: isText ? c.green : c.primary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Lead Detail Sheet ────────────────────────────────────────────────────────

class _RcsLeadDetailSheet extends StatelessWidget {
  final RcsLeadsDataModel lead;
  const _RcsLeadDetailSheet({required this.lead});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final interactions = lead.interactions;
    final last = interactions.isNotEmpty ? interactions.last : null;
    final textCount = interactions.where((i) => i.isTextMessage).length;
    final buttonCount = interactions.where((i) => i.isResponse).length;

    return Container(
      decoration: BoxDecoration(
        color: c.bottomSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: c.borderStrong),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Drag handle ──────────────────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.bottomSheetHandle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ───────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: last == null
                        ? c.surfaceHigh
                        : last.isTextMessage
                        ? c.successSoft
                        : c.accentSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: last == null
                          ? c.border
                          : last.isTextMessage
                          ? c.green.withOpacity(0.25)
                          : c.primary.withOpacity(0.25),
                    ),
                  ),
                  child: Icon(
                    last == null
                        ? Icons.phone_rounded
                        : last.isTextMessage
                        ? Icons.message_rounded
                        : Icons.touch_app_rounded,
                    size: 22,
                    color: last == null
                        ? c.textMuted
                        : last.isTextMessage
                        ? c.green
                        : c.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.mobile ?? 'Unknown',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _StatPill(
                            icon: Icons.message_rounded,
                            label: '$textCount text',
                            color: c.green,
                            bg: c.successSoft,
                          ),
                          const SizedBox(width: 6),
                          _StatPill(
                            icon: Icons.touch_app_rounded,
                            label: '$buttonCount button',
                            color: c.primary,
                            bg: c.accentSoft,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Close button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: c.textSecondary,
                    size: 18,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: c.surfaceHigh,
                    minimumSize: const Size(36, 36),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: c.border, height: 1),

          // ── Interactions section ──────────────────────────────────────────────
          if (interactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_rounded, color: c.textMuted, size: 36),
                  const SizedBox(height: 10),
                  Text(
                    'No interactions recorded',
                    style: TextStyle(color: c.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  Text(
                    'INTERACTIONS',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: c.surfaceHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${interactions.length} total',
                      style: TextStyle(
                        color: c.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                shrinkWrap: true,
                itemCount: interactions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, index) => _InteractionTile(
                  interaction: interactions[index],
                  index: index,
                  total: interactions.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Stat Pill ────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Interaction Tile ─────────────────────────────────────────────────────────

class _InteractionTile extends StatelessWidget {
  final Interaction interaction;
  final int index;
  final int total;

  const _InteractionTile({
    required this.interaction,
    required this.index,
    required this.total,
  });

  String _fmtFull(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      return DateFormat(
        'dd MMM yyyy, h:mm a',
      ).format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isText = interaction.isTextMessage;
    final ts = _fmtFull(interaction.eventTimestamp ?? interaction.createdAt);
    final isLast = index == total - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline column ─────────────────────────────────────────────────
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isText ? c.successSoft : c.accentSoft,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isText
                          ? c.green.withOpacity(0.25)
                          : c.primary.withOpacity(0.25),
                    ),
                  ),
                  child: Icon(
                    isText ? Icons.message_rounded : Icons.touch_app_rounded,
                    size: 14,
                    color: isText ? c.green : c.primary,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: c.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Content ──────────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type + timestamp
                  Row(
                    children: [
                      Text(
                        isText ? 'Text Message' : 'Button Click',
                        style: TextStyle(
                          color: isText ? c.green : c.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (ts.isNotEmpty)
                        Text(
                          ts,
                          style: TextStyle(
                            color: c.textMuted,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Text message content
                  if (isText && (interaction.textMessage?.isNotEmpty ?? false))
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: c.surfaceHigh,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: c.border),
                      ),
                      child: Text(
                        interaction.textMessage!,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),

                  // Button response content
                  if (!isText) ...[
                    if (interaction.responseText?.isNotEmpty ?? false)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: c.accentSoft,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: c.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              size: 13,
                              color: c.primary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                interaction.responseText!,
                                style: TextStyle(
                                  color: c.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (interaction.responsePostback?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Row(
                          children: [
                            Icon(
                              Icons.data_object_rounded,
                              size: 12,
                              color: c.textMuted,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                interaction.responsePostback!,
                                style: TextStyle(
                                  color: c.textMuted,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (interaction.suggestionType?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Row(
                          children: [
                            Icon(
                              Icons.label_outline_rounded,
                              size: 12,
                              color: c.textMuted,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              interaction.suggestionType!,
                              style: TextStyle(
                                color: c.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer Loading ──────────────────────────────────────────────────────────

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
      end: 0.8,
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Bone(width: 46, height: 46, borderRadius: 13, color: shim),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Bone(width: 140, height: 13, color: shim),
                        const Spacer(),
                        _Bone(width: 44, height: 10, color: shim),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _Bone(height: 11, color: shim),
                    const SizedBox(height: 5),
                    _Bone(width: 210, height: 11, color: shim),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _Bone(width: 90, height: 10, color: shim),
                        const Spacer(),
                        _Bone(
                          width: 52,
                          height: 18,
                          borderRadius: 20,
                          color: shim,
                        ),
                      ],
                    ),
                  ],
                ),
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

// ─── Error View ───────────────────────────────────────────────────────────────

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

// ─── Empty View ───────────────────────────────────────────────────────────────
