// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/enums/transaction_enums.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/utils/app_configarations.dart';
import 'package:synqer_io/core/widgets/custom_appbar.dart';
import 'package:synqer_io/core/widgets/loading_screen.dart';
import 'package:synqer_io/features/profile/model/user_profile_model.dart';
import 'package:synqer_io/features/transaction_screen/bloc/transaction_get_bloc.dart';
import 'package:synqer_io/features/transaction_screen/model/transaction_model.dart';
import 'package:synqer_io/features/transaction_screen/widgets/balance_card.dart';
import 'package:synqer_io/features/transaction_screen/widgets/filterted_screen.dart';

class TransactionScreen extends StatelessWidget {
  final User allServiceBalance;
  const TransactionScreen({super.key, required this.allServiceBalance});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TransactionGetBloc(transactionGetRepo: AppInjector.transactionsRepo)
            ..add(const FetchTransactionsEvent()),
      child: _TransactionView(allServiceBalance: allServiceBalance),
    );
  }
}

class _TransactionView extends StatefulWidget {
  final User allServiceBalance;

  const _TransactionView({required this.allServiceBalance});

  @override
  State<_TransactionView> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<_TransactionView> {
  static const int _pageSize = 15;
  static const double _balanceCardsHeight = 130;
  static const double _scrollHideThreshold = 8; // small dead-zone

  final ValueNotifier<TxnFilter> _filterNotifier = ValueNotifier(TxnFilter.all);
  final ValueNotifier<TxnService?> _serviceNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _showBalanceNotifier = ValueNotifier(true);
  final ScrollController _scrollController = ScrollController();

  String? _fromDate;
  String? _toDate;
  double _lastScrollOffset = 0;
  int? _requestedLoadMorePage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _filterNotifier.dispose();
    _serviceNotifier.dispose();
    _showBalanceNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final delta = offset - _lastScrollOffset;

    if (delta > _scrollHideThreshold && _showBalanceNotifier.value) {
      _showBalanceNotifier.value = false;
    } else if (delta < -_scrollHideThreshold && !_showBalanceNotifier.value) {
      _showBalanceNotifier.value = true;
    }

    // Always show when at the very top
    if (offset <= 0 && !_showBalanceNotifier.value) {
      _showBalanceNotifier.value = true;
    }

    _lastScrollOffset = offset;

    // Pagination
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (offset < maxScroll - 200) return;

    final state = context.read<TransactionGetBloc>().state;
    if (state is! TransactionGetLoaded ||
        !state.hasMore ||
        state.isLoadingMore) {
      return;
    }

    final nextPage = state.currentPage + 1;
    if (_requestedLoadMorePage == nextPage) return;

    _requestedLoadMorePage = nextPage;

    context.read<TransactionGetBloc>().add(
      LoadMoreTransactionsEvent(
        page: nextPage,
        limit: _pageSize,
        serviceType: _serviceType,
        transactionType: _transactionType,
        dateFrom: _fromDate,
        dateTo: _toDate,
      ),
    );
  }

  String? get _transactionType {
    final filter = _filterNotifier.value;
    return filter == TxnFilter.all ? null : filter.name;
  }

  String? get _serviceType => _serviceNotifier.value?.name;

  void _dispatchFetch() {
    _requestedLoadMorePage = null;

    context.read<TransactionGetBloc>().add(
      FetchTransactionsEvent(
        page: 1,
        limit: _pageSize,
        serviceType: _serviceType,
        transactionType: _transactionType,
        dateFrom: _fromDate,
        dateTo: _toDate,
      ),
    );
  }

  Future<void> _onRefresh() async {
    _dispatchFetch();
    await context.read<TransactionGetBloc>().stream.firstWhere(
      (state) => state is! TransactionGetLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: c.bg,
        appBar: CustomAppBar(
          title: 'Transactions',

          subtitle: 'All wallet activity',

          backgroundColor: c.surface,

          titleColor: c.textPrimary,

          subtitleColor: c.textSecondary,
          trailing: _IconBtn(
            icon: Icons.tune_rounded,

            onTap: () async {
              final result =
                  await showModalBottomSheet<TransactionFilterResult>(
                    context: context,

                    isScrollControlled: true,

                    backgroundColor: Colors.transparent,

                    builder: (_) => SafeArea(
                      top: false,

                      child: TransactionFilterSheet(
                        selectedFilter: _filterNotifier.value,

                        selectedService: _serviceNotifier.value,
                      ),
                    ),
                  );

              if (result != null) {
                _filterNotifier.value = result.filter;

                _serviceNotifier.value = result.service;

                _fromDate = result.fromDate;

                _toDate = result.toDate;

                _dispatchFetch();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: _showBalanceNotifier,
                builder: (context, show, child) {
                  return _AnimatedCollapse(
                    expanded: show,
                    maxHeight: _balanceCardsHeight,
                    child: child!,
                  );
                },
                child: BalanceCards(
                  allServiceBalance: widget.allServiceBalance,
                ),
              ),

              const SizedBox(height: 8),

              // Filter bar — only rebuilds when filter changes
              ValueListenableBuilder<TxnFilter>(
                valueListenable: _filterNotifier,
                builder: (context, filterValue, _) {
                  return _FilterBar(
                    selected: filterValue,
                    onChanged: (f) {
                      _filterNotifier.value = f;
                      _dispatchFetch();
                    },
                  );
                },
              ),

              // Service chips — only rebuilds when service changes
              ValueListenableBuilder<TxnService?>(
                valueListenable: _serviceNotifier,
                builder: (context, serviceValue, _) {
                  return _ServiceChipBar(
                    selected: serviceValue,
                    onChanged: (s) {
                      _serviceNotifier.value = s;
                      _dispatchFetch();
                    },
                  );
                },
              ),

              const SizedBox(height: 4),

              Expanded(
                child: BlocConsumer<TransactionGetBloc, TransactionGetState>(
                  listener: (context, state) {
                    if (state is TransactionGetLoaded && !state.isLoadingMore) {
                      _requestedLoadMorePage = null;
                    }
                  },
                  builder: (context, state) {
                    if (state is TransactionGetInitial ||
                        state is TransactionGetLoading) {
                      return const _LoadingState();
                    }

                    if (state is TransactionGetError) {
                      return _TransactionErrorState(
                        message: state.message,
                        onRetry: _dispatchFetch,
                      );
                    }

                    if (state is TransactionGetLoaded) {
                      if (state.transactions.isEmpty) {
                        return const _EmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: c.primary,
                        backgroundColor: c.surface,
                        child: _TransactionList(
                          grouped: state.groupedTransactions,
                          scrollController: _scrollController,
                          isLoadingMore: state.isLoadingMore,
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedCollapse extends StatelessWidget {
  final bool expanded;
  final double maxHeight;
  final Widget child;

  const _AnimatedCollapse({
    required this.expanded,
    required this.maxHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: expanded ? 1.0 : 0.0,
          curve: Curves.easeOut,
          child: SizedBox(
            height: expanded ? maxHeight : 0,
            child: OverflowBox(
              minHeight: 0,
              maxHeight: maxHeight,
              alignment: Alignment.topCenter,
              child: SizedBox(height: maxHeight, child: child),
            ),
          ),
        ),
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
    final c = context.colors;
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: c.textSecondary),
        ),
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
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: TxnFilter.values.map((f) {
            final isActive = f == selected;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isActive ? c.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _label(f),
                      style: TextStyle(
                        color: isActive ? c.onBrand : c.textSecondary,
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

  static const _items = <_ChipItem>[
    _ChipItem('All Services', null),
    _ChipItem('SMS', TxnService.sms),
    _ChipItem('WhatsApp', TxnService.whatsapp),
    _ChipItem('RCS', TxnService.rcs),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final item = _items[i];
          final isActive = item.service == selected;
          return GestureDetector(
            onTap: () => onChanged(item.service),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? c.primary.withOpacity(0.12) : c.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? c.primary : c.border,
                  width: isActive ? 1.2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: isActive ? c.primary : c.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
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
  const _ChipItem(this.label, this.service);
}

// =========================
// TRANSACTION LIST
// =========================
class _TransactionList extends StatelessWidget {
  final Map<String, List<TransactionDetailsModel>> grouped;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final List<_TransactionListItem> rows;

  _TransactionList({
    required this.grouped,
    required this.scrollController,
    required this.isLoadingMore,
  }) : rows = _buildRows(grouped, isLoadingMore);

  static List<_TransactionListItem> _buildRows(
    Map<String, List<TransactionDetailsModel>> grouped,
    bool isLoadingMore,
  ) {
    final rows = <_TransactionListItem>[];

    grouped.forEach((date, transactions) {
      rows.add(_TransactionListItem.header(date, transactions.length));

      for (var i = 0; i < transactions.length; i++) {
        rows.add(
          _TransactionListItem.transaction(
            transactions[i],
            isFirstInGroup: i == 0,
            isLastInGroup: i == transactions.length - 1,
          ),
        );
      }
    });

    if (isLoadingMore) {
      rows.add(const _TransactionListItem.loading());
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: rows.length,
      itemBuilder: (_, i) {
        final row = rows[i];

        if (row.isLoading) {
          return const _LoadMoreIndicator();
        }

        if (row.date != null) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
            child: Row(
              children: [
                Text(
                  row.date!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: c.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 1, color: c.border)),
                const SizedBox(width: 8),
                Text(
                  '${row.count} ${row.count == 1 ? "txn" : "txns"}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: c.textMuted,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.vertical(
              top: row.isFirstInGroup ? const Radius.circular(16) : Radius.zero,
              bottom: row.isLastInGroup
                  ? const Radius.circular(16)
                  : Radius.zero,
            ),
            border: Border(
              left: BorderSide(color: c.border),
              right: BorderSide(color: c.border),
              top: row.isFirstInGroup
                  ? BorderSide(color: c.border)
                  : BorderSide.none,
              bottom: BorderSide(color: c.border),
            ),
          ),
          // child: Column(
          //   children: [
          //     _TransactionTile(txn: row.transaction!),
          //     // if (!row.isLastInGroup)
          //     //   Padding(
          //     //     padding: const EdgeInsets.symmetric(horizontal: 16),
          //     //     child: Container(height: 1, color: c.border),
          //     //   ),
          //   ],
          // ),
          child: _TransactionTile(txn: row.transaction!),
        );
      },
    );
  }
}

class _TransactionListItem {
  final String? date;
  final int count;
  final TransactionDetailsModel? transaction;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool isLoading;

  const _TransactionListItem.header(this.date, this.count)
    : transaction = null,
      isFirstInGroup = false,
      isLastInGroup = false,
      isLoading = false;

  const _TransactionListItem.transaction(
    this.transaction, {
    required this.isFirstInGroup,
    required this.isLastInGroup,
  }) : date = null,
       count = 0,
       isLoading = false;

  const _TransactionListItem.loading()
    : date = null,
      count = 0,
      transaction = null,
      isFirstInGroup = false,
      isLastInGroup = false,
      isLoading = true;
}

// =========================
// TILE
// =========================
class _TransactionTile extends StatelessWidget {
  final TransactionDetailsModel txn;
  const _TransactionTile({required this.txn});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final type = _normalized(txn.type);
    final service = _normalized(txn.service);
    final config = _typeConfig(type, c);
    final amount = txn.amount ?? 0;
    final balanceAfter = txn.balanceAfter ?? 0;
    final isDebit = type == 'debit';
    final sign = isDebit ? '-' : '+';
    final amountColor = isDebit ? c.error : c.green;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDetails(context, txn),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,

                    decoration: BoxDecoration(
                      color: AppConfig.serviceColor(service).withOpacity(0.12),

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Center(
                      child: AppConfig.serviceIcon(
                        service,
                        size: 20,
                        color: AppConfig.serviceColor(service),
                      ),
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
                        border: Border.all(color: c.surface, width: 2),
                      ),
                      child: Icon(config.icon, size: 10, color: config.fg),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
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
                        Flexible(
                          child: Text(
                            txn.time?.isNotEmpty == true ? txn.time! : '--',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: c.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      txn.description?.isNotEmpty == true
                          ? txn.description!
                          : 'Transaction',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: c.textPrimary,
                        height: 1,
                      ),
                    ),
                    if ((txn.dltCharge ?? 0) > 0) ...[
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign₹${amount.toStringAsFixed(amount < 1 ? 3 : 2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bal ₹${balanceAfter.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: c.textMuted,
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

  void _showDetails(BuildContext context, TransactionDetailsModel t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SafeArea(top: false, child: _TxnDetailSheet(txn: t)),
    );
  }

  String _normalized(String? value) => value?.toLowerCase().trim() ?? '';

  _TypeConfig _typeConfig(String type, dynamic c) {
    switch (type) {
      case 'credit':
        return _TypeConfig(
          label: 'Credit',
          icon: Icons.arrow_downward_rounded,
          fg: c.green as Color,
          bg: (c.green as Color).withOpacity(0.15),
        );
      case 'debit':
        return _TypeConfig(
          label: 'Debit',
          icon: Icons.arrow_upward_rounded,
          fg: c.error as Color,
          bg: (c.error as Color).withOpacity(0.15),
        );
      case 'refund':
        return _TypeConfig(
          label: 'Refund',
          icon: Icons.refresh_rounded,
          fg: c.primary as Color,
          bg: (c.primary as Color).withOpacity(0.15),
        );
      default:
        return _TypeConfig(
          label: 'Transaction',
          icon: Icons.receipt_long_rounded,
          fg: c.textSecondary as Color,
          bg: (c.textSecondary as Color).withOpacity(0.15),
        );
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
  final TransactionDetailsModel txn;
  const _TxnDetailSheet({required this.txn});

  String _dateTimeLabel(TransactionDetailsModel txn) {
    final parts = <String>[
      if (txn.date?.isNotEmpty == true) txn.date!,
      if (txn.time?.isNotEmpty == true) txn.time!,
    ];
    return parts.isEmpty ? '--' : parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final type = txn.type?.toLowerCase().trim() ?? '';
    final amount = txn.amount ?? 0;
    final balanceBefore = txn.balanceBefore ?? 0;
    final balanceAfter = txn.balanceAfter ?? 0;
    final isDebit = type == 'debit';
    final amountColor = isDebit ? c.error : c.green;
    final sign = isDebit ? '-' : '+';

    return Container(
      decoration: BoxDecoration(
        color: c.bottomSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: c.bottomSheetHandle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Transaction Details',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$sign₹${amount.toStringAsFixed(amount < 1 ? 3 : 2)}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: amountColor,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            txn.description?.isNotEmpty == true
                ? txn.description!
                : 'Transaction',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(
              children: [
                _DetailRow(
                  label: 'Type',
                  value: type.isNotEmpty ? type.toUpperCase() : '--',
                ),
                _DetailRow(
                  label: 'Service',
                  value: txn.service?.isNotEmpty == true
                      ? txn.service!.toUpperCase()
                      : '--',
                ),
                _DetailRow(
                  label: 'Balance Before',
                  value: '₹${balanceBefore.toStringAsFixed(2)}',
                ),
                _DetailRow(
                  label: 'Balance After',
                  value: '₹${balanceAfter.toStringAsFixed(2)}',
                  isStrong: true,
                ),
                if ((txn.dltCharge ?? 0) > 0)
                  _DetailRow(
                    label: 'DLT Charge',
                    value: '₹${txn.dltCharge!.toStringAsFixed(3)}',
                  ),
                _DetailRow(label: 'Date & Time', value: _dateTimeLabel(txn)),
                _DetailRow(
                  label: 'Transaction ID',
                  value: txn.sId ?? '--',
                  isLast: true,
                  mono: true,
                ),
              ],
            ),
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
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: c.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: c.textPrimary,
                fontWeight: isStrong ? FontWeight.w700 : FontWeight.w600,
                fontFamily: mono ? 'monospace' : null,
                letterSpacing: mono ? 0.3 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) => Center(child: FullScreenLoader());
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: c.primary),
        ),
      ),
    );
  }
}

class _TransactionErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _TransactionErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: c.error, size: 34),
            const SizedBox(height: 12),
            Text(
              'Unable to load transactions',
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
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: c.onBrand,
                elevation: 0,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
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
    final c = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: c.textMuted,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try changing your filters',
            style: TextStyle(fontSize: 12.5, color: c.textMuted),
          ),
        ],
      ),
    );
  }
}
