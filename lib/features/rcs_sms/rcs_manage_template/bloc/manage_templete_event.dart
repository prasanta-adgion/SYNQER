part of 'manage_templete_bloc.dart';

sealed class ManageTempleteEvent extends Equatable {
  const ManageTempleteEvent();

  @override
  List<Object?> get props => [];
}

class FetchManageTempleteEvent extends ManageTempleteEvent {
  final int page;
  final int limit;
  final String? templateType;
  final String? searchValue;

  const FetchManageTempleteEvent({
    this.page = 1,
    this.limit = 20,
    this.templateType,
    this.searchValue,
  });

  @override
  List<Object?> get props => [page, limit, templateType, searchValue];
}

class LoadMoreManageTempleteEvent extends ManageTempleteEvent {
  final int? page;
  final int? limit;
  final String? templateType;
  final String? searchValue;

  const LoadMoreManageTempleteEvent({
    this.page,
    this.limit,
    this.templateType,
    this.searchValue,
  });

  @override
  List<Object?> get props => [page, limit, templateType, searchValue];
}
