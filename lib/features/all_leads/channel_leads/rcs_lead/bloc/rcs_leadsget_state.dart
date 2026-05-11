part of 'rcs_leadsget_bloc.dart';

sealed class RcsLeadsgetState extends Equatable {
  const RcsLeadsgetState();

  @override
  List<Object?> get props => [];
}

final class RcsLeadsgetInitial extends RcsLeadsgetState {}

class RcsLeadsgetLoading extends RcsLeadsgetState {}

class RcsLeadsLoaded extends RcsLeadsgetState {
  final List<RcsLeadsDataModel> rcsLeads;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  final String? searchValue;
  final String? eventType;
  final String? dateFrom;
  final String? dateTo;

  const RcsLeadsLoaded({
    required this.rcsLeads,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
    this.searchValue,
    this.eventType,
    this.dateFrom,
    this.dateTo,
  });

  RcsLeadsLoaded copyWith({
    List<RcsLeadsDataModel>? rcsLeads,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    String? searchValue,
    String? eventType,
    String? dateFrom,
    String? dateTo,
  }) {
    return RcsLeadsLoaded(
      rcsLeads: rcsLeads ?? this.rcsLeads,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchValue: searchValue ?? this.searchValue,
      eventType: eventType ?? this.eventType,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  @override
  List<Object?> get props => [
    rcsLeads,
    hasMore,
    currentPage,
    isLoadingMore,
    searchValue,
    eventType,
    dateFrom,
    dateTo,
  ];
}

class RcsLeadsgetError extends RcsLeadsgetState {
  final String errorMessage;

  const RcsLeadsgetError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
