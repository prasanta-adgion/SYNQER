part of 'whatsappleads_get_bloc.dart';

sealed class WhatsappleadsGetState extends Equatable {
  const WhatsappleadsGetState();

  @override
  List<Object?> get props => [];
}

final class WhatsappleadsGetInitial extends WhatsappleadsGetState {}

class WhatsappleadsGetLoading extends WhatsappleadsGetState {}

class WhatsappleadsLoaded extends WhatsappleadsGetState {
  final List<WhatsappLeadsDataModel> leads;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  final String? searchValue;
  final String? status;
  final String? leadType;

  const WhatsappleadsLoaded({
    required this.leads,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
    this.searchValue,
    this.status,
    this.leadType,
  });

  WhatsappleadsLoaded copyWith({
    List<WhatsappLeadsDataModel>? leads,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    String? searchValue,
    String? status,
    String? leadType,
  }) {
    return WhatsappleadsLoaded(
      leads: leads ?? this.leads,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchValue: searchValue ?? this.searchValue,
      status: status ?? this.status,
      leadType: leadType ?? this.leadType,
    );
  }

  @override
  List<Object?> get props => [
    leads,
    hasMore,
    currentPage,
    isLoadingMore,
    searchValue,
    status,
    leadType,
  ];
}

class WhatsappleadsGetError extends WhatsappleadsGetState {
  final String errorMessage;

  const WhatsappleadsGetError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
