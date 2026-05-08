import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:synqer_io/core/constants/apis_end_points.dart';
import 'package:synqer_io/core/model/paginated_response.dart';
import 'package:synqer_io/core/network/dio_methods_service.dart';
import 'package:synqer_io/features/live_chat/single_conversion/model/single_conversion_model.dart';

class SingleConversionRepo {
  final DioMethodsService dio;

  SingleConversionRepo({required this.dio});

  Future<PaginatedResponse<SingleConversionModel>> fetchSingleConversion({
    required String customerMobile,
    int page = 1,
    int limit = 50,
  }) async {
    final res = await dio.get(
      APIsEndPoints.singleConvertion,
      requiresAuth: true,
      queryParameters: {
        'customerMobile': customerMobile,
        'page': page,
        'limit': limit,
      },
    );

    bool hasMore =
        ((res['page'] ?? 1) * (res['limit'] ?? 0)) < (res['total'] ?? 0);

    final data = await compute(parseSingleChats, res['data']);

    return PaginatedResponse(
      data: data,
      success: res['success'] ?? false,
      message: res['message'] ?? '',
      page: res['page'],
      limit: res['limit'],
      totalItems: res['total'],
      totalPages: res['totalPages'],
      hasMore: hasMore,
    );
  }

  Future<dynamic> sendMessage({
    required String customerMobile,
    required String message,
    required String messageType,
    String? file,
  }) async {
    if (file != null && file.isNotEmpty) {
      final res = await dio.postMultipart(
        APIsEndPoints.sendMessage,
        fileField: 'file',
        files: [File(file)],
        fields: {
          'mobile': customerMobile,
          'message_type': messageType,
          if (message.isNotEmpty) 'message': message,
        },
      );
      debugPrint(res.toString());
      return res;
    }

    final res = await dio.post(APIsEndPoints.sendMessage, requiresAuth: true, {
      'mobile': customerMobile,
      'message_type': messageType,
      'message': message,
    });

    debugPrint(res.toString());
    return res;
  }
}

List<SingleConversionModel> parseSingleChats(dynamic data) {
  return (data as List).map((e) => SingleConversionModel.fromJson(e)).toList();
}
