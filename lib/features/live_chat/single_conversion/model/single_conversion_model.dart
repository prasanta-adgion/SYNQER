import 'package:equatable/equatable.dart';
import 'package:synqer_io/core/utils/date_time_utils.dart';

enum MessageStatus { sent, delivered, read }

enum MessageType { text, image, video, document }

/// Convert String -> MessageStatus
MessageStatus getMessageStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'sent':
      return MessageStatus.sent;

    case 'delivered':
      return MessageStatus.delivered;

    case 'read':
      return MessageStatus.read;

    default:
      return MessageStatus.sent;
  }
}

/// Convert String -> MessageType
MessageType getMessageType(String? type) {
  switch (type?.toLowerCase()) {
    case 'text':
      return MessageType.text;

    case 'image':
      return MessageType.image;

    case 'video':
      return MessageType.video;

    case 'document':
      return MessageType.document;

    default:
      return MessageType.text;
  }
}

class SingleConversionModel extends Equatable {
  final String? sId;
  final String? senderName;
  final String? message;
  final String? mediaUrl;

  final String? direction;
  final String? providerLogId;

  final bool? isRead;

  final MessageStatus status;
  final MessageType messageType;

  final String? deliveredDate;
  final String? deliveredTime;

  final String createDate;
  final String createTime;

  final String? readDate;
  final String? readTime;

  // ───── Local UI State ─────
  final bool isLocal;
  final bool isFailed;
  final String? tempId;

  const SingleConversionModel({
    this.sId,
    this.senderName,
    this.message,
    this.mediaUrl,
    this.direction,
    this.providerLogId,
    this.isRead,

    required this.status,
    required this.messageType,

    this.deliveredDate,
    this.deliveredTime,

    required this.createDate,
    required this.createTime,

    this.readDate,
    this.readTime,

    // local
    this.isLocal = false,
    this.isFailed = false,
    this.tempId,
  });

  factory SingleConversionModel.fromJson(Map<String, dynamic> json) {
    final parsedCreate = DateTimeUtils.parseChatDateTime(
      json['createdAt'] ?? '',
    );

    final parsedRead = DateTimeUtils.parseChatDateTime(json['readAt'] ?? '');

    final parsedDelivered = DateTimeUtils.parseChatDateTime(
      json['deliveredAt'] ?? '',
    );

    return SingleConversionModel(
      sId: json['_id'],
      senderName: json['senderName'],
      message: json['message'],
      mediaUrl: json['mediaUrl'],
      direction: json['direction'],
      providerLogId: json['providerLogId'],
      isRead: json['isRead'] ?? false,

      status: getMessageStatus(json['status']),
      messageType: getMessageType(json['messageType']),

      deliveredDate: parsedDelivered.date,
      deliveredTime: parsedDelivered.time,

      createDate: parsedCreate.date,
      createTime: parsedCreate.time,

      readDate: parsedRead.date,
      readTime: parsedRead.time,

      // local states
      isLocal: false,
      isFailed: false,
      tempId: null,
    );
  }

  SingleConversionModel copyWith({bool? isLocal, bool? isFailed}) {
    return SingleConversionModel(
      sId: sId,
      senderName: senderName,
      message: message,
      mediaUrl: mediaUrl,
      direction: direction,
      providerLogId: providerLogId,
      isRead: isRead,
      status: status,
      messageType: messageType,
      deliveredDate: deliveredDate,
      deliveredTime: deliveredTime,
      createDate: createDate,
      createTime: createTime,
      readDate: readDate,
      readTime: readTime,
      tempId: tempId,

      isLocal: isLocal ?? this.isLocal,
      isFailed: isFailed ?? this.isFailed,
    );
  }

  @override
  List<Object?> get props => [
    sId,
    senderName,
    message,
    mediaUrl,
    direction,
    providerLogId,
    isRead,
    status,
    messageType,
    deliveredDate,
    deliveredTime,
    createDate,
    createTime,
    readDate,
    readTime,
    isLocal,
    isFailed,
    tempId,
  ];
}
