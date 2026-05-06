import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:synqer_io/features/live_chat/single_conversion/model/single_conversion_model.dart';
import 'package:synqer_io/features/live_chat/single_conversion/repository/single_conversion_repo.dart';

part 'single_conversions_event.dart';
part 'single_conversions_state.dart';

class SingleConversionsBloc
    extends Bloc<SingleConversionsEvent, SingleConversionsState> {
  final SingleConversionRepo singleConversionRepo;

  SingleConversionsBloc({required this.singleConversionRepo})
    : super(SingleConversionsInitial()) {
    on<FetchSingleConversionsEvent>(_onFetchMessages);
    on<SilentRefreshSingleConversionsEvent>(_onSilentRefreshMessages);
    on<LoadMoreSingleConversionsEvent>(_onLoadMoreMessages);
  }

  Future<void> _onFetchMessages(
    FetchSingleConversionsEvent event,
    Emitter<SingleConversionsState> emit,
  ) async {
    try {
      emit(SingleConversionsLoading());

      final firstResponse = await singleConversionRepo.fetchSingleConversion(
        customerMobile: event.customerMobile,
        page: 1,
        limit: event.limit,
      );

      final lastPage = firstResponse.totalPages;

      final latestMessages = await singleConversionRepo.fetchSingleConversion(
        customerMobile: event.customerMobile,
        page: lastPage,
        limit: event.limit,
      );

      emit(
        SingleConversionsLoaded(
          conversions: latestMessages.data,
          hasMore: lastPage > 1,
          currentPage: lastPage,
          totalPages: lastPage,
        ),
      );
    } catch (e) {
      emit(SingleConversionsError(errorMessage: e.toString()));
    }
  }

  Future<void> _onSilentRefreshMessages(
    SilentRefreshSingleConversionsEvent event,
    Emitter<SingleConversionsState> emit,
  ) async {
    final currentState = state;

    if (currentState is! SingleConversionsLoaded) return;

    try {
      emit(currentState.copyWith(isRefreshing: true));

      final firstResponse = await singleConversionRepo.fetchSingleConversion(
        customerMobile: event.customerMobile,
        page: 1,
        limit: event.limit,
      );

      final lastPage = firstResponse.totalPages;

      final latestMessages = await singleConversionRepo.fetchSingleConversion(
        customerMobile: event.customerMobile,
        page: lastPage,
        limit: event.limit,
      );

      emit(
        currentState.copyWith(
          conversions: latestMessages.data,
          currentPage: lastPage,
          totalPages: lastPage,
          hasMore: lastPage > 1,
          isRefreshing: false,
        ),
      );
    } catch (_) {
      emit(currentState.copyWith(isRefreshing: false));
    }
  }

  Future<void> _onLoadMoreMessages(
    LoadMoreSingleConversionsEvent event,
    Emitter<SingleConversionsState> emit,
  ) async {
    final currentState = state;

    if (currentState is! SingleConversionsLoaded) return;

    if (currentState.isLoadingMore) return;

    if (!currentState.hasMore) return;

    try {
      emit(currentState.copyWith(isLoadingMore: true));

      final nextPage = currentState.currentPage - 1;

      final response = await singleConversionRepo.fetchSingleConversion(
        customerMobile: event.customerMobile,
        page: nextPage,
        limit: event.limit,
      );

      final updatedMessages = [...response.data, ...currentState.conversions];

      emit(
        currentState.copyWith(
          conversions: updatedMessages,
          currentPage: nextPage,
          hasMore: nextPage > 1,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  // Optimistic UI update
  void addLocalMessage(SingleConversionModel message) {
    final currentState = state;

    if (currentState is! SingleConversionsLoaded) return;

    final updatedMessages = [...currentState.conversions, message];

    emit(currentState.copyWith(conversions: updatedMessages));
  }
}
