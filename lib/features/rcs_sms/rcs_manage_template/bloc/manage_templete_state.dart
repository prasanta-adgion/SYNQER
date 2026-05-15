part of 'manage_templete_bloc.dart';

sealed class ManageTempleteState extends Equatable {
  const ManageTempleteState();

  @override
  List<Object?> get props => [];
}

final class ManageTempleteInitial extends ManageTempleteState {}

final class ManageTempleteLoading extends ManageTempleteState {}

final class ManageTempleteLoaded extends ManageTempleteState {
  final List<RcsTemplateData> templates;
  final bool hasMore;
  final int currentPage;
  final int limit;
  final int totalItems;
  final bool isLoadingMore;
  final String? searchValue;
  final String? templateType;
  final String? message;
  final String? loadMoreError;

  const ManageTempleteLoaded({
    required this.templates,
    required this.hasMore,
    required this.currentPage,
    required this.limit,
    required this.totalItems,
    this.isLoadingMore = false,
    this.searchValue,
    this.templateType,
    this.message,
    this.loadMoreError,
  });

  ManageTempleteLoaded copyWith({
    List<RcsTemplateData>? templates,
    bool? hasMore,
    int? currentPage,
    int? limit,
    int? totalItems,
    bool? isLoadingMore,
    String? searchValue,
    String? templateType,
    String? message,
    String? loadMoreError,
  }) {
    return ManageTempleteLoaded(
      templates: templates ?? this.templates,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      totalItems: totalItems ?? this.totalItems,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchValue: searchValue ?? this.searchValue,
      templateType: templateType ?? this.templateType,
      message: message ?? this.message,
      loadMoreError: loadMoreError,
    );
  }

  @override
  List<Object?> get props => [
    templates,
    hasMore,
    currentPage,
    limit,
    totalItems,
    isLoadingMore,
    searchValue,
    templateType,
    message,
    loadMoreError,
  ];
}

final class ManageTempleteError extends ManageTempleteState {
  final String message;

  const ManageTempleteError({required this.message});

  @override
  List<Object?> get props => [message];
}
