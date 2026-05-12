import 'package:equatable/equatable.dart';
import 'package:synqer_io/core/utils/date_time_utils.dart';

class AiLeadsDataModel extends Equatable {
  final String? sId;
  final String? userId;
  final WidgetConfigId? widgetConfigId;
  final String? chatSessionId;
  final String? sessionId;
  final String? name;
  final String? email;
  final String? phone;
  final String? pageUrl;
  final bool? isContacted;
  final String? notes;
  final String? createdDate;
  final String? createdTime;
  final int? iV;

  const AiLeadsDataModel({
    this.sId,
    this.userId,
    this.widgetConfigId,
    this.chatSessionId,
    this.sessionId,
    this.name,
    this.email,
    this.phone,
    this.pageUrl,
    this.isContacted,
    this.notes,
    this.createdDate,
    this.createdTime,
    this.iV,
  });

  factory AiLeadsDataModel.fromJson(Map<String, dynamic> json) {
    final parseCreatedAt = DateTimeUtils.parseChatDateTime(json['createdAt']);
    return AiLeadsDataModel(
      sId: json['_id'],
      userId: json['userId'],
      widgetConfigId: json['widgetConfigId'] == null
          ? null
          : WidgetConfigId.fromJson(json['widgetConfigId']),
      chatSessionId: json['chatSessionId'],
      sessionId: json['sessionId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      pageUrl: json['pageUrl'],
      isContacted: _parseBool(json['isContacted']),
      notes: json['notes'],
      createdDate: parseCreatedAt.date,
      createdTime: parseCreatedAt.time,
      iV: json['__v'],
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return null;
  }

  @override
  List<Object?> get props => [
    sId,
    userId,
    widgetConfigId,
    chatSessionId,
    sessionId,
    name,
    email,
    phone,
    pageUrl,
    isContacted,
    notes,
    createdDate,
    createdTime,
    iV,
  ];
}

class WidgetConfigId extends Equatable {
  final String? sId;
  final String? apiKey;
  final String? botName;

  const WidgetConfigId({this.sId, this.apiKey, this.botName});

  factory WidgetConfigId.fromJson(Map<String, dynamic> json) {
    return WidgetConfigId(
      sId: json['_id'],
      apiKey: json['apiKey'],
      botName: json['botName'],
    );
  }

  @override
  List<Object?> get props => [sId, apiKey, botName];
}
