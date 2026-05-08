part of 'get_contacts_bloc.dart';

sealed class GetContactsState extends Equatable {
  const GetContactsState();

  @override
  List<Object> get props => [];
}

final class GetContactsInitial extends GetContactsState {}

final class GetContactsLoading extends GetContactsState {}

final class GetContactsLoaded extends GetContactsState {
  final List<ContactsDataModel> contacts;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  const GetContactsLoaded({
    required this.contacts,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
  });

  GetContactsLoaded copyWith({
    List<ContactsDataModel>? contacts,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return GetContactsLoaded(
      contacts: contacts ?? this.contacts,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [contacts, hasMore, currentPage, isLoadingMore];
}

final class GetContactsError extends GetContactsState {
  final String message;

  const GetContactsError({required this.message});

  @override
  List<Object> get props => [message];
}
