// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:synqer_io/core/enums/transaction_enums.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';

class TransactionFilterResult {
  final TxnFilter filter;
  final TxnService? service;

  final String? fromDate;
  final String? toDate;

  const TransactionFilterResult({
    required this.filter,
    required this.service,
    this.fromDate,
    this.toDate,
  });
}

class TransactionFilterSheet extends StatefulWidget {
  final TxnFilter selectedFilter;
  final TxnService? selectedService;

  const TransactionFilterSheet({
    super.key,
    required this.selectedFilter,
    required this.selectedService,
  });

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late final ValueNotifier<TxnFilter> _filterNotifier;
  late final ValueNotifier<TxnService?> _serviceNotifier;
  final ValueNotifier<DateTime?> _fromDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _toDateNotifier = ValueNotifier<DateTime?>(
    null,
  );

  @override
  void initState() {
    super.initState();

    _filterNotifier = ValueNotifier(widget.selectedFilter);
    _serviceNotifier = ValueNotifier(widget.selectedService);
  }

  @override
  void dispose() {
    _filterNotifier.dispose();
    _serviceNotifier.dispose();
    _fromDateNotifier.dispose();
    _toDateNotifier.dispose();
    super.dispose();
  }

  String? _formatApiDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _fromDateNotifier.value = picked;
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _toDateNotifier.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: c.bottomSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: c.bottomSheetHandle,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Filter Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),

          const SizedBox(height: 22),

          // TYPE
          Text(
            'Transaction Type',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: c.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          ValueListenableBuilder<TxnFilter>(
            valueListenable: _filterNotifier,
            builder: (context, selectedFilter, _) {
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: TxnFilter.values.map((f) {
                  final active = selectedFilter == f;
                  return _FilterChip(
                    label: f.name.toUpperCase(),
                    selected: active,
                    onTap: () {
                      _filterNotifier.value = f;
                    },
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 22),

          // SERVICE
          Text(
            'Service',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: c.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          ValueListenableBuilder<TxnService?>(
            valueListenable: _serviceNotifier,
            builder: (context, selectedService, _) {
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FilterChip(
                    label: 'ALL',
                    selected: selectedService == null,
                    onTap: () {
                      _serviceNotifier.value = null;
                    },
                  ),
                  ...TxnService.values.map((s) {
                    return _FilterChip(
                      label: s.name.toUpperCase(),
                      selected: selectedService == s,
                      onTap: () {
                        _serviceNotifier.value = s;
                      },
                    );
                  }),
                ],
              );
            },
          ),

          const SizedBox(height: 22),

          // DATE
          Text(
            'Date Range',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: c.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<DateTime?>(
                  valueListenable: _fromDateNotifier,
                  builder: (context, fromDate, _) {
                    return _DatePickerBox(
                      label: 'From Date',
                      value: fromDate,
                      onTap: _pickFromDate,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ValueListenableBuilder<DateTime?>(
                  valueListenable: _toDateNotifier,
                  builder: (context, toDate, _) {
                    return _DatePickerBox(
                      label: 'To Date',
                      value: toDate,
                      onTap: _pickToDate,
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: c.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      TransactionFilterResult(
                        filter: _filterNotifier.value,
                        service: _serviceNotifier.value,
                        fromDate: _formatApiDate(_fromDateNotifier.value),
                        toDate: _formatApiDate(_toDateNotifier.value),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: c.primary,
                    foregroundColor: c.onBrand,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? c.primary : c.surfaceHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? c.primary : c.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? c.onBrand : c.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _DatePickerBox extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DatePickerBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: c.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.inputBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded, size: 18, color: c.inputIcon),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value == null ? label : DateFormat('yyyy-MM-dd').format(value!),
                style: TextStyle(
                  fontSize: 12.5,
                  color: value == null ? c.inputHint : c.inputText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
