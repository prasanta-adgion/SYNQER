part of 'live_convertsions_bloc.dart';

sealed class LiveConvertsionsEvent extends Equatable {
  const LiveConvertsionsEvent();

  @override
  List<Object> get props => [];
}

class FetchLiveConvertionsEvent extends LiveConvertsionsEvent {
  final String limit;
  final String page;
  final String? searchValue;
  final String isUnread;

  const FetchLiveConvertionsEvent({
    required this.limit,
    required this.page,
    this.searchValue,
    required this.isUnread,
  });

  @override
  List<Object> get props => [limit, page, searchValue ?? "", isUnread];
}

class LoadMoreLiveConvertionsEvent extends LiveConvertsionsEvent {
  final String limit;
  final String page;
  final String? searchValue;
  final String isUnread;

  const LoadMoreLiveConvertionsEvent({
    required this.limit,
    required this.page,
    this.searchValue,
    required this.isUnread,
  });

  @override
  List<Object> get props => [limit, page, searchValue ?? "", isUnread];
}
