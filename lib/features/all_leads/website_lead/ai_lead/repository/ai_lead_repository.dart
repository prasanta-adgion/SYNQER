import 'package:flutter/rendering.dart';
import 'package:synqer_io/app_export.dart';
import 'package:synqer_io/core/model/paginated_response.dart';
import 'package:synqer_io/core/utils/pagination_utils.dart';
import 'package:synqer_io/features/all_leads/website_lead/ai_lead/model/ai_leads_model.dart';

class AiLeadRepository {
  final DioMethodsService dio;
  const AiLeadRepository({required this.dio});

  Future<PaginatedResponse<AiLeadsDataModel>> fetchAiLeads({
    required int page,
    required int limit,
    String? isContacted,
  }) async {
    final response = await dio.get(
      APIsEndPoints.getAiWebLeads,
      requiresAuth: true,
      queryParameters: {
        if (isContacted != null && isContacted.isNotEmpty)
          "isContacted": isContacted,
        "page": page,
        "limit": limit,
      },
    );
    debugPrint(isContacted.toString());
    final bool success = response['success'] == true;

    final String message = response['success'].toString() == 'true'
        ? 'Ai Web Leads fetch successfull'
        : 'Failed to fetch Ai Web leads';

    final int currentPage = (response['meta']['page'] ?? 1) as int;

    final int currentLimit = (response['meta']['limit'] ?? limit) as int;

    final int totalItems = (response['meta']['total'] ?? 0) as int;

    final int totalPages = (response['meta']['pages'] ?? 1) as int;

    final bool hasMore = PaginationUtils.hasMore(
      currentPage: currentPage,
      currentLimit: currentLimit,
      totalItems: totalItems,
      totalPages: totalPages,
    );

    final List<AiLeadsDataModel> data = parseAiWebLeads(response['data']);

    return PaginatedResponse<AiLeadsDataModel>(
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

  Future<dynamic> updateAiWebLead({
    required String id,
    String? isContacted,
    String? notes,
  }) async {
    final response = await dio.patch(APIsEndPoints.updateAiWebLead(id), {
      if (notes != null && notes.isNotEmpty) "notes": notes,
      if (isContacted != null && isContacted.isNotEmpty)
        "isContacted": isContacted,
    });

    return response;
  }

  Future<dynamic> deleteAiWebLead({required String id}) async {
    final response = await dio.delete(APIsEndPoints.updateAiWebLead(id));

    return response;
  }
}

List<AiLeadsDataModel> parseAiWebLeads(List<dynamic> data) {
  return data.map((e) => AiLeadsDataModel.fromJson(e)).toList();
}
