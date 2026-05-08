import 'package:equatable/equatable.dart';
import 'package:synqer_io/core/utils/date_time_utils.dart';

class ContactsDataModel extends Equatable {
  final String? sId;
  final String? fullName;
  final String? mobileNumber;
  final String? status;
  final int? smsCount;
  final String? groupName;

  final String? date;
  final String? time;

  const ContactsDataModel({
    this.sId,
    this.fullName,
    this.mobileNumber,
    this.status,
    this.smsCount,
    this.groupName,
    this.date,
    this.time,
  });

  factory ContactsDataModel.fromJson(Map<String, dynamic> json) {
    final parseDateTime = DateTimeUtils.parseChatDateTime(json['createdAt']);
    return ContactsDataModel(
      sId: json['_id'] as String?,
      fullName: json['fullName'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      status: json['status'] as String?,
      smsCount: json['smsCount'] as int?,
      groupName: json['groupName'] as String?,
      date: parseDateTime.date,
      time: parseDateTime.time,
    );
  }

  @override
  List<Object?> get props => [
    sId,
    fullName,
    mobileNumber,
    status,
    smsCount,
    groupName,
    date,
    time,
  ];
}
