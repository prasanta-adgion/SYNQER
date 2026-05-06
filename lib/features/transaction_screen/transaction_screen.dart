// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:synqer_io/core/enums/transaction_enums.dart';
import 'package:synqer_io/features/transaction_screen/widgets/filterted_screen.dart';

class Transaction {
  final String id;
  final TxnType type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final TxnService service;
  final String description;
  final DateTime createdAt;
  final double? dltCharge;
  final Map<String, dynamic> meta;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.service,
    required this.description,
    required this.createdAt,
    this.dltCharge,
    this.meta = const {},
  });
}

// =========================
// SAMPLE DATA (mirrors your API)
// =========================
final List<Transaction> _sampleTxns = [
  Transaction(
    id: '69f9a7bb',
    type: TxnType.credit,
    amount: 50,
    balanceBefore: 47.8,
    balanceAfter: 97.8,
    service: TxnService.sms,
    description: 'SMS balance added by reseller',
    createdAt: DateTime.parse('2026-05-05T13:48:03'),
  ),
  Transaction(
    id: '69f9a639',
    type: TxnType.credit,
    amount: 5,
    balanceBefore: 42.8,
    balanceAfter: 47.8,
    service: TxnService.sms,
    description: 'SMS balance added by reseller',
    createdAt: DateTime.parse('2026-05-05T13:41:37'),
  ),
  Transaction(
    id: '69f66cd8',
    type: TxnType.refund,
    amount: 0.9,
    balanceBefore: 86.56,
    balanceAfter: 87.46,
    service: TxnService.whatsapp,
    description: 'Refund for 1 failed WhatsApp messages',
    createdAt: DateTime.parse('2026-05-03T03:00:00'),
  ),
  Transaction(
    id: '69f665d0',
    type: TxnType.refund,
    amount: 0.7,
    balanceBefore: 691.6,
    balanceAfter: 692.30,
    service: TxnService.rcs,
    description: 'Refund for 1 failed RCS richMedia messages',
    createdAt: DateTime.parse('2026-05-03T02:30:00'),
  ),
  Transaction(
    id: '69f65ec8',
    type: TxnType.refund,
    amount: 0.475,
    balanceBefore: 42.325,
    balanceAfter: 42.80,
    service: TxnService.sms,
    description: 'Refund for 1 failed SMS',
    createdAt: DateTime.parse('2026-05-03T02:00:00'),
    dltCharge: 0.025,
  ),
  Transaction(
    id: '69f5f636',
    type: TxnType.debit,
    amount: 0.9,
    balanceBefore: 87.46,
    balanceAfter: 86.56,
    service: TxnService.whatsapp,
    description: 'WhatsApp campaign: ark',
    createdAt: DateTime.parse('2026-05-02T18:33:50'),
  ),
  Transaction(
    id: '69f5f5dc',
    type: TxnType.debit,
    amount: 0.5,
    balanceBefore: 42.825,
    balanceAfter: 42.325,
    service: TxnService.sms,
    description: 'SMS campaign: ark',
    createdAt: DateTime.parse('2026-05-02T18:32:20'),
  ),
  Transaction(
    id: '69f5f58f',
    type: TxnType.debit,
    amount: 0.7,
    balanceBefore: 692.3,
    balanceAfter: 691.6,
    service: TxnService.rcs,
    description: 'RCS campaign: ark',
    createdAt: DateTime.parse('2026-05-02T18:31:03'),
  ),
  Transaction(
    id: '69f5f52e',
    type: TxnType.debit,
    amount: 0.5,
    balanceBefore: 43.325,
    balanceAfter: 42.825,
    service: TxnService.sms,
    description: 'SMS campaign: ark',
    createdAt: DateTime.parse('2026-05-02T18:29:26'),
  ),
  Transaction(
    id: '69f51450',
    type: TxnType.refund,
    amount: 0.7,
    balanceBefore: 691.6,
    balanceAfter: 692.30,
    service: TxnService.rcs,
    description: 'Refund for 1 failed RCS richMedia messages',
    createdAt: DateTime.parse('2026-05-02T02:30:00'),
  ),
  Transaction(
    id: '69f50d48',
    type: TxnType.refund,
    amount: 0.475,
    balanceBefore: 42.85,
    balanceAfter: 43.325,
    service: TxnService.sms,
    description: 'Refund for 1 failed SMS',
    createdAt: DateTime.parse('2026-05-02T02:00:00'),
    dltCharge: 0.025,
  ),
];

// =========================
// MAIN SCREEN
// =========================
class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final ValueNotifier<TxnFilter> _filterNotifier = ValueNotifier(TxnFilter.all);

  final ValueNotifier<TxnService?> _serviceNotifier = ValueNotifier(null);

  String _dateGroupLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return DateFormat('d MMM yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),

      child: Scaffold(
        body: SafeArea(
          child: ValueListenableBuilder<TxnFilter>(
            valueListenable: _filterNotifier,

            builder: (context, filterValue, _) {
              return ValueListenableBuilder<TxnService?>(
                valueListenable: _serviceNotifier,

                builder: (context, serviceValue, __) {
                  // FILTERED TRANSACTIONS
                  final filteredTxns = _sampleTxns.where((t) {
                    final matchesType =
                        filterValue == TxnFilter.all ||
                        (filterValue == TxnFilter.credit &&
                            t.type == TxnType.credit) ||
                        (filterValue == TxnFilter.debit &&
                            t.type == TxnType.debit) ||
                        (filterValue == TxnFilter.refund &&
                            t.type == TxnType.refund);

                    final matchesService =
                        serviceValue == null || t.service == serviceValue;

                    return matchesType && matchesService;
                  }).toList();

                  // GROUPED
                  final Map<String, List<Transaction>> groupedTxns = {};

                  for (final t in filteredTxns) {
                    final key = _dateGroupLabel(t.createdAt);

                    groupedTxns.putIfAbsent(key, () => []).add(t);
                  }

                  return Column(
                    children: [
                      _Header(
                        filterNotifier: _filterNotifier,

                        serviceNotifier: _serviceNotifier,
                      ),

                      const _BalanceCards(),

                      const SizedBox(height: 8),

                      _FilterBar(
                        selected: filterValue,

                        onChanged: (f) {
                          _filterNotifier.value = f;
                        },
                      ),

                      _ServiceChipBar(
                        selected: serviceValue,

                        onChanged: (s) {
                          _serviceNotifier.value = s;
                        },
                      ),

                      const SizedBox(height: 4),

                      Expanded(
                        child: filteredTxns.isEmpty
                            ? const _EmptyState()
                            : _TransactionList(grouped: groupedTxns),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// =========================
// HEADER
// =========================
class _Header extends StatelessWidget {
  final ValueNotifier<TxnFilter> filterNotifier;

  final ValueNotifier<TxnService?> serviceNotifier;

  const _Header({required this.filterNotifier, required this.serviceNotifier});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),

      child: Row(
        children: [
          _IconBtn(
            icon: Icons.arrow_back_ios_new_rounded,

            onTap: () {
              Navigator.pop(context);
            },
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Transactions',

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  'All wallet activity',

                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          _IconBtn(icon: Icons.search_rounded, onTap: () {}),

          const SizedBox(width: 8),

          _IconBtn(
            icon: Icons.tune_rounded,

            onTap: () async {
              final result =
                  await showModalBottomSheet<TransactionFilterResult>(
                    context: context,

                    isScrollControlled: true,

                    backgroundColor: Colors.transparent,

                    builder: (_) {
                      return SafeArea(
                        top: false,
                        child: TransactionFilterSheet(
                          selectedFilter: filterNotifier.value,

                          selectedService: serviceNotifier.value,
                        ),
                      );
                    },
                  );

              if (result != null) {
                filterNotifier.value = result.filter;

                serviceNotifier.value = result.service;
              }
            },
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: const Color(0xFF334155)),
        ),
      ),
    );
  }
}

// =========================
// BALANCE CARDS
// =========================
class _BalanceCards extends StatelessWidget {
  const _BalanceCards();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: const [
          _ServiceBalanceCard(
            service: 'Bulk SMS',
            balance: 97.80,
            icon: Icons.sms_rounded,
            gradient: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          ),
          SizedBox(width: 12),
          _ServiceBalanceCard(
            service: 'WhatsApp',
            balance: 86.56,
            icon: Icons.chat_bubble_rounded,
            gradient: [Color(0xFF059669), Color(0xFF10B981)],
          ),
          SizedBox(width: 12),
          _ServiceBalanceCard(
            service: 'RCS',
            balance: 691.60,
            icon: Icons.message_rounded,
            gradient: [Color(0xFFDC2626), Color(0xFFF97316)],
          ),
        ],
      ),
    );
  }
}

class _ServiceBalanceCard extends StatelessWidget {
  final String service;
  final double balance;
  final IconData icon;
  final List<Color> gradient;
  const _ServiceBalanceCard({
    required this.service,
    required this.balance,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                service,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Balance',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '₹${balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =========================
// FILTER BAR (segmented)
// =========================
class _FilterBar extends StatelessWidget {
  final TxnFilter selected;
  final ValueChanged<TxnFilter> onChanged;
  const _FilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: TxnFilter.values.map((f) {
            final isActive = f == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF0F172A)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _label(f),
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _label(TxnFilter f) {
    switch (f) {
      case TxnFilter.all:
        return 'All';
      case TxnFilter.credit:
        return 'Credit';
      case TxnFilter.debit:
        return 'Debit';
      case TxnFilter.refund:
        return 'Refund';
    }
  }
}

// =========================
// SERVICE CHIPS
// =========================
class _ServiceChipBar extends StatelessWidget {
  final TxnService? selected;
  final ValueChanged<TxnService?> onChanged;
  const _ServiceChipBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = <_ChipItem>[
      _ChipItem('All Services', null),
      _ChipItem('SMS', TxnService.sms),
      _ChipItem('WhatsApp', TxnService.whatsapp),
      _ChipItem('RCS', TxnService.rcs),
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final item = items[i];
          final isActive = item.service == selected;
          return GestureDetector(
            onTap: () => onChanged(item.service),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF4F46E5).withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF4F46E5)
                      : Colors.black.withOpacity(0.06),
                  width: isActive ? 1.2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChipItem {
  final String label;
  final TxnService? service;
  _ChipItem(this.label, this.service);
}

// =========================
// TRANSACTION LIST
// =========================
class _TransactionList extends StatelessWidget {
  final Map<String, List<Transaction>> grouped;
  const _TransactionList({required this.grouped});

  @override
  Widget build(BuildContext context) {
    final keys = grouped.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: keys.length,
      itemBuilder: (_, i) {
        final key = keys[i];
        final items = grouped[key]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Row(
                children: [
                  Text(
                    key,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${items.length} ${items.length == 1 ? "txn" : "txns"}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                children: List.generate(items.length, (idx) {
                  return Column(
                    children: [
                      _TransactionTile(txn: items[idx]),
                      if (idx != items.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 1,
                            color: Colors.black.withOpacity(0.04),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

// =========================
// TILE
// =========================
class _TransactionTile extends StatelessWidget {
  final Transaction txn;
  const _TransactionTile({required this.txn});

  @override
  Widget build(BuildContext context) {
    final config = _typeConfig(txn.type);
    final sign = txn.type == TxnType.debit ? '-' : '+';
    final amountColor = txn.type == TxnType.debit
        ? const Color(0xFFDC2626)
        : const Color(0xFF059669);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDetails(context, txn),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service icon w/ type badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _serviceColor(txn.service).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _serviceIcon(txn.service),
                      color: _serviceColor(txn.service),
                      size: 20,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: config.bg,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(config.icon, size: 10, color: config.fg),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Description + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Pill(
                          label: config.label,
                          fg: config.fg,
                          bg: config.bg,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('h:mm a').format(txn.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      txn.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                    if (txn.dltCharge != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'DLT charge: ₹${txn.dltCharge!.toStringAsFixed(3)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Amount + balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign₹${txn.amount.toStringAsFixed(txn.amount < 1 ? 3 : 2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bal ₹${txn.balanceAfter.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Transaction t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TxnDetailSheet(txn: t),
    );
  }

  _TypeConfig _typeConfig(TxnType type) {
    switch (type) {
      case TxnType.credit:
        return _TypeConfig(
          label: 'Credit',
          icon: Icons.arrow_downward_rounded,
          fg: const Color(0xFF059669),
          bg: const Color(0xFFD1FAE5),
        );
      case TxnType.debit:
        return _TypeConfig(
          label: 'Debit',
          icon: Icons.arrow_upward_rounded,
          fg: const Color(0xFFDC2626),
          bg: const Color(0xFFFEE2E2),
        );
      case TxnType.refund:
        return _TypeConfig(
          label: 'Refund',
          icon: Icons.refresh_rounded,
          fg: const Color(0xFF2563EB),
          bg: const Color(0xFFDBEAFE),
        );
    }
  }

  Color _serviceColor(TxnService s) {
    switch (s) {
      case TxnService.sms:
        return const Color(0xFF4F46E5);
      case TxnService.whatsapp:
        return const Color(0xFF059669);
      case TxnService.rcs:
        return const Color(0xFFDC2626);
    }
  }

  IconData _serviceIcon(TxnService s) {
    switch (s) {
      case TxnService.sms:
        return Icons.sms_rounded;
      case TxnService.whatsapp:
        return Icons.chat_bubble_rounded;
      case TxnService.rcs:
        return Icons.message_rounded;
    }
  }
}

class _TypeConfig {
  final String label;
  final IconData icon;
  final Color fg;
  final Color bg;
  _TypeConfig({
    required this.label,
    required this.icon,
    required this.fg,
    required this.bg,
  });
}

class _Pill extends StatelessWidget {
  final String label;
  final Color fg;
  final Color bg;
  const _Pill({required this.label, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// =========================
// DETAIL SHEET
// =========================
class _TxnDetailSheet extends StatelessWidget {
  final Transaction txn;
  const _TxnDetailSheet({required this.txn});

  @override
  Widget build(BuildContext context) {
    final isDebit = txn.type == TxnType.debit;
    final amountColor = isDebit
        ? const Color(0xFFDC2626)
        : const Color(0xFF059669);
    final sign = isDebit ? '-' : '+';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Transaction Details',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.55),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$sign₹${txn.amount.toStringAsFixed(txn.amount < 1 ? 3 : 2)}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: amountColor,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            txn.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withOpacity(0.04)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(
              children: [
                _DetailRow(label: 'Type', value: txn.type.name.toUpperCase()),
                _DetailRow(
                  label: 'Service',
                  value: txn.service.name.toUpperCase(),
                ),
                _DetailRow(
                  label: 'Balance Before',
                  value: '₹${txn.balanceBefore.toStringAsFixed(2)}',
                ),
                _DetailRow(
                  label: 'Balance After',
                  value: '₹${txn.balanceAfter.toStringAsFixed(2)}',
                  isStrong: true,
                ),
                if (txn.dltCharge != null)
                  _DetailRow(
                    label: 'DLT Charge',
                    value: '₹${txn.dltCharge!.toStringAsFixed(3)}',
                  ),
                _DetailRow(
                  label: 'Date & Time',
                  value: DateFormat('d MMM yyyy, h:mm a').format(txn.createdAt),
                ),
                _DetailRow(
                  label: 'Transaction ID',
                  value: txn.id,
                  isLast: true,
                  mono: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.black.withOpacity(0.1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: const Text(
                    'Share',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text(
                    'Receipt',
                    style: TextStyle(fontWeight: FontWeight.w600),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  final bool isStrong;
  final bool mono;
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
    this.isStrong = false,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF0F172A),
              fontWeight: isStrong ? FontWeight.w700 : FontWeight.w600,
              fontFamily: mono ? 'monospace' : null,
              letterSpacing: mono ? 0.3 : 0,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// EMPTY STATE
// =========================
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF94A3B8),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try changing your filters',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
