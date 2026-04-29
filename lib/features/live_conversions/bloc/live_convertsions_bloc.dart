import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:synqer_io/features/live_conversions/model/live_conversions_model.dart';
import 'package:synqer_io/features/live_conversions/repository/conversions_repo.dart';

part 'live_convertsions_event.dart';
part 'live_convertsions_state.dart';

class LiveConvertsionsBloc
    extends Bloc<LiveConvertsionsEvent, LiveConvertsionsState> {
  final ConversionsRepo conversionsRepo;
  LiveConvertsionsBloc({required this.conversionsRepo})
    : super(LiveConvertsionsInitial()) {
    on<FetchLiveConvertionsEvent>(_onFetchLiveConvertionsEvent);
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
        emit(LiveConvertsionsLoaded(conversions: res.data));
      } else {
        emit(
          const LiveConvertsionsError(message: "Failed to load conversions"),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('LiveConvertsionsBloc Error: $e');
      debugPrintStack(stackTrace: stackTrace);

      emit(
        const LiveConvertsionsError(
          message: "An error occurred while loading conversions",
        ),
      );
    }
  }
}
