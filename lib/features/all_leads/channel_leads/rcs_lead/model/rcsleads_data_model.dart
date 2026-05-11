import 'package:equatable/equatable.dart';

class RcsLeadsDataModel extends Equatable {
  final String? sId;
  final String? mobile;
  final List<Interaction> interactions;

  const RcsLeadsDataModel({
    this.sId,
    this.mobile,
    this.interactions = const [],
  });

  factory RcsLeadsDataModel.fromJson(Map<String, dynamic> json) {
    return RcsLeadsDataModel(
      sId: json['_id']?.toString(),

      mobile: json['mobile']?.toString(),

      interactions:
          (json['interactions'] as List?)
              ?.map((e) => Interaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [sId, mobile, interactions];
}

class Interaction extends Equatable {
  final String? textMessage;

  final String? responsePostback;
  final String? responseText;
  final String? suggestionType;

  final String? eventTimestamp;
  final String? createdAt;

  final String? eventType;

  const Interaction({
    this.textMessage,

    this.responsePostback,
    this.responseText,
    this.suggestionType,

    this.eventTimestamp,
    this.createdAt,

    this.eventType,
  });

  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      textMessage: json['textMessage']?.toString(),

      responsePostback: json['responsePostback']?.toString(),

      responseText: json['responseText']?.toString(),

      suggestionType: json['suggestionType']?.toString(),

      eventTimestamp: json['eventTimestamp']?.toString(),

      createdAt: json['createdAt']?.toString(),

      eventType: json['eventType']?.toString(),
    );
  }

  bool get isTextMessage => eventType == 'text_message';

  bool get isResponse => eventType == 'response';

  @override
  List<Object?> get props => [
    textMessage,

    responsePostback,
    responseText,
    suggestionType,

    eventTimestamp,
    createdAt,

    eventType,
  ];
}
