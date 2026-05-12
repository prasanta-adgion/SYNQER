part of 'ai_leads_get_bloc.dart';

sealed class AiLeadsGetEvent extends Equatable {
  const AiLeadsGetEvent();

  @override
  List<Object?> get props => [];
}

class FetchAiLeadsEvent extends AiLeadsGetEvent {
  final int page;
  final int limit;
  final String? isContacted;

  const FetchAiLeadsEvent({this.page = 1, this.limit = 10, this.isContacted});

  @override
  List<Object?> get props => [page, limit, isContacted];
}

class LoadMoreAiLeads extends AiLeadsGetEvent {
  final int page;
  final int limit;
  final String? isContacted;

  const LoadMoreAiLeads({
    required this.page,
    this.limit = 20,
    this.isContacted,
  });

  @override
  List<Object?> get props => [page, limit, isContacted];
}
