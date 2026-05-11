part of 'whatsappleads_get_bloc.dart';

sealed class WhatsappleadsGetEvent extends Equatable {
  const WhatsappleadsGetEvent();

  @override
  List<Object?> get props => [];
}

class FetchWhatsappLeadsEvent extends WhatsappleadsGetEvent {
  final int page;
  final int limit;
  final String? searchValue;
  final String? status;
  final String? leadType;

  const FetchWhatsappLeadsEvent({
    this.page = 1,
    this.limit = 20,
    this.searchValue,
    this.status,
    this.leadType,
  });

  @override
  List<Object?> get props => [page, limit, searchValue, status, leadType];
}

class LoadMoreWhatsappLeads extends WhatsappleadsGetEvent {
  final int page;
  final int limit;
  final String? searchValue;
  final String?
  status; // Pass value in key :=> Pending || Follow+Up || Interested || Not+Interested || Closed
  final String? leadType; //Pass value in key :=> general+enquiry || lead

  const LoadMoreWhatsappLeads({
    required this.page,
    this.limit = 20,
    this.searchValue,
    this.status,
    this.leadType,
  });

  @override
  List<Object?> get props => [page, limit, searchValue, status, leadType];
}
