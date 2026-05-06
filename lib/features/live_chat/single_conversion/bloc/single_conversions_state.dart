part of 'single_conversions_bloc.dart';

sealed class SingleConversionsState extends Equatable {
  const SingleConversionsState();

  @override
  List<Object?> get props => [];
}

final class SingleConversionsInitial extends SingleConversionsState {}

class SingleConversionsLoading extends SingleConversionsState {}

class SingleConversionsLoaded extends SingleConversionsState {
  final List<SingleConversionModel> conversions;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool isSendingMessage;
  final int currentPage;
  final int totalPages;
  final String? sendFailureMessage;
  final int sendFailureId;

  const SingleConversionsLoaded({
    required this.conversions,
    required this.hasMore,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.isSendingMessage = false,
    required this.currentPage,
    required this.totalPages,
    this.sendFailureMessage,
    this.sendFailureId = 0,
  });

  SingleConversionsLoaded copyWith({
    List<SingleConversionModel>? conversions,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? isSendingMessage,
    int? currentPage,
    int? totalPages,
    String? sendFailureMessage,
    bool clearSendFailure = false,
    int? sendFailureId,
  }) {
    return SingleConversionsLoaded(
      conversions: conversions ?? this.conversions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      sendFailureMessage: clearSendFailure
          ? null
          : sendFailureMessage ?? this.sendFailureMessage,
      sendFailureId: sendFailureId ?? this.sendFailureId,
    );
  }

  @override
  List<Object?> get props => [
    conversions,
    hasMore,
    isLoadingMore,
    isRefreshing,
    isSendingMessage,
    currentPage,
    totalPages,
    sendFailureMessage,
    sendFailureId,
  ];
}

class SingleConversionsError extends SingleConversionsState {
  final String errorMessage;

  const SingleConversionsError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
