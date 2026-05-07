import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:synqer_io/features/transaction_screen/model/transaction_model.dart';
import 'package:synqer_io/features/transaction_screen/repository/transaction_get_repo.dart';

part 'transaction_get_event.dart';
part 'transaction_get_state.dart';

class TransactionGetBloc
    extends Bloc<TransactionGetEvent, TransactionGetState> {
  final TransactionGetRepo transactionGetRepo;

  TransactionGetBloc({required this.transactionGetRepo})
    : super(TransactionGetInitial()) {
    on<FetchTransactionsEvent>(_onFetchTransactions);
    on<LoadMoreTransactionsEvent>(_onLoadMoreTransactions);
  }

  Future<void> _onFetchTransactions(
    FetchTransactionsEvent event,
    Emitter<TransactionGetState> emit,
  ) async {
    emit(TransactionGetLoading());

    try {
      final res = await transactionGetRepo.fetchTransactions(
        page: event.page,
        limit: event.limit,
        serviceType: event.serviceType,
        transactionType: event.transactionType,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      if (res.success) {
        emit(
          TransactionGetLoaded(
            transactions: res.data,
            groupedTransactions: _groupTransactions(res.data),
            hasMore: res.hasMore,
            isLoadingMore: false,
            currentPage: res.page,
            serviceType: event.serviceType,
            transactionType: event.transactionType,
            dateFrom: event.dateFrom,
            dateTo: event.dateTo,
          ),
        );
      } else {
        emit(TransactionGetError(message: res.message));
      }
    } catch (e) {
      emit(TransactionGetError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactionsEvent event,
    Emitter<TransactionGetState> emit,
  ) async {
    if (state is! TransactionGetLoaded) return;

    final currentState = state as TransactionGetLoaded;

    if (currentState.isLoadingMore || !currentState.hasMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final res = await transactionGetRepo.fetchTransactions(
        page: event.page,
        limit: event.limit,
        serviceType: event.serviceType,
        transactionType: event.transactionType,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      if (res.success) {
        final transactions = [...currentState.transactions, ...res.data];
        emit(
          currentState.copyWith(
            transactions: transactions,
            groupedTransactions: _groupTransactions(transactions),
            hasMore: res.hasMore,
            isLoadingMore: false,
            currentPage: res.page,
            serviceType: event.serviceType,
            transactionType: event.transactionType,
            dateFrom: event.dateFrom,
            dateTo: event.dateTo,
          ),
        );
      } else {
        emit(currentState.copyWith(isLoadingMore: false));
      }
    } catch (_) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Map<String, List<TransactionDetailsModel>> _groupTransactions(
    List<TransactionDetailsModel> transactions,
  ) {
    final grouped = <String, List<TransactionDetailsModel>>{};

    for (final transaction in transactions) {
      final key = transaction.date?.isNotEmpty == true
          ? transaction.date!
          : 'Unknown Date';
      grouped.putIfAbsent(key, () => []).add(transaction);
    }

    return grouped;
  }
}
