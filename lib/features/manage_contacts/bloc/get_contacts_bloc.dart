import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:synqer_io/features/manage_contacts/model/contacts_model.dart';
import 'package:synqer_io/features/manage_contacts/repository/manage_contacts_repo.dart';

part 'get_contacts_event.dart';
part 'get_contacts_state.dart';

class GetContactsBloc extends Bloc<GetContactsEvent, GetContactsState> {
  final ManageContactsRepo _repo;

  GetContactsBloc({required ManageContactsRepo repo})
    : _repo = repo,
      super(GetContactsInitial()) {
    on<FetchContactsEvent>(_onFetchContacts);
    on<LoadMoreContactsEvent>(_onLoadMoreContacts);
  }

  Future<void> _onFetchContacts(
    FetchContactsEvent event,
    Emitter<GetContactsState> emit,
  ) async {
    emit(GetContactsLoading());
    try {
      final result = await _repo.fetchContacts(
        page: event.page,
        limit: event.limit,
        search: event.searchValue,
      );
      emit(
        GetContactsLoaded(
          contacts: result.data,
          hasMore: result.hasMore,
          currentPage: result.page,
        ),
      );
    } catch (e) {
      emit(GetContactsError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreContacts(
    LoadMoreContactsEvent event,
    Emitter<GetContactsState> emit,
  ) async {
    final current = state;
    if (current is! GetContactsLoaded || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      final result = await _repo.fetchContacts(
        page: event.page,
        limit: event.limit,
        search: event.searchValue,
      );
      emit(
        GetContactsLoaded(
          contacts: [...current.contacts, ...result.data],
          hasMore: result.hasMore,
          currentPage: result.page,
        ),
      );
    } catch (e) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
