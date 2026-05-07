part of 'single_conversions_bloc.dart';

sealed class SingleConversionsEvent extends Equatable {
  const SingleConversionsEvent();

  @override
  List<Object> get props => [];
}

class FetchSingleConversionsEvent extends SingleConversionsEvent {
  final String customerMobile;
  final int limit;

  const FetchSingleConversionsEvent({
    required this.customerMobile,
    this.limit = 50,
  });

  @override
  List<Object> get props => [customerMobile, limit];
}

class LoadMoreSingleConversionsEvent extends SingleConversionsEvent {
  final String customerMobile;
  final int limit;

  const LoadMoreSingleConversionsEvent({
    required this.customerMobile,
    this.limit = 50,
  });

  @override
  List<Object> get props => [customerMobile, limit];
}

class SilentRefreshSingleConversionsEvent extends SingleConversionsEvent {
  final String customerMobile;
  final int limit;

  const SilentRefreshSingleConversionsEvent({
    required this.customerMobile,
    this.limit = 50,
  });

  @override
  List<Object> get props => [customerMobile, limit];
}

class SendSingleMessageEvent extends SingleConversionsEvent {
  final String customerMobile;
  final String message;
  final String messageType;
  String? attachment;

  SendSingleMessageEvent({
    required this.customerMobile,
    required this.message,
    this.messageType = 'text',
    this.attachment = '',
  });

  @override
  List<Object> get props => [
    customerMobile,
    message,
    messageType,
    attachment = '',
  ];
}

class MarkMessagesAsReadEvent extends SingleConversionsEvent {
  final String customerMobile;

  const MarkMessagesAsReadEvent({required this.customerMobile});

  @override
  List<Object> get props => [customerMobile];
}
