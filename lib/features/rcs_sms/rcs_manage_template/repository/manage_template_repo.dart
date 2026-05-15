import 'package:synqer_io/app_export.dart';
import 'package:synqer_io/core/model/paginated_response.dart';
import 'package:synqer_io/core/utils/pagination_utils.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/model/manage_template_model.dart';

class ManageTemplateRepo {
  final DioMethodsService dio;
  const ManageTemplateRepo({required this.dio});

  Future<PaginatedResponse<RcsTemplateData>> fetchRcsTemplate({
    required int page,
    required int limit,
    final String? templateType,
    final String? search,
  }) async {
    final response = await dio.get(
      APIsEndPoints.getRcsTemplates,
      requiresAuth: true,
      queryParameters: {
        "page": page,
        "limit": limit,
        "type": templateType,
        "name": search,
      },
    );

    final bool success = response['success'] == true;

    final String message = response['success'].toString() == 'true'
        ? 'Template data fetch successfull'
        : 'Failed to fetch Template data';

    final int currentPage = (response['page'] ?? 1) as int;

    final int currentLimit = (response['limit'] ?? limit) as int;

    final int totalItems = (response['total'] ?? 0) as int;

    final int totalPages = (response['totalPages'] ?? 1) as int;
    final data = parseRcsTemplateResponse(response);

    final bool hasMore = PaginationUtils.hasMore(
      currentPage: currentPage,
      currentLimit: currentLimit,
      totalItems: totalItems,
      totalPages: totalPages,
    );

    return PaginatedResponse(
      success: success,
      message: message,
      page: page,
      limit: limit,
      totalItems: totalItems,
      totalPages: totalPages,
      hasMore: hasMore,
      data: data,
    );
  }
}

List<RcsTemplateData> parseRcsTemplateResponse(dynamic json) {
  return (json['data'] as List)
      .map((e) => RcsTemplateData.fromJson(e))
      .toList();
}
