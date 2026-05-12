part of 'ai_leads_get_bloc.dart';

sealed class AiLeadsGetState extends Equatable {
  const AiLeadsGetState();

  @override
  List<Object?> get props => [];
}

final class AiLeadsGetInitial extends AiLeadsGetState {}

class AiLeadsGetLoading extends AiLeadsGetState {}

class AiLeadsLoaded extends AiLeadsGetState {
  final List<AiLeadsDataModel> aiLeads;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final String? isContacted;

  const AiLeadsLoaded({
    required this.aiLeads,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
    this.isContacted,
  });

  AiLeadsLoaded copyWith({
    List<AiLeadsDataModel>? aiLeads,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    String? isContacted,
  }) {
    return AiLeadsLoaded(
      aiLeads: aiLeads ?? this.aiLeads,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isContacted: isContacted ?? this.isContacted,
    );
  }

  @override
  List<Object?> get props => [
    aiLeads,
    hasMore,
    currentPage,
    isLoadingMore,
    isContacted,
  ];
}

class AiLeadsGetError extends AiLeadsGetState {
  final String errorMessage;

  const AiLeadsGetError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
