part of 'transaction_get_bloc.dart';

sealed class TransactionGetEvent extends Equatable {
  const TransactionGetEvent();

  @override
  List<Object?> get props => [];
}

class FetchTransactionsEvent extends TransactionGetEvent {
  final int page;
  final int limit;
  final String? serviceType;
  final String? transactionType;
  final String? dateFrom;
  final String? dateTo;

  const FetchTransactionsEvent({
    this.page = 1,
    this.limit = 20,
    this.serviceType,
    this.transactionType,
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    serviceType,
    transactionType,
    dateFrom,
    dateTo,
  ];
}

class LoadMoreTransactionsEvent extends TransactionGetEvent {
  final int page;
  final int limit;
  final String? serviceType;
  final String? transactionType;
  final String? dateFrom;
  final String? dateTo;

  const LoadMoreTransactionsEvent({
    required this.page,
    this.limit = 20,
    this.serviceType,
    this.transactionType,
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    serviceType,
    transactionType,
    dateFrom,
    dateTo,
  ];
}
