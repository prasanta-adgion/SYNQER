part of 'get_groups_bloc.dart';

sealed class GetGroupsEvent extends Equatable {
  const GetGroupsEvent();

  @override
  List<Object?> get props => [];
}

class FetchGroupsEvent extends GetGroupsEvent {
  final int page;
  final int limit;
  final String search;

  const FetchGroupsEvent({this.page = 1, this.limit = 20, this.search = ''});

  @override
  List<Object?> get props => [page, limit, search];
}

class LoadMoreGroupsEvent extends GetGroupsEvent {
  final int page;
  final int limit;
  final String search;

  const LoadMoreGroupsEvent({
    required this.page,
    required this.limit,
    required this.search,
  });

  @override
  List<Object?> get props => [page, limit, search];
}
