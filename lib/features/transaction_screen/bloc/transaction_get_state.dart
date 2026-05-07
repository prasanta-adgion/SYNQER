part of 'transaction_get_bloc.dart';

sealed class TransactionGetState extends Equatable {
  const TransactionGetState();

  @override
  List<Object?> get props => [];
}

final class TransactionGetInitial extends TransactionGetState {}

final class TransactionGetLoading extends TransactionGetState {}

class TransactionGetLoaded extends TransactionGetState {
  final List<TransactionDetailsModel> transactions;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentPage;
  final String? serviceType;
  final String? transactionType;
  final String? dateFrom;
  final String? dateTo;

  const TransactionGetLoaded({
    required this.transactions,
    required this.hasMore,
    required this.isLoadingMore,
    required this.currentPage,
    this.serviceType,
    this.transactionType,
    this.dateFrom,
    this.dateTo,
  });

  TransactionGetLoaded copyWith({
    List<TransactionDetailsModel>? transactions,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentPage,
    String? serviceType,
    String? transactionType,
    String? dateFrom,
    String? dateTo,
  }) {
    return TransactionGetLoaded(
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      serviceType: serviceType ?? this.serviceType,
      transactionType: transactionType ?? this.transactionType,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    hasMore,
    isLoadingMore,
    currentPage,
    serviceType,
    transactionType,
    dateFrom,
    dateTo,
  ];
}

class TransactionGetError extends TransactionGetState {
  final String message;

  const TransactionGetError({required this.message});

  @override
  List<Object?> get props => [message];
}
