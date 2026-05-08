part of 'get_contacts_bloc.dart';

sealed class GetContactsEvent extends Equatable {
  const GetContactsEvent();

  @override
  List<Object?> get props => [];
}

class FetchContactsEvent extends GetContactsEvent {
  final int page;
  final int limit;
  final String? searchValue;

  const FetchContactsEvent({
    required this.page,
    required this.limit,
    this.searchValue,
  });

  @override
  List<Object?> get props => [page, limit, searchValue];
}

class LoadMoreContactsEvent extends GetContactsEvent {
  final int page;
  final int limit;
  final String? searchValue;

  const LoadMoreContactsEvent({
    required this.page,
    required this.limit,
    this.searchValue,
  });

  @override
  List<Object?> get props => [page, limit, searchValue];
}
