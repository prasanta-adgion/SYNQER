import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:synqer_io/features/all_leads/channel_leads/rcs_lead/model/rcsleads_data_model.dart';
import 'package:synqer_io/features/all_leads/channel_leads/rcs_lead/repository/rcs_leads_repo.dart';

part 'rcs_leadsget_event.dart';
part 'rcs_leadsget_state.dart';

class RcsLeadsgetBloc extends Bloc<RcsLeadsgetEvent, RcsLeadsgetState> {
  final RcsLeadsRepo rcsLeadsRepo;
  RcsLeadsgetBloc({required this.rcsLeadsRepo}) : super(RcsLeadsgetInitial()) {
    on<FetchRcsLeadsEvent>(_onFetchRcsLeadsEvent);
    on<LoadMoreRcsLeads>(_onLoadMoreRcsLeads);
  }

  Future<void> _onFetchRcsLeadsEvent(
    FetchRcsLeadsEvent event,
    Emitter<RcsLeadsgetState> emit,
  ) async {
    emit(RcsLeadsgetLoading());
    try {
      final res = await rcsLeadsRepo.fetchRcsLeads(
        page: event.page,
        limit: event.limit,
        eventType: event.eventType,
        search: event.searchValue,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      if (res.success) {
        emit(
          RcsLeadsLoaded(
            rcsLeads: res.data,
            hasMore: res.hasMore,
            currentPage: res.page,
            isLoadingMore: false,
            searchValue: event.searchValue,
            eventType: event.eventType,
            dateFrom: event.fromDate,
            dateTo: event.toDate,
          ),
        );
      } else {
        emit(RcsLeadsgetError(errorMessage: res.message));
      }
    } catch (e) {
      emit(RcsLeadsgetError(errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMoreRcsLeads(
    LoadMoreRcsLeads event,
    Emitter<RcsLeadsgetState> emit,
  ) async {
    if (state is! RcsLeadsLoaded) return;

    final currentState = state as RcsLeadsLoaded;

    if (currentState.isLoadingMore || !currentState.hasMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final res = await rcsLeadsRepo.fetchRcsLeads(
        page: event.page,
        limit: event.limit,
        eventType: event.eventType ?? currentState.eventType,
        search: event.searchValue ?? currentState.searchValue,
        fromDate: event.fromDate ?? currentState.dateFrom,
        toDate: event.toDate ?? currentState.dateTo,
      );

      if (res.success) {
        emit(
          currentState.copyWith(
            rcsLeads: [...currentState.rcsLeads, ...res.data],
            hasMore: res.hasMore,
            currentPage: res.page,
            isLoadingMore: false,
            searchValue: event.searchValue ?? currentState.searchValue,
            eventType: event.eventType ?? currentState.eventType,
            dateFrom: event.fromDate ?? currentState.dateFrom,
            dateTo: event.toDate ?? currentState.dateTo,
          ),
        );
      } else {
        emit(currentState.copyWith(isLoadingMore: false));
      }
    } catch (_) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}
