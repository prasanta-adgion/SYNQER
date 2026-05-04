import 'package:synqer_io/core/utils/date_time_utils.dart';

class GroupsDataModel {
  int? totalNumbers;
  String? date;
  String? time;
  String? groupName;

  GroupsDataModel({this.totalNumbers, this.date, this.time, this.groupName});

  factory GroupsDataModel.fromJson(Map<String, dynamic> json) {
    final parse = DateTimeUtils.parseChatDateTime(json['lastActivity']);
    return GroupsDataModel(
      totalNumbers: json['totalNumbers'],
      date: parse.date,
      time: parse.time,
      groupName: json['groupName'],
    );
  }
}
