part of 'get_groups_bloc.dart';

sealed class GetGroupsState extends Equatable {
  const GetGroupsState();

  @override
  List<Object?> get props => [];
}

final class GetGroupsInitial extends GetGroupsState {}

class GetGroupsLoading extends GetGroupsState {}

class GetGroupsLoaded extends GetGroupsState {
  final List<GroupsDataModel> groups;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentPage;
  final String search;

  const GetGroupsLoaded({
    required this.groups,
    required this.hasMore,
    required this.isLoadingMore,
    required this.currentPage,
    required this.search,
  });

  GetGroupsLoaded copyWith({
    List<GroupsDataModel>? groups,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentPage,
    String? search,
  }) {
    return GetGroupsLoaded(
      groups: groups ?? this.groups,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [
    groups,
    hasMore,
    isLoadingMore,
    currentPage,
    search,
  ];
}

class GetGroupsError extends GetGroupsState {
  final String message;

  const GetGroupsError({required this.message});

  @override
  List<Object?> get props => [message];
}
