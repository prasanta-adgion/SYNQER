// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/features/all_leads/channel_leads/whatsapp_lead/bloc/whatsappleads_get_bloc.dart';
import 'package:synqer_io/features/all_leads/channel_leads/whatsapp_lead/model/whatsappleads_data_model.dart';

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

// ─── Shared helpers ───────────────────────────────────────────────────────────

String _fmtPhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12 && digits.startsWith('91')) {
    final local = digits.substring(2);
    return '+91 ${local.substring(0, 5)} ${local.substring(5)}';
  }
  if (digits.length == 10) {
    return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
  }
  return raw.isNotEmpty ? '+$raw' : '—';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

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

// ─── View ─────────────────────────────────────────────────────────────────────

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
  Timer? _debounce;
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
    _debounce?.cancel();
    super.dispose();
  }

  void _onFiltersChanged() {
    if (!mounted) return;
    final filters = widget.filtersNotifier!.value;
    _searchCtrl.clear();
    _debounce?.cancel();
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
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _trackedLoadPage = null;
      final filters = widget.filtersNotifier?.value ?? const {};
      context.read<WhatsappleadsGetBloc>().add(
        FetchWhatsappLeadsEvent(
          searchValue: query.trim().isEmpty ? null : query.trim(),
          status: _mapStatus(filters['status'] as String?),
          leadType: _mapLeadType(filters['leadType'] as String?),
        ),
      );
    });
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: c.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: _onSearchChanged,
                        style: TextStyle(color: c.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search by name or phone...',
                          hintStyle: TextStyle(
                            color: c.textSecondary,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchCtrl,
                      builder: (_, val, _) {
                        if (val.text.isEmpty) return const SizedBox.shrink();
                        return GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            _onSearchChanged('');
                          },
                          child: Icon(
                            Icons.close_rounded,
                            color: c.textSecondary,
                            size: 16,
                          ),
                        );
                      },
                    ),
                  ],
                ),
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
                if (state.leads.isEmpty) return const _EmptyView();
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

// ─── Leads list ───────────────────────────────────────────────────────────────

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
        return _LeadCard(lead: leads[index]);
      },
    );
  }
}

// ─── Lead Card ────────────────────────────────────────────────────────────────

class _LeadCard extends StatelessWidget {
  final WhatsappLeadsDataModel lead;

  const _LeadCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final name = lead.name ?? 'Unknown';
    final phone = _fmtPhone(lead.phoneNumber ?? '');
    final leadType = lead.leadType ?? '';
    final status = lead.status ?? '';
    final remark = lead.remark ?? '';
    final queries = (lead.query ?? []).whereType<String>().toList();
    final date = lead.enquiryDate ?? '';

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top: avatar + name/phone + status ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(name: name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 12,
                            color: c.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (status.isNotEmpty) _StatusBadge(status: status),
              ],
            ),
          ),

          Divider(height: 1, color: c.border),

          // ── Meta: lead type + enquiry date ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                if (leadType.isNotEmpty) _LeadTypeBadge(type: leadType),
                const Spacer(),
                if (date.isNotEmpty) ...[
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: c.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Queries ──
          if (queries.isNotEmpty) ...[
            Divider(height: 1, color: c.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QUERIES',
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...queries.map(
                    (q) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              q,
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 12.5,
                              ),
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

          // ── Remark ──
          if (remark.isNotEmpty) ...[
            Divider(height: 1, color: c.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_rounded, size: 13, color: c.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      remark,
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Actions ──
          Divider(height: 1, color: c.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    color: c.primary,
                    background: c.accentSoft,
                    onTap: () => _showEditDialog(context, lead),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    color: c.error,
                    background: c.dangerSoft,
                    onTap: () => _showDeleteDialog(context, lead),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WhatsappLeadsDataModel lead) {
    _EditLeadBottomSheet.show(context, lead);
  }

  void _showDeleteDialog(BuildContext context, WhatsappLeadsDataModel lead) {
    final c = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete Lead',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${lead.name ?? 'this lead'}"? This action cannot be undone.',
          style: TextStyle(color: c.textSecondary, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Delete',
              style: TextStyle(color: c.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF34D399)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = _colors(c);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.30), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            _displayStatus,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // API returns "Follow+Up" / "Not+Interested" — normalize for display
  String get _displayStatus => status.replaceAll('+', ' ');

  (Color, Color) _colors(dynamic c) {
    final normalized = status.replaceAll('+', ' ');
    return switch (normalized) {
      'Pending' => (c.warningSoft as Color, c.warning as Color),
      'Follow Up' => (c.accentSoft as Color, c.primary as Color),
      'Interested' => (c.successSoft as Color, c.green as Color),
      'Not Interested' => (c.dangerSoft as Color, c.error as Color),
      'Closed' => (c.surfaceHigh as Color, c.textSecondary as Color),
      _ => (c.surfaceHigh as Color, c.textSecondary as Color),
    };
  }

  IconData get _icon {
    final normalized = status.replaceAll('+', ' ');
    return switch (normalized) {
      'Pending' => Icons.schedule_rounded,
      'Follow Up' => Icons.phone_callback_rounded,
      'Interested' => Icons.thumb_up_outlined,
      'Not Interested' => Icons.thumb_down_outlined,
      'Closed' => Icons.check_circle_outline_rounded,
      _ => Icons.info_outline_rounded,
    };
  }
}

// ─── Lead type badge ──────────────────────────────────────────────────────────

class _LeadTypeBadge extends StatelessWidget {
  final String type;
  const _LeadTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final normalized = type.replaceAll('+', ' ').toLowerCase();
    final isLead = normalized == 'lead';
    final bg = isLead ? c.accentSoft : const Color(0x26413D81);
    final fg = isLead ? c.primary : const Color(0xFF413D81);
    final label = isLead ? 'Lead' : 'General Enquiry';
    final icon = isLead
        ? Icons.person_outline_rounded
        : Icons.chat_bubble_outline_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Edit lead bottom sheet ───────────────────────────────────────────────────

class _EditLeadBottomSheet extends StatefulWidget {
  final WhatsappLeadsDataModel lead;

  const _EditLeadBottomSheet({required this.lead});

  static Future<void> show(BuildContext context, WhatsappLeadsDataModel lead) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => SafeArea(child: _EditLeadBottomSheet(lead: lead)),
    );
  }

  @override
  State<_EditLeadBottomSheet> createState() => _EditLeadBottomSheetState();
}

class _EditLeadBottomSheetState extends State<_EditLeadBottomSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _remarkCtrl;
  late String _selectedStatus;
  late String _selectedLeadType;

  static const _statuses = [
    'Pending',
    'Follow Up',
    'Interested',
    'Not Interested',
    'Closed',
  ];
  static const _leadTypes = ['Lead', 'General Enquiry'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.lead.name ?? '');
    _remarkCtrl = TextEditingController(text: widget.lead.remark ?? '');
    _selectedStatus = (widget.lead.status ?? 'Pending').replaceAll('+', ' ');
    final raw = (widget.lead.leadType ?? '').replaceAll('+', ' ').toLowerCase();
    _selectedLeadType = raw == 'lead' ? 'Lead' : 'General Enquiry';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final phone = _fmtPhone(widget.lead.phoneNumber ?? '');

    return Container(
      decoration: BoxDecoration(
        color: c.bottomSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: c.borderStrong),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Drag handle ──
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.bottomSheetHandle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 16, 16),
            child: Row(
              children: [
                _LargeAvatar(name: widget.lead.name ?? '?'),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lead.name ?? 'Unknown',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        phone,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
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

          Divider(height: 1, color: c.border),

          // ── Scrollable body ──
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoGrid(lead: widget.lead),
                  const SizedBox(height: 20),
                  Divider(height: 1, color: c.border),
                  const SizedBox(height: 20),

                  Text(
                    'EDIT DETAILS',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                    ),
                  ),
                  const SizedBox(height: 18),

                  _FieldLabel('Name'),
                  const SizedBox(height: 6),
                  _InputField(controller: _nameCtrl, hint: 'Enter name'),
                  const SizedBox(height: 18),

                  _FieldLabel('Lead Type'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _leadTypes
                        .map(
                          (t) => _SelectChip(
                            label: t,
                            isSelected: _selectedLeadType == t,
                            onTap: () => setState(() => _selectedLeadType = t),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),

                  _FieldLabel('Status'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _statuses
                        .map(
                          (s) => _SelectChip(
                            label: s,
                            isSelected: _selectedStatus == s,
                            onTap: () => setState(() => _selectedStatus = s),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),

                  _FieldLabel('Remark'),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: _remarkCtrl,
                    hint: 'Add notes or follow-up remarks...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: c.border),

          // ── Footer ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.textSecondary,
                      side: BorderSide(color: c.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.save_rounded, size: 17),
                    label: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
}

// ─── Large avatar (bottom sheet header) ──────────────────────────────────────

class _LargeAvatar extends StatelessWidget {
  final String name;
  const _LargeAvatar({required this.name});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF34D399)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Read-only info grid ──────────────────────────────────────────────────────

class _InfoGrid extends StatelessWidget {
  final WhatsappLeadsDataModel lead;
  const _InfoGrid({required this.lead});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final raw = (lead.leadType ?? '').replaceAll('+', ' ').toLowerCase();
    final displayType = raw == 'lead'
        ? 'Lead'
        : raw.isNotEmpty
        ? 'General Enquiry'
        : '—';

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _InfoCell(label: 'LEAD TYPE', value: displayType),
                ),
                VerticalDivider(width: 1, color: c.border),
                Expanded(
                  child: _InfoCell(
                    label: 'BRAND NUMBER',
                    value: lead.brandNumber ?? '—',
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.border),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _InfoCell(
                    label: 'ENQUIRY DATE',
                    value: (lead.enquiryDate ?? '').isNotEmpty
                        ? lead.enquiryDate!
                        : '—',
                  ),
                ),
                VerticalDivider(width: 1, color: c.border),
                Expanded(
                  child: _InfoCell(
                    label: 'CREATED AT',
                    value: lead.createDate ?? '-',
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

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: c.textMuted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Field label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: c.textSecondary,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9,
      ),
    );
  }
}

// ─── Styled input ─────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        color: c.inputText,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.inputHint, fontSize: 13.5),
        filled: true,
        fillColor: c.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.inputBorderFocus, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Selectable chip ─────────────────────────────────────────────────────────

class _SelectChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? c.primary : c.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? c.primary : c.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : c.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer loading ──────────────────────────────────────────────────────────

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

// ─── Empty view ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

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
            const SizedBox(height: 16),
            Text(
              'No WhatsApp Leads Found',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No leads match your current filters.\nTry adjusting the search or filter options.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

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
