part of 'rcs_leadsget_bloc.dart';

sealed class RcsLeadsgetEvent extends Equatable {
  const RcsLeadsgetEvent();

  @override
  List<Object?> get props => [];
}

class FetchRcsLeadsEvent extends RcsLeadsgetEvent {
  final int page;
  final int limit;
  final String? searchValue;
  final String? eventType;
  final String? fromDate;
  final String? toDate;

  const FetchRcsLeadsEvent({
    this.page = 1,
    this.limit = 20,
    this.searchValue,
    this.eventType,
    this.fromDate,
    this.toDate,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    searchValue,
    eventType,
    fromDate,
    toDate,
  ];
}

class LoadMoreRcsLeads extends RcsLeadsgetEvent {
  final int page;
  final int limit;
  final String? searchValue;
  final String? eventType;
  final String? fromDate;
  final String? toDate;

  const LoadMoreRcsLeads({
    required this.page,
    this.limit = 20,
    this.searchValue,
    this.eventType,
    this.fromDate,
    this.toDate,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    searchValue,
    eventType,
    fromDate,
    toDate,
  ];
}
