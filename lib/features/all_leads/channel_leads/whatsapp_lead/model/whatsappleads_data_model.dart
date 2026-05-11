import 'package:equatable/equatable.dart';
import 'package:synqer_io/core/utils/date_time_utils.dart';

class WhatsappLeadsDataModel extends Equatable {
  final String? sId;
  final String? phoneNumber;
  final String? userId;
  final int? iV;
  final String? brandNumber;
  final List<dynamic>? contactNumber;
  final List<dynamic>? email;
  final String? leadType;
  final String? name;
  final List<dynamic>? query;
  final String? remark;
  final String? status;

  final String? createDate;
  final String? createTime;

  final String? updatedDate;
  final String? updatedTime;

  final String? enquiryDate;
  final String? enquiryTime;

  const WhatsappLeadsDataModel({
    this.sId,
    this.phoneNumber,
    this.userId,
    this.iV,
    this.brandNumber,
    this.contactNumber,
    this.email,
    this.leadType,
    this.name,
    this.query,
    this.remark,
    this.status,
    this.updatedDate,
    this.updatedTime,
    this.createDate,
    this.createTime,
    this.enquiryTime,
    this.enquiryDate,
  });

  factory WhatsappLeadsDataModel.fromJson(Map<String, dynamic> json) {
    final parseCreatedAt = DateTimeUtils.parseChatDateTime(json['createdAt']);
    final parseEnquiryAt = DateTimeUtils.parseChatDateTime(
      json['enquiry_date'],
    );
    final parseUpdatedAt = DateTimeUtils.parseChatDateTime(json['updatedAt']);
    return WhatsappLeadsDataModel(
      sId: json['_id'],
      phoneNumber: json['phoneNumber'],
      userId: json['userId'],
      iV: json['__v'],
      brandNumber: json['brand_number'],
      contactNumber: json['contact_number'] is List
          ? List.from(json['contact_number'])
          : null,
      email: json['email'] is List ? List.from(json['email']) : null,
      leadType: json['leadType'],
      name: json['name'],
      query: json['query'] is List ? List.from(json['query']) : null,
      remark: json['remark'],
      status: json['status'],
      createDate: parseCreatedAt.date,
      createTime: parseCreatedAt.time,
      updatedDate: parseUpdatedAt.date,
      updatedTime: parseUpdatedAt.time,
      enquiryDate: parseEnquiryAt.date,
      enquiryTime: parseEnquiryAt.time,
    );
  }

  @override
  List<Object?> get props => [
    sId,
    phoneNumber,
    userId,
    iV,
    brandNumber,
    contactNumber,
    email,
    enquiryDate,
    leadType,
    name,
    query,
    remark,
    status,
    createDate,
    createTime,
    updatedDate,
    updatedTime,
    enquiryTime,
  ];
}
