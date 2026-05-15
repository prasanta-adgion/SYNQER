import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/model/manage_template_model.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/repository/manage_template_repo.dart';

part 'manage_templete_event.dart';
part 'manage_templete_state.dart';

class ManageTempleteBloc
    extends Bloc<ManageTempleteEvent, ManageTempleteState> {
  final ManageTemplateRepo _repo;

  ManageTempleteBloc({required ManageTemplateRepo repo})
    : _repo = repo,
      super(ManageTempleteInitial()) {
    on<FetchManageTempleteEvent>(_onFetchTemplates);
    on<LoadMoreManageTempleteEvent>(_onLoadMoreTemplates);
  }

  Future<void> _onFetchTemplates(
    FetchManageTempleteEvent event,
    Emitter<ManageTempleteState> emit,
  ) async {
    emit(ManageTempleteLoading());

    try {
      final result = await _repo.fetchRcsTemplate(
        page: event.page,
        limit: event.limit,
        templateType: event.templateType,
        search: event.searchValue,
      );

      if (result.success) {
        emit(
          ManageTempleteLoaded(
            templates: result.data,
            hasMore: result.hasMore,
            currentPage: result.page,
            limit: result.limit,
            totalItems: result.totalItems,
            searchValue: event.searchValue,
            templateType: event.templateType,
            message: result.message,
          ),
        );
      } else {
        emit(ManageTempleteError(message: result.message));
      }
    } catch (e) {
      emit(ManageTempleteError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreTemplates(
    LoadMoreManageTempleteEvent event,
    Emitter<ManageTempleteState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ManageTempleteLoaded ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = event.page ?? currentState.currentPage + 1;
      final result = await _repo.fetchRcsTemplate(
        page: nextPage,
        limit: event.limit ?? currentState.limit,
        templateType: event.templateType ?? currentState.templateType,
        search: event.searchValue ?? currentState.searchValue,
      );

      if (result.success) {
        emit(
          currentState.copyWith(
            templates: [...currentState.templates, ...result.data],
            hasMore: result.hasMore,
            currentPage: result.page,
            limit: result.limit,
            totalItems: result.totalItems,
            isLoadingMore: false,
            searchValue: event.searchValue ?? currentState.searchValue,
            templateType: event.templateType ?? currentState.templateType,
            message: result.message,
          ),
        );
      } else {
        emit(
          currentState.copyWith(
            isLoadingMore: false,
            loadMoreError: result.message,
          ),
        );
      }
    } catch (e) {
      emit(
        currentState.copyWith(
          isLoadingMore: false,
          loadMoreError: e.toString(),
        ),
      );
    }
  }
}
