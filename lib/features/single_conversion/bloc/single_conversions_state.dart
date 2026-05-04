part of 'single_conversions_bloc.dart';

sealed class SingleConversionsState extends Equatable {
  const SingleConversionsState();

  @override
  List<Object> get props => [];
}

final class SingleConversionsInitial extends SingleConversionsState {}

class SingleConversionsLoading extends SingleConversionsState {}

class SingleConversionsLoaded extends SingleConversionsState {
  final List<SingleConversionModel> conversions;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final int currentPage;
  final int totalPages;

  const SingleConversionsLoaded({
    required this.conversions,
    required this.hasMore,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    required this.currentPage,
    required this.totalPages,
  });

  SingleConversionsLoaded copyWith({
    List<SingleConversionModel>? conversions,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    int? currentPage,
    int? totalPages,
  }) {
    return SingleConversionsLoaded(
      conversions: conversions ?? this.conversions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object> get props => [
    conversions,
    hasMore,
    isLoadingMore,
    isRefreshing,
    currentPage,
    totalPages,
  ];
}

class SingleConversionsError extends SingleConversionsState {
  final String errorMessage;

  const SingleConversionsError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
