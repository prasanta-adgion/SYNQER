import 'package:flutter/widgets.dart';
import 'package:synqer_io/app_export.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/model/rcs_preview_model.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/model/templete_details_model.dart';

class RcsPreviewRepo {
  final DioMethodsService dio;

  const RcsPreviewRepo({required this.dio});

  Future<RcsPreviewTempleteDataModel> fetchRcsPreviewTemplete() async {
    final response = await dio.get(
      APIsEndPoints.getRcsPreviewTemplates,
      requiresAuth: true,
    );

    return RcsPreviewTempleteDataModel.fromJson(response);
  }

  Future<SingleTempleteDataModel> fetchTempleteById(String id) async {
    debugPrint("single templete data");

    final response = await dio.get(
      APIsEndPoints.getRcsPreviewTempleteById(id),
      requiresAuth: true,
    );

    return SingleTempleteDataModel.fromJson(response);
  }
}
