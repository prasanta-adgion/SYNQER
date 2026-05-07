import 'package:equatable/equatable.dart';
import 'package:synqer_io/core/utils/date_time_utils.dart';

class TransactionDetailsModel extends Equatable {
  final String? sId;
  final String? userId;
  final String? type;
  final double? amount;
  final double? balanceBefore;
  final double? balanceAfter;
  final String? service;
  final String? description;
  final Meta? meta;
  final String? date;
  final String? time;
  final int? iV;
  final double? dltCharge;

  const TransactionDetailsModel({
    this.sId,
    this.userId,
    this.type,
    this.amount,
    this.balanceBefore,
    this.balanceAfter,
    this.service,
    this.description,
    this.meta,
    this.date,
    this.time,
    this.iV,
    this.dltCharge,
  });

  factory TransactionDetailsModel.fromJson(Map<String, dynamic> json) {
    final parseDateTime = DateTimeUtils.parseChatDateTime(
      json['createdAt'] ?? '',
    );
    return TransactionDetailsModel(
      sId: json['_id'] as String?,
      userId: json['userId'] as String?,
      type: json['type'] as String?,
      amount: _toDouble(json['amount']),
      balanceBefore: _toDouble(json['balanceBefore']),
      balanceAfter: _toDouble(json['balanceAfter']),
      service: json['service'] as String?,
      description: json['description'] as String?,
      meta: json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
      date: parseDateTime.date,
      time: parseDateTime.time,
      iV: _toInt(json['__v']),
      dltCharge: _toDouble(json['dltCharge']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
    sId,
    userId,
    type,
    amount,
    balanceBefore,
    balanceAfter,
    service,
    description,
    meta,
    date,
    time,
    iV,
    dltCharge,
  ];
}

class Meta extends Equatable {
  final String? campaignName;
  final int? totalContacts;
  final double? pricePerMsg;
  final String? campaignId;
  final String? broadcastId;
  final String? templateName;
  final String? templateType;

  const Meta({
    this.campaignName,
    this.totalContacts,
    this.pricePerMsg,
    this.campaignId,
    this.broadcastId,
    this.templateName,
    this.templateType,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      campaignName: json['campaignName'] as String?,
      totalContacts: _toInt(json['totalContacts']),
      pricePerMsg: _toDouble(json['pricePerMsg']),
      campaignId: json['campaignId'] as String?,
      broadcastId: json['broadcastId'] as String?,
      templateName: json['templateName'] as String?,
      templateType: json['templateType'] as String?,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
    campaignName,
    totalContacts,
    pricePerMsg,
    campaignId,
    broadcastId,
    templateName,
    templateType,
  ];
}
