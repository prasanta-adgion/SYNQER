import 'package:equatable/equatable.dart';

class RcsPreviewTempleteDataModel extends Equatable {
  final bool success;
  final List<Data>? data;

  const RcsPreviewTempleteDataModel({required this.success, this.data});

  factory RcsPreviewTempleteDataModel.fromJson(Map<String, dynamic> json) {
    return RcsPreviewTempleteDataModel(
      success: json['success'],
      data: json['data'] == null
          ? []
          : List<Data>.from(json['data']!.map((x) => Data.fromJson(x))),
    );
  }

  @override
  List<Object?> get props => [success, data];
}

class Data extends Equatable {
  final String? sId;
  final String? name;
  final String? type;

  const Data({this.sId, this.name, this.type});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(sId: json['_id'], name: json['name'], type: json['type']);
  }

  @override
  List<Object?> get props => [sId, name, type];
}
