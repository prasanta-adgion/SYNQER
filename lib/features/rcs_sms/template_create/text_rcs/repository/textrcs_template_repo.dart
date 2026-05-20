import 'package:synqer_io/app_export.dart';

class TextRcsTemplateRepo {
  final DioMethodsService dio;

  const TextRcsTemplateRepo({required this.dio});

  Future<dynamic> createTextRcsTemplate({
    required String name,
    required String textMessageContent,
    required List<Map<String, dynamic>> suggestions,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final body = {
        "name": name,
        "templateDetails": {"category": "text", "payload": payload ?? {}},
        "textMessageContent": textMessageContent,
        "suggestions": suggestions,
      };

      final response = await dio.post(
        APIsEndPoints.createTextRcsTemplate,
        body,
        requiresAuth: true,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
