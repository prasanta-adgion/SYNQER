import 'package:synqer_io/core/constants/apis_end_points.dart';
import 'package:synqer_io/core/network/dio_methods_service.dart';

class SendRcsmessageRepo {
  final DioMethodsService dio;

  const SendRcsmessageRepo({required this.dio});

  Future<dynamic> sendRcsMessage({
    required List<String> phoneNumbers,
    required String templateId,
    required String campaignName,
    required String expireTime,
    required String countryCode,
    Map<String, dynamic>? variables,
  }) async {
    final body = {
      "templateId": templateId,
      "phoneNumbers": phoneNumbers,
      "campaign_name": campaignName,
      "expire_time": expireTime,
      "country_code": countryCode,
      "variables": variables ?? {},
    };

    final response = await dio.post(
      APIsEndPoints.sendRcsBulkMessages,
      body,
      requiresAuth: true,
    );

    return response;
  }
}
