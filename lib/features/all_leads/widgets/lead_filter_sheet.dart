// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:synqer_io/core/enums/leadfilter_tabs_enum.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';

class LeadFilterSheet extends StatefulWidget {
  final LeadFilterContext filterContext;
  final Map<String, dynamic> initialFilters;

  const LeadFilterSheet._({
    required this.filterContext,
    required this.initialFilters,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required LeadFilterContext filterContext,
    required Map<String, dynamic> currentFilters,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => SafeArea(
        child: LeadFilterSheet._(
          filterContext: filterContext,
          initialFilters: Map.from(currentFilters),
        ),
      ),
    );
  }

  @override
  State<LeadFilterSheet> createState() => _LeadFilterSheetState();
}

class _LeadFilterSheetState extends State<LeadFilterSheet> {
  late final ValueNotifier<Map<String, dynamic>> _filtersNotifier;

  @override
  void initState() {
    super.initState();
    _filtersNotifier = ValueNotifier(Map.from(widget.initialFilters));
  }

  @override
  void dispose() {
    _filtersNotifier.dispose();
    super.dispose();
  }

  bool _isActive(dynamic v) {
    if (v == null) return false;
    if (v is String) return v != 'All';
    if (v is DateTime) return true;
    return false;
  }

  bool _hasActiveFilters(Map<String, dynamic> filters) =>
      filters.values.any(_isActive);

  int _activeCount(Map<String, dynamic> filters) =>
      filters.values.where(_isActive).length;

  void _clearAll() {
    final current = _filtersNotifier.value;
    _filtersNotifier.value = {
      for (final e in current.entries)
        e.key: (e.value is DateTime || e.value == null) ? null : 'All',
    };
  }

  void _updateFilter(String key, dynamic value) {
    _filtersNotifier.value = {..._filtersNotifier.value, key: value};
  }

  String get _sheetTitle {
    switch (widget.filterContext) {
      case LeadFilterContext.whatsapp:
        return 'WhatsApp Leads';
      case LeadFilterContext.rcs:
        return 'RCS Leads';
      case LeadFilterContext.aiWebAgent:
        return 'AI Web Agent';
      case LeadFilterContext.webForm:
        return 'Web Form';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: c.bottomSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: c.borderStrong),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _sheetTitle,
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ValueListenableBuilder<Map<String, dynamic>>(
                  valueListenable: _filtersNotifier,
                  builder: (_, filters, _) {
                    final hasActive = _hasActiveFilters(filters);
                    return GestureDetector(
                      onTap: hasActive ? _clearAll : null,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: hasActive ? 1.0 : 0.3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: c.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: c.primary.withOpacity(0.25),
                            ),
                          ),
                          child: Text(
                            'Clear All',
                            style: TextStyle(
                              color: c.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: c.border, height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: ValueListenableBuilder<Map<String, dynamic>>(
                valueListenable: _filtersNotifier,
                builder: (_, filters, _) => _buildContent(filters),
              ),
            ),
          ),
          Divider(color: c.border, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: SizedBox(
              height: 50,
              child: ValueListenableBuilder<Map<String, dynamic>>(
                valueListenable: _filtersNotifier,
                builder: (_, filters, _) {
                  final count = _activeCount(filters);
                  return ElevatedButton(
                    onPressed: () => Navigator.pop(context, filters),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      count > 0
                          ? 'Apply Filters ($count active)'
                          : 'Apply Filters',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> filters) {
    switch (widget.filterContext) {
      case LeadFilterContext.whatsapp:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChipSection(
              title: 'Status',
              options: const [
                'All',
                'Pending',
                'Follow Up',
                'Interested',
                'Not Interested',
                'Closed',
              ],
              selected: filters['status'] as String,
              onSelected: (v) => _updateFilter('status', v),
            ),
            const SizedBox(height: 24),
            _ChipSection(
              title: 'Lead Type',
              options: const ['All', 'General Enquiry', 'Lead'],
              selected: filters['leadType'] as String,
              onSelected: (v) => _updateFilter('leadType', v),
            ),
            const SizedBox(height: 8),
          ],
        );

      case LeadFilterContext.rcs:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChipSection(
              title: 'Event Type',
              options: const ['All', 'Button Click', 'Text Message'],
              selected: filters['eventType'] as String,
              onSelected: (v) => _updateFilter('eventType', v),
            ),
            const SizedBox(height: 24),
            _DateRangeSection(
              fromDate: filters['fromDate'] as DateTime?,
              toDate: filters['toDate'] as DateTime?,
              onFromDate: (d) => _updateFilter('fromDate', d),
              onToDate: (d) => _updateFilter('toDate', d),
            ),
            const SizedBox(height: 8),
          ],
        );

      case LeadFilterContext.aiWebAgent:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChipSection(
              title: 'Connection Status',
              options: const ['All', 'Not Contacted', 'Contacted'],
              selected: filters['isConnected'] as String,
              onSelected: (v) => _updateFilter('isConnected', v),
            ),
            const SizedBox(height: 8),
          ],
        );

      case LeadFilterContext.webForm:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChipSection(
              title: 'Read Status',
              options: const ['All', 'Unread', 'Read'],
              selected: filters['isRead'] as String,
              onSelected: (v) => _updateFilter('isRead', v),
            ),
            const SizedBox(height: 24),
            _ChipSection(
              title: 'Connection Status',
              options: const ['All', 'Pending', 'Contacted'],
              selected: filters['isConnected'] as String,
              onSelected: (v) => _updateFilter('isConnected', v),
            ),
            const SizedBox(height: 8),
          ],
        );
    }
  }
}

// ─── Chip Section ────────────────────────────────────────────────────────────

class _ChipSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final void Function(String) onSelected;

  const _ChipSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: c.textSecondary,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return GestureDetector(
              onTap: () => onSelected(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? c.primary : c.surfaceHigh,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? c.primary : c.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    color: isSelected ? Colors.white : c.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Date Range Section ───────────────────────────────────────────────────────

class _DateRangeSection extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final void Function(DateTime?) onFromDate;
  final void Function(DateTime?) onToDate;

  const _DateRangeSection({
    required this.fromDate,
    required this.toDate,
    required this.onFromDate,
    required this.onToDate,
  });

  static final _fmt = DateFormat('dd MMM yyyy');

  Future<void> _pick(BuildContext context, bool isFrom) async {
    final c = context.colors;
    final now = DateTime.now();

    DateTime initial;
    DateTime first;
    DateTime last;

    if (isFrom) {
      initial = fromDate ?? now;
      first = DateTime(2020);
      last = toDate ?? DateTime(now.year + 2);
    } else {
      initial = toDate ?? now;
      first = fromDate ?? DateTime(2020);
      last = DateTime(now.year + 2);
    }

    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: c.primary,
            brightness: Theme.of(ctx).brightness,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      isFrom ? onFromDate(picked) : onToDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE RANGE',
          style: TextStyle(
            color: c.textSecondary,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _DateTile(
                label: 'From',
                value: fromDate != null ? _fmt.format(fromDate!) : null,
                onTap: () => _pick(context, true),
                onClear: fromDate != null ? () => onFromDate(null) : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DateTile(
                label: 'To',
                value: toDate != null ? _fmt.format(toDate!) : null,
                onTap: () => _pick(context, false),
                onClear: toDate != null ? () => onToDate(null) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasValue = value != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue ? c.primary.withOpacity(0.6) : c.border,
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 15,
              color: hasValue ? c.primary : c.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value ?? 'Select date',
                    style: TextStyle(
                      color: hasValue ? c.textPrimary : c.textSecondary,
                      fontSize: 12,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (hasValue && onClear != null)
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: c.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
