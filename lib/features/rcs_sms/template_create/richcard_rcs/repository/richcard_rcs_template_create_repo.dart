import 'package:synqer_io/app_export.dart';

class RichcardRcsTemplateCreateRepo {
  final DioMethodsService dio;
  const RichcardRcsTemplateCreateRepo({required this.dio});

  Future<dynamic> createRichcardRcsTemplate({
    required String name,
    required String cardTitle,
    String? cardDescription,
    required List<Map<String, dynamic>> suggestions,
    required String file,
  }) async {
    final body = {
      "name": name,
      "cardTitle": cardTitle,
      "cardDescription": cardDescription,
      "multimedia_files": cardDescription,
      "suggestions": suggestions,
    };

    final response = await dio.post(
      APIsEndPoints.createRichCardRcsTemplate,
      requiresAuth: true,
      {},
    );
    return response;
  }
}
