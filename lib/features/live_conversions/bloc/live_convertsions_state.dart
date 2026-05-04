part of 'live_convertsions_bloc.dart';

sealed class LiveConvertsionsState extends Equatable {
  const LiveConvertsionsState();

  @override
  List<Object> get props => [];
}

final class LiveConvertsionsInitial extends LiveConvertsionsState {}

class LiveConvertsionsLoading extends LiveConvertsionsState {}

class LiveConvertsionsLoaded extends LiveConvertsionsState {
  final List<ConversionsChatData> conversions;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentPage;

  const LiveConvertsionsLoaded({
    required this.conversions,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
  });

  LiveConvertsionsLoaded copyWith({
    List<ConversionsChatData>? conversions,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentPage,
  }) {
    return LiveConvertsionsLoaded(
      conversions: conversions ?? this.conversions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [conversions, hasMore, isLoadingMore, currentPage];
}

class LiveConvertsionsError extends LiveConvertsionsState {
  final String message;

  const LiveConvertsionsError({required this.message});

  @override
  List<Object> get props => [message];
}
