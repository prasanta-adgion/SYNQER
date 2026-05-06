import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:synqer_io/features/live_chat/save_contact/model/groups_model.dart';
import 'package:synqer_io/features/live_chat/save_contact/repository/get_groups_repo.dart';

part 'get_groups_event.dart';
part 'get_groups_state.dart';

class GetGroupsBloc extends Bloc<GetGroupsEvent, GetGroupsState> {
  final GetGroupsRepo getGroupsRepo;

  GetGroupsBloc({required this.getGroupsRepo}) : super(GetGroupsInitial()) {
    on<FetchGroupsEvent>(_onFetchGroups);
    on<LoadMoreGroupsEvent>(_onLoadMoreGroups);
  }

  Future<void> _onFetchGroups(
    FetchGroupsEvent event,
    Emitter<GetGroupsState> emit,
  ) async {
    emit(GetGroupsLoading());

    try {
      final res = await getGroupsRepo.fetchGroups(
        page: event.page,
        limit: event.limit,
        searchValue: event.search,
      );

      if (res.success) {
        emit(
          GetGroupsLoaded(
            groups: res.data,
            hasMore: res.hasMore,
            isLoadingMore: false,
            currentPage: res.page,
            search: event.search,
          ),
        );
      } else {
        emit(GetGroupsError(message: res.message));
      }
    } catch (e) {
      emit(GetGroupsError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreGroups(
    LoadMoreGroupsEvent event,
    Emitter<GetGroupsState> emit,
  ) async {
    if (state is! GetGroupsLoaded) return;

    final currentState = state as GetGroupsLoaded;

    if (currentState.isLoadingMore || !currentState.hasMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final res = await getGroupsRepo.fetchGroups(
        page: event.page,
        limit: event.limit,
        searchValue: event.search,
      );

      if (res.success) {
        emit(
          currentState.copyWith(
            groups: [...currentState.groups, ...res.data],
            hasMore: res.hasMore,
            isLoadingMore: false,
            currentPage: res.page,
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
