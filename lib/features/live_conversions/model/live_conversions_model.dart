import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class ChatDateTime {
  final String date;
  final String time;

  ChatDateTime({required this.date, required this.time});
}

ChatDateTime parseChatDateTime(String isoDate) {
  try {
    final dateTime = DateTime.parse(isoDate).toLocal();

    final date = DateFormat('dd MMM yyyy').format(dateTime);
    final time = DateFormat('h:mm a').format(dateTime);

    return ChatDateTime(date: date, time: time);
  } catch (e) {
    return ChatDateTime(date: '', time: '');
  }
}

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
    final parsed = parseChatDateTime(json['lastMessageAt'] ?? '');

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
