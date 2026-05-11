import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:synqer_io/features/all_leads/channel_leads/whatsapp_lead/model/whatsappleads_data_model.dart';
import 'package:synqer_io/features/all_leads/channel_leads/whatsapp_lead/repository/whatsapp_leads_repo.dart';

part 'whatsappleads_get_event.dart';
part 'whatsappleads_get_state.dart';

class WhatsappleadsGetBloc
    extends Bloc<WhatsappleadsGetEvent, WhatsappleadsGetState> {
  final WhatsappLeadsRepo whatsappLeadsRepo;

  WhatsappleadsGetBloc({required this.whatsappLeadsRepo})
      : super(WhatsappleadsGetInitial()) {
    on<FetchWhatsappLeadsEvent>(_onFetchWhatsappLeads);
    on<LoadMoreWhatsappLeads>(_onLoadMoreWhatsappLeads);
  }

  Future<void> _onFetchWhatsappLeads(
    FetchWhatsappLeadsEvent event,
    Emitter<WhatsappleadsGetState> emit,
  ) async {
    emit(WhatsappleadsGetLoading());
    try {
      final res = await whatsappLeadsRepo.fetchWhatsappLeads(
        page: event.page,
        limit: event.limit,
        search: event.searchValue,
        status: event.status,
        leadType: event.leadType,
      );

      if (res.success) {
        emit(
          WhatsappleadsLoaded(
            leads: res.data,
            hasMore: res.hasMore,
            currentPage: res.page,
            isLoadingMore: false,
            searchValue: event.searchValue,
            status: event.status,
            leadType: event.leadType,
          ),
        );
      } else {
        emit(WhatsappleadsGetError(errorMessage: res.message));
      }
    } catch (e) {
      emit(WhatsappleadsGetError(errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMoreWhatsappLeads(
    LoadMoreWhatsappLeads event,
    Emitter<WhatsappleadsGetState> emit,
  ) async {
    if (state is! WhatsappleadsLoaded) return;

    final currentState = state as WhatsappleadsLoaded;

    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final res = await whatsappLeadsRepo.fetchWhatsappLeads(
        page: event.page,
        limit: event.limit,
        search: event.searchValue ?? currentState.searchValue,
        status: event.status ?? currentState.status,
        leadType: event.leadType ?? currentState.leadType,
      );

      if (res.success) {
        emit(
          currentState.copyWith(
            leads: [...currentState.leads, ...res.data],
            hasMore: res.hasMore,
            currentPage: res.page,
            isLoadingMore: false,
            searchValue: event.searchValue ?? currentState.searchValue,
            status: event.status ?? currentState.status,
            leadType: event.leadType ?? currentState.leadType,
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
