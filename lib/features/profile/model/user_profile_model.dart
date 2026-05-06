import 'package:equatable/equatable.dart';
import 'package:synqer_io/core/utils/date_time_utils.dart';

class UserProfile extends Equatable {
  final bool? success;
  final String? message;
  final User? user;

  const UserProfile({this.success, this.message, this.user});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      success: _asBool(json['success']),
      message: _asString(json['message']),
      user: _asMap(json['user']) == null
          ? null
          : User.fromJson(_asMap(json['user'])!),
    );
  }

  @override
  List<Object?> get props => [success, message, user];
}

class User extends Equatable {
  final Services? services;
  final RcsBalance? rcsBalance;
  final RcsBalance? rcsPricing;
  final Whatsapp? whatsapp;
  final DltEntity? dltEntity;
  final Object? resellerId;
  final String? sId;
  final String? fullName;
  final String? email;
  final String? mobileNumber;
  final String? userName;
  final String? planName;
  final int? planPrice;
  final String? country;
  final int? aiCredits;
  final String? currency;
  final double? smsPricing;
  final double? whatsappPricing;
  final String? status;
  final String? expiryDate;
  final String? expiryTime;
  final List<Object?> rcsApplications;

  final String? createdAt;
  final String? createDate;
  final String? createTime;

  final String? updatedAt;
  final String? updateDate;
  final String? updateTime;

  final int? iV;
  final double? smsBalance;
  final double? whatsappBalance;
  final String? rmlTransUsername;
  final String? profilePicture;
  final String? id;

  const User({
    this.services,
    this.rcsBalance,
    this.rcsPricing,
    this.whatsapp,
    this.dltEntity,
    this.resellerId,
    this.sId,
    this.fullName,
    this.email,
    this.mobileNumber,
    this.userName,
    this.planName,
    this.planPrice,
    this.country,
    this.aiCredits,
    this.currency,
    this.smsPricing,
    this.whatsappPricing,
    this.status,
    this.expiryDate,
    this.expiryTime,
    this.rcsApplications = const [],

    this.createdAt,
    this.createDate,
    this.createTime,

    this.updatedAt,
    this.updateDate,
    this.updateTime,
    this.iV,
    this.smsBalance,
    this.whatsappBalance,
    this.rmlTransUsername,
    this.profilePicture,
    this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final parsedCreateDateTime = DateTimeUtils.parseChatDateTime(
      json['createdAt'] ?? '',
    );

    final parsedUpdateDateTime = DateTimeUtils.parseChatDateTime(
      json['updatedAt'] ?? '',
    );

    final parseExpiryDateTime = DateTimeUtils.parseChatDateTime(
      json['expiryDate'] ?? '',
    );
    return User(
      services: _asMap(json['services']) == null
          ? null
          : Services.fromJson(_asMap(json['services'])!),
      rcsBalance: _asMap(json['rcsBalance']) == null
          ? null
          : RcsBalance.fromJson(_asMap(json['rcsBalance'])!),
      rcsPricing: _asMap(json['rcsPricing']) == null
          ? null
          : RcsBalance.fromJson(_asMap(json['rcsPricing'])!),
      whatsapp: _asMap(json['whatsapp']) == null
          ? null
          : Whatsapp.fromJson(_asMap(json['whatsapp'])!),
      dltEntity: _asMap(json['dltEntity']) == null
          ? null
          : DltEntity.fromJson(_asMap(json['dltEntity'])!),
      resellerId: json['resellerId'],
      sId: _asString(json['_id']),
      fullName: _asString(json['fullName']),
      email: _asString(json['email']),
      mobileNumber: _asString(json['mobileNumber']),
      userName: _asString(json['userName']),
      planName: _asString(json['planName']),
      planPrice: _asInt(json['planPrice']),
      country: _asString(json['country']),
      aiCredits: _asInt(json['aiCredits']),
      currency: _asString(json['currency']),
      smsPricing: _asDouble(json['smsPricing']),
      whatsappPricing: _asDouble(json['whatsappPricing']),
      status: _asString(json['status']),
      expiryDate: parseExpiryDateTime.date,
      expiryTime: parseExpiryDateTime.time,
      rcsApplications: _asList(json['rcsApplications']),
      createdAt: _asString(json['createdAt']),
      createDate: parsedCreateDateTime.date,
      createTime: parsedCreateDateTime.time,
      updatedAt: _asString(json['updatedAt']),
      updateDate: parsedUpdateDateTime.date,
      updateTime: parsedUpdateDateTime.time,
      iV: _asInt(json['__v']),
      smsBalance: _asDouble(json['smsBalance']),
      whatsappBalance: _asDouble(json['whatsappBalance']),
      rmlTransUsername: _asString(json['rmlTransUsername']),
      profilePicture: _asString(json['profilePicture']),
      id: _asString(json['id']),
    );
  }

  @override
  List<Object?> get props => [
    services,
    rcsBalance,
    rcsPricing,
    whatsapp,
    dltEntity,
    resellerId,
    sId,
    fullName,
    email,
    mobileNumber,
    userName,
    planName,
    planPrice,
    country,
    aiCredits,
    currency,
    smsPricing,
    whatsappPricing,
    status,
    expiryDate,
    rcsApplications,
    createdAt,
    updatedAt,
    iV,
    smsBalance,
    whatsappBalance,
    rmlTransUsername,
    profilePicture,
    id,
  ];
}

class Services extends Equatable {
  final bool? chatbot;
  final bool? rcs;
  final bool? sms;
  final bool? whatsapp;

  const Services({this.chatbot, this.rcs, this.sms, this.whatsapp});

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      chatbot: _asBool(json['chatbot']),
      rcs: _asBool(json['rcs']),
      sms: _asBool(json['sms']),
      whatsapp: _asBool(json['whatsapp']),
    );
  }

  @override
  List<Object?> get props => [chatbot, rcs, sms, whatsapp];
}

class RcsBalance extends Equatable {
  final double? text;
  final double? richMedia;

  const RcsBalance({this.text, this.richMedia});

  factory RcsBalance.fromJson(Map<String, dynamic> json) {
    return RcsBalance(
      text: _asDouble(json['text']),
      richMedia: _asDouble(json['richMedia']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'richMedia': richMedia};
  }

  @override
  List<Object?> get props => [text, richMedia];
}

class Whatsapp extends Equatable {
  final Object? accessToken;
  final String? status;
  final String? pinacleApiKey;
  final List<Accounts> accounts;
  final List<Object?> phoneNumber;

  const Whatsapp({
    this.accessToken,
    this.status,
    this.pinacleApiKey,
    this.accounts = const [],
    this.phoneNumber = const [],
  });

  factory Whatsapp.fromJson(Map<String, dynamic> json) {
    return Whatsapp(
      accessToken: json['accessToken'],
      status: _asString(json['status']),
      pinacleApiKey: _asString(json['pinacleApiKey']),
      accounts: _asList(
        json['accounts'],
      ).whereType<Map<String, dynamic>>().map(Accounts.fromJson).toList(),
      phoneNumber: _asList(json['phoneNumber']),
    );
  }

  @override
  List<Object?> get props => [
    accessToken,
    status,
    pinacleApiKey,
    accounts,
    phoneNumber,
  ];
}

class Accounts extends Equatable {
  final String? sId;
  final String? whatsappBusinessAccountId;
  final String? waNumber;
  final String? phoneNumberId;
  final String? id;

  const Accounts({
    this.sId,
    this.whatsappBusinessAccountId,
    this.waNumber,
    this.phoneNumberId,
    this.id,
  });

  factory Accounts.fromJson(Map<String, dynamic> json) {
    return Accounts(
      sId: _asString(json['_id']),
      whatsappBusinessAccountId: _asString(json['whatsappBusinessAccountId']),
      waNumber: _asString(json['waNumber']),
      phoneNumberId: _asString(json['phoneNumberId']),
      id: _asString(json['id']),
    );
  }

  @override
  List<Object?> get props => [
    sId,
    whatsappBusinessAccountId,
    waNumber,
    phoneNumberId,
    id,
  ];
}

class DltEntity extends Equatable {
  final String? entityId;
  final String? companyName;
  final String? date;

  final String? time;

  const DltEntity({this.entityId, this.companyName, this.date, this.time});

  factory DltEntity.fromJson(Map<String, dynamic> json) {
    final praseDateTime = DateTimeUtils.parseChatDateTime(
      json['createdAt'] ?? '',
    );
    return DltEntity(
      entityId: _asString(json['entityId']),
      companyName: _asString(json['companyName']),
      date: praseDateTime.date,
      time: praseDateTime.time,
    );
  }

  @override
  List<Object?> get props => [entityId, companyName, date, time];
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

List<Object?> _asList(Object? value) {
  if (value is List) {
    return List<Object?>.unmodifiable(value);
  }
  return const [];
}

String? _asString(Object? value) {
  return value?.toString();
}

int? _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

double? _asDouble(Object? value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

bool? _asBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    if (normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == '0') {
      return false;
    }
  }
  return null;
}
