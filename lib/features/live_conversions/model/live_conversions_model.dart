import 'package:equatable/equatable.dart';
import 'package:synqer_io/core/utils/date_time_utils.dart';

class ConversionsChatData extends Equatable {
  final String? customerName;
  final String? lastMessage;
  final String? lastDirection;
  final String date;
  final String time;
  final int? unreadCount;
  final String? customerMobile;

  const ConversionsChatData({
    this.customerName,
    this.lastMessage,
    this.lastDirection,

    required this.date,
    required this.time,
    this.unreadCount,
    this.customerMobile,
  });

  factory ConversionsChatData.fromJson(Map<String, dynamic> json) {
    final parsed = DateTimeUtils.parseChatDateTime(json['lastMessageAt'] ?? '');

    return ConversionsChatData(
      customerName: json['customerName'] ?? '',
      lastMessage: json['lastMessage'] ?? "",
      lastDirection: json['lastDirection'] ?? '',
      date: parsed.date,
      time: parsed.time,
      unreadCount: json['unreadCount'] ?? '',
      customerMobile: json['customerMobile'] ?? '',
    );
  }

  @override
  List<Object?> get props {
    return [
      customerName,
      lastMessage,
      lastDirection,
      date,
      time,
      unreadCount,
      customerMobile,
    ];
  }
}
