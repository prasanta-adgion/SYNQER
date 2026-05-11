import 'package:synqer_io/app_export.dart';
import 'package:synqer_io/core/model/paginated_response.dart';
import 'package:synqer_io/core/utils/pagination_utils.dart';
import 'package:synqer_io/features/all_leads/channel_leads/rcs_lead/model/rcsleads_data_model.dart';

class RcsLeadsRepo {
  final DioMethodsService dio;

  const RcsLeadsRepo({required this.dio});

  Future<PaginatedResponse<RcsLeadsDataModel>> fetchRcsLeads({
    required int page,
    required int limit,
    String? search,
    String? eventType,
    String? fromDate,
    String? toDate,
  }) async {
    final response = await dio.get(
      APIsEndPoints.getRcsLeads,

      requiresAuth: true,

      queryParameters: {
        "page": page,
        "limit": limit,

        if (search != null && search.isNotEmpty) "search": search,

        if (eventType != null && eventType.isNotEmpty) "eventType": eventType,

        if (fromDate != null && fromDate.isNotEmpty) "from": fromDate,

        if (toDate != null && toDate.isNotEmpty) "to": toDate,
      },
    );

    final bool success = response['success'] == true;

    final String message = response['success'].toString() == 'true'
        ? 'Rcs Leads fetch successfull.'
        : 'Failed to fetch rcs leads';

    final int currentPage = (response['pagination']['page'] ?? 1) as int;

    final int currentLimit = (response['pagination']['limit'] ?? limit) as int;

    final int totalItems = (response['pagination']['total'] ?? 0) as int;

    final int totalPages = (response['pagination']['totalPages'] ?? 1) as int;

    final bool hasMore = PaginationUtils.hasMore(
      currentPage: currentPage,
      currentLimit: currentLimit,
      totalItems: totalItems,
      totalPages: totalPages,
    );

    final List<RcsLeadsDataModel> data = parseRcsLeads(response['data']);

    return PaginatedResponse<RcsLeadsDataModel>(
      success: success,

      message: message,

      page: currentPage,

      limit: currentLimit,

      totalItems: totalItems,

      totalPages: totalPages,

      hasMore: hasMore,

      data: data,
    );
  }
}

List<RcsLeadsDataModel> parseRcsLeads(dynamic data) {
  if (data == null) return [];

  if (data is! List) return [];

  return data
      .map<RcsLeadsDataModel>(
        (e) => RcsLeadsDataModel.fromJson(e as Map<String, dynamic>),
      )
      .toList();
}
