// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:synqer_io/core/enums/transaction_enums.dart';

class TransactionFilterResult {
  final TxnFilter filter;
  final TxnService? service;

  final DateTime? fromDate;
  final DateTime? toDate;

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
  late TxnFilter _filter;
  TxnService? _service;

  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();

    _filter = widget.selectedFilter;
    _service = widget.selectedService;
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2020),

      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _fromDate = picked);
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
      setState(() => _toDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),

      decoration: const BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                color: const Color(0xFFE2E8F0),

                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Filter Transactions',

            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 22),

          // TYPE
          const Text(
            'Transaction Type',

            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,

            children: TxnFilter.values.map((f) {
              final active = _filter == f;

              return _FilterChip(
                label: f.name.toUpperCase(),

                selected: active,

                onTap: () {
                  setState(() => _filter = f);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 22),

          // SERVICE
          const Text(
            'Service',

            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,

            children: [
              _FilterChip(
                label: 'ALL',

                selected: _service == null,

                onTap: () {
                  setState(() => _service = null);
                },
              ),

              ...TxnService.values.map((s) {
                return _FilterChip(
                  label: s.name.toUpperCase(),

                  selected: _service == s,

                  onTap: () {
                    setState(() => _service = s);
                  },
                );
              }),
            ],
          ),

          const SizedBox(height: 22),

          // DATE
          const Text(
            'Date Range',

            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _DatePickerBox(
                  label: 'From Date',

                  value: _fromDate,

                  onTap: _pickFromDate,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _DatePickerBox(
                  label: 'To Date',

                  value: _toDate,

                  onTap: _pickToDate,
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

                    side: BorderSide(color: Colors.black.withOpacity(0.08)),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  child: const Text(
                    'Cancel',

                    style: TextStyle(fontWeight: FontWeight.w600),
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
                        filter: _filter,
                        service: _service,
                        fromDate: _fromDate,
                        toDate: _toDate,
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    elevation: 0,

                    backgroundColor: const Color(0xFF0F172A),

                    foregroundColor: Colors.white,

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
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),

        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),

          borderRadius: BorderRadius.circular(14),

          border: Border.all(
            color: selected
                ? const Color(0xFF0F172A)
                : Colors.black.withOpacity(0.05),
          ),
        ),

        child: Text(
          label,

          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF475569),

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
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(14),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),

          borderRadius: BorderRadius.circular(14),

          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),

        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: Color(0xFF64748B),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                value == null ? label : DateFormat('d MMM yyyy').format(value!),

                style: TextStyle(
                  fontSize: 12.5,

                  color: value == null
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF0F172A),

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
