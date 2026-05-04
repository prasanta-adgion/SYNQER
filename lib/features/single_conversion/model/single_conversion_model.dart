import 'package:equatable/equatable.dart';
import 'package:synqer_io/core/utils/date_time_utils.dart';

class SingleConversionModel extends Equatable {
  final String? sId;
  final String? senderName;
  final String? message;
  final String? messageType;
  final bool? isRead;
  final String? direction;
  final String? status;
  final String? providerLogId;

  final String? deliveredDate;
  final String? deliveredTime;

  final String createDate;
  final String createTime;

  final String? readDate;
  final String? readTime;

  const SingleConversionModel({
    this.sId,
    this.senderName,
    this.message,
    this.messageType,
    this.isRead,
    this.direction,
    this.status,
    this.providerLogId,

    this.deliveredDate,
    this.deliveredTime,

    required this.createDate,
    required this.createTime,

    this.readDate,
    this.readTime,
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
      sId: json['_id'] ?? '',
      senderName: json['senderName'] ?? '',
      message: json['message'] ?? '',
      messageType: json['messageType'] ?? '',
      isRead: json['isRead'] ?? false,
      direction: json['direction'] ?? '',
      status: json['status'] ?? '',
      providerLogId: json['providerLogId'] ?? '',
      deliveredDate: parsedDelivered.date.toString(),
      deliveredTime: parsedDelivered.time.toString(),
      createDate: parsedCreate.date.toString(),
      createTime: parsedCreate.time.toString(),
      readDate: parsedRead.date.toString(),
      readTime: parsedRead.time.toString(),
    );
  }

  @override
  List<Object?> get props => [
    sId,
    senderName,
    message,
    messageType,
    isRead,
    direction,
    status,
    providerLogId,
    deliveredDate,
    deliveredTime,
    readDate,
    readTime,
    createDate,
    createTime,
  ];
}
