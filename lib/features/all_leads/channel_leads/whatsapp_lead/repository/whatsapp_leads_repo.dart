import 'package:flutter/cupertino.dart';
import 'package:synqer_io/app_export.dart';
import 'package:synqer_io/core/model/paginated_response.dart';
import 'package:synqer_io/core/utils/pagination_utils.dart';
import 'package:synqer_io/features/all_leads/channel_leads/whatsapp_lead/model/whatsappleads_data_model.dart';

class WhatsappLeadsRepo {
  final DioMethodsService dio;
  const WhatsappLeadsRepo({required this.dio});

  Future<PaginatedResponse<WhatsappLeadsDataModel>> fetchWhatsappLeads({
    required int page,
    required int limit,
    String? search,
    String? status,
    String? leadType,
  }) async {
    final response = await dio.get(
      APIsEndPoints.getWhatsappconversationLeads,
      requiresAuth: true,
      queryParameters: {
        "page": page,
        "limit": limit,
        if (search != null && search.isNotEmpty) "search": search,
        if (status != null && status.isNotEmpty) "status": status,
        if (leadType != null && leadType.isNotEmpty) "leadType": leadType,
      },
    );

    final bool success = response['success'] == true;

    final String message = response['success'].toString() == 'true'
        ? 'Whatsapp Leads fetch successfull.'
        : 'Failed to fetch Whatsapp leads';

    final int currentPage = (response['page'] ?? 1) as int;

    final int currentLimit = (response['limit'] ?? limit) as int;

    final int totalItems = (response['total'] ?? 0) as int;

    final int totalPages = (response['totalPages'] ?? 1) as int;

    final bool hasMore = PaginationUtils.hasMore(
      currentPage: currentPage,
      currentLimit: currentLimit,
      totalItems: totalItems,
      totalPages: totalPages,
    );

    final List<WhatsappLeadsDataModel> data = parseRcsLeads(response['data']);

    return PaginatedResponse<WhatsappLeadsDataModel>(
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

  Future<dynamic> updateLeadStatus({
    required String leadId,
    String? status,
    String? remark,
    String? leadType,
    String? name,
  }) async {
    final response = await dio
        .patch(APIsEndPoints.updateWhatsappLead(leadId), requiresAuth: true, {
          "status": status,
          if (name != null && name.isNotEmpty) 'name': name,
          if (remark != null && remark.isNotEmpty) "remarks": remark,
          if (leadType != null && leadType.isNotEmpty) 'leadType': leadType,
        });
    debugPrint(response.toString());

    return response;
  }

  Future<dynamic> deleteLead({required String leadId}) async {
    final response = await dio.delete(
      APIsEndPoints.deleteWhatsappLead(leadId),
      requiresAuth: true,
    );
    return response;
  }
}

List<WhatsappLeadsDataModel> parseRcsLeads(dynamic data) {
  if (data == null) return [];

  if (data is! List) return [];

  return data
      .map<WhatsappLeadsDataModel>(
        (e) => WhatsappLeadsDataModel.fromJson(e as Map<String, dynamic>),
      )
      .toList();
}
