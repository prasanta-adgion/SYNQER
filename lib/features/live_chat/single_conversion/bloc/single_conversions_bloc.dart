import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:synqer_io/features/live_chat/single_conversion/model/single_conversion_model.dart';
import 'package:synqer_io/features/live_chat/single_conversion/repository/single_conversion_repo.dart';

part 'single_conversions_event.dart';
part 'single_conversions_state.dart';

class SingleConversionsBloc
    extends Bloc<SingleConversionsEvent, SingleConversionsState> {
  final SingleConversionRepo singleConversionRepo;

  SingleConversionsBloc({required this.singleConversionRepo})
    : super(SingleConversionsInitial()) {
    on<FetchSingleConversionsEvent>(_onFetchMessages);
    on<SilentRefreshSingleConversionsEvent>(_onSilentRefreshMessages);
    on<LoadMoreSingleConversionsEvent>(_onLoadMoreMessages);
    on<SendSingleMessageEvent>(_onSendMessage);
  }

  Future<void> _onFetchMessages(
    FetchSingleConversionsEvent event,
    Emitter<SingleConversionsState> emit,
  ) async {
    try {
      emit(SingleConversionsLoading());

      final response = await singleConversionRepo.fetchSingleConversion(
        customerMobile: event.customerMobile,
        page: 1,
        limit: event.limit,
      );

      emit(
        SingleConversionsLoaded(
          conversions: response.data,
          hasMore: response.hasMore,
          currentPage: response.page,
          totalPages: response.totalPages,
        ),
      );
    } catch (e) {
      emit(SingleConversionsError(errorMessage: e.toString()));
    }
  }

  Future<void> _onSilentRefreshMessages(
    SilentRefreshSingleConversionsEvent event,
    Emitter<SingleConversionsState> emit,
  ) async {
    final currentState = state;

    if (currentState is! SingleConversionsLoaded) return;

    try {
      emit(currentState.copyWith(isRefreshing: true));

      final response = await singleConversionRepo.fetchSingleConversion(
        customerMobile: event.customerMobile,
        page: 1,
        limit: event.limit,
      );

      emit(
        currentState.copyWith(
          conversions: _mergeServerMessagesWithPendingLocalMessages(
            response.data,
            currentState.conversions,
          ),
          currentPage: response.page,
          totalPages: response.totalPages,
          hasMore: response.hasMore,
          isRefreshing: false,
          clearSendFailure: true,
        ),
      );
    } catch (_) {
      emit(currentState.copyWith(isRefreshing: false));
    }
  }

  Future<void> _onLoadMoreMessages(
    LoadMoreSingleConversionsEvent event,
    Emitter<SingleConversionsState> emit,
  ) async {
    final currentState = state;

    if (currentState is! SingleConversionsLoaded) return;

    if (currentState.isLoadingMore) return;

    if (!currentState.hasMore) return;

    try {
      emit(currentState.copyWith(isLoadingMore: true));

      final nextPage = currentState.currentPage + 1;

      final response = await singleConversionRepo.fetchSingleConversion(
        customerMobile: event.customerMobile,
        page: nextPage,
        limit: event.limit,
      );

      emit(
        currentState.copyWith(
          conversions: [
            ...currentState.conversions,
            ...response.data,
          ],
          currentPage: response.page,
          totalPages: response.totalPages,
          hasMore: response.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onSendMessage(
    SendSingleMessageEvent event,
    Emitter<SingleConversionsState> emit,
  ) async {
    final currentState = state;

    if (currentState is! SingleConversionsLoaded) return;

    final text = event.message.trim();
    final hasFile = event.attachment != null && event.attachment!.isNotEmpty;

    if (text.isEmpty && !hasFile) return;

    final tempId = DateTime.now().microsecondsSinceEpoch.toString();
    final localMessage = _createLocalMessage(
      tempId: tempId,
      message: text,
      messageType: event.messageType,
      attachment: hasFile ? event.attachment : null,
    );

    emit(
      currentState.copyWith(
        conversions: [localMessage, ...currentState.conversions],
        isSendingMessage: true,
        clearSendFailure: true,
      ),
    );

    try {
      final response = await singleConversionRepo.sendMessage(
        customerMobile: event.customerMobile,
        message: text,
        messageType: event.messageType,
        file: event.attachment,
      );

      final isSuccess = response is Map && response['success'] == true;

      if (!isSuccess) {
        String message;

        if (response is Map) {
          final rawMessage = response['message']?.toString() ?? '';

          if (rawMessage.contains(
            'The 24-hour customer service window has expired',
          )) {
            message =
                'You can’t reply to this chat right now because the 24-hour reply window has expired. Ask the customer to send a new message to continue.';
          } else {
            message = rawMessage;
          }
        } else {
          message = 'Failed to send message';
        }

        _removeLocalMessageAndEmitFailure(
          emit,
          tempId: tempId,
          message: message,
        );

        return;
      }

      await _refreshAfterSuccessfulSend(
        emit,
        customerMobile: event.customerMobile,
        sentTempId: tempId,
      );
    } catch (_) {
      _removeLocalMessageAndEmitFailure(
        emit,
        tempId: tempId,
        message: 'Error in sending message',
      );
    }
  }

  Future<void> _refreshAfterSuccessfulSend(
    Emitter<SingleConversionsState> emit, {
    required String customerMobile,
    required String sentTempId,
    int limit = 25,
  }) async {
    final currentState = state;

    if (currentState is! SingleConversionsLoaded) return;

    try {
      final response = await singleConversionRepo.fetchSingleConversion(
        customerMobile: customerMobile,
        page: 1,
        limit: limit,
      );

      emit(
        currentState.copyWith(
          conversions: _mergeServerMessagesWithPendingLocalMessages(
            response.data,
            currentState.conversions,
            excludeTempIds: {sentTempId},
          ),
          hasMore: response.hasMore,
          currentPage: response.page,
          totalPages: response.totalPages,
          isSendingMessage: false,
          clearSendFailure: true,
        ),
      );
    } catch (_) {
      emit(
        currentState.copyWith(
          conversions: currentState.conversions
              .map(
                (message) => message.tempId == sentTempId
                    ? message.copyWith(isLocal: false)
                    : message,
              )
              .toList(),
          isSendingMessage: false,
          clearSendFailure: true,
        ),
      );
    }
  }

  void _removeLocalMessageAndEmitFailure(
    Emitter<SingleConversionsState> emit, {
    required String tempId,
    required String message,
  }) {
    final currentState = state;

    if (currentState is! SingleConversionsLoaded) return;

    emit(
      currentState.copyWith(
        conversions: currentState.conversions
            .where((conversion) => conversion.tempId != tempId)
            .toList(),
        isSendingMessage: false,
        sendFailureMessage: message,
        sendFailureId: currentState.sendFailureId + 1,
      ),
    );
  }

  SingleConversionModel _createLocalMessage({
    required String tempId,
    required String message,
    String messageType = 'text',
    String? attachment,
  }) {
    final now = DateTime.now();

    return SingleConversionModel(
      tempId: tempId,
      message: message.isNotEmpty ? message : null,
      mediaUrl: attachment,
      direction: 'outbound',
      isLocal: true,
      isFailed: false,
      status: MessageStatus.sent,
      messageType: getMessageType(messageType),
      createDate: DateFormat('dd MMM yyyy').format(now),
      createTime: DateFormat('h:mm a').format(now),
      isRead: false,
    );
  }

  List<SingleConversionModel> _mergeServerMessagesWithPendingLocalMessages(
    List<SingleConversionModel> serverMessages,
    List<SingleConversionModel> currentMessages, {
    Set<String> excludeTempIds = const {},
  }) {
    final pendingLocalMessages = currentMessages.where((message) {
      final tempId = message.tempId;

      return message.isLocal &&
          tempId != null &&
          !excludeTempIds.contains(tempId);
    });

    return [...pendingLocalMessages, ...serverMessages];
  }
}
