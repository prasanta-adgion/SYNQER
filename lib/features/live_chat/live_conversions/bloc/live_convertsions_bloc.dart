import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:synqer_io/features/live_chat/live_conversions/model/live_conversions_model.dart';
import 'package:synqer_io/features/live_chat/live_conversions/repository/conversions_repo.dart';

part 'live_convertsions_event.dart';
part 'live_convertsions_state.dart';

class LiveConvertsionsBloc
    extends Bloc<LiveConvertsionsEvent, LiveConvertsionsState> {
  final ConversionsRepo conversionsRepo;

  LiveConvertsionsBloc({required this.conversionsRepo})
    : super(LiveConvertsionsInitial()) {
    on<FetchLiveConvertionsEvent>(_onFetchLiveConvertionsEvent);
    on<LoadMoreLiveConvertionsEvent>(_onLoadMoreLiveConvertionsEvent);
  }

  Future<void> _onFetchLiveConvertionsEvent(
    FetchLiveConvertionsEvent event,
    Emitter<LiveConvertsionsState> emit,
  ) async {
    try {
      emit(LiveConvertsionsLoading());

      final res = await conversionsRepo.getLiveConvertions(
        event.limit,
        event.page,
        event.searchValue,
        event.isUnread,
      );

      if (res.success) {
        emit(
          LiveConvertsionsLoaded(
            conversions: res.data,
            hasMore: res.hasMore,
            currentPage: int.parse(event.page),
          ),
        );
      } else {
        emit(
          const LiveConvertsionsError(message: "Failed to load conversions"),
        );
      }
    } catch (e) {
      emit(
        const LiveConvertsionsError(
          message: "An error occurred while loading conversions",
        ),
      );
    }
  }

  Future<void> _onLoadMoreLiveConvertionsEvent(
    LoadMoreLiveConvertionsEvent event,
    Emitter<LiveConvertsionsState> emit,
  ) async {
    final currentState = state;

    if (currentState is! LiveConvertsionsLoaded) return;

    if (currentState.isLoadingMore || !currentState.hasMore) return;

    try {
      emit(currentState.copyWith(isLoadingMore: true));

      final res = await conversionsRepo.getLiveConvertions(
        event.limit,
        event.page,
        event.searchValue,
        event.isUnread,
      );

      if (res.success) {
        emit(
          currentState.copyWith(
            conversions: [...currentState.conversions, ...res.data],
            hasMore: res.hasMore,
            currentPage: int.parse(event.page),
            isLoadingMore: false,
          ),
        );
      }
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}
