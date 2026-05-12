import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:synqer_io/features/all_leads/website_lead/ai_lead/model/ai_leads_model.dart';
import 'package:synqer_io/features/all_leads/website_lead/ai_lead/repository/ai_lead_repository.dart';

part 'ai_leads_get_event.dart';
part 'ai_leads_get_state.dart';

class AiLeadsGetBloc extends Bloc<AiLeadsGetEvent, AiLeadsGetState> {
  final AiLeadRepository aiLeadRepository;

  AiLeadsGetBloc({required this.aiLeadRepository})
    : super(AiLeadsGetInitial()) {
    on<FetchAiLeadsEvent>(_onFetchAiLeads);
    on<LoadMoreAiLeads>(_onLoadMoreAiLeads);
  }

  Future<void> _onFetchAiLeads(
    FetchAiLeadsEvent event,
    Emitter<AiLeadsGetState> emit,
  ) async {
    emit(AiLeadsGetLoading());
    try {
      final res = await aiLeadRepository.fetchAiLeads(
        page: event.page,
        limit: event.limit,
        isContacted: event.isContacted,
      );

      if (res.success) {
        emit(
          AiLeadsLoaded(
            aiLeads: res.data,
            hasMore: res.hasMore,
            currentPage: res.page,
            isLoadingMore: false,
            isContacted: event.isContacted,
          ),
        );
      } else {
        emit(AiLeadsGetError(errorMessage: res.message));
      }
    } catch (e) {
      emit(AiLeadsGetError(errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMoreAiLeads(
    LoadMoreAiLeads event,
    Emitter<AiLeadsGetState> emit,
  ) async {
    if (state is! AiLeadsLoaded) return;

    final currentState = state as AiLeadsLoaded;

    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final res = await aiLeadRepository.fetchAiLeads(
        page: event.page,

        limit: event.limit,
        isContacted: event.isContacted ?? currentState.isContacted,
      );

      if (res.success) {
        emit(
          currentState.copyWith(
            aiLeads: [...currentState.aiLeads, ...res.data],
            hasMore: res.hasMore,
            currentPage: res.page,
            isLoadingMore: false,
            isContacted: event.isContacted ?? currentState.isContacted,
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
