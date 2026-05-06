import 'package:synqer_io/app_export.dart';
import 'package:synqer_io/core/model/paginated_response.dart';
import 'package:synqer_io/features/live_chat/live_conversions/model/live_conversions_model.dart';

class ConversionsRepo {
  final DioMethodsService dio;
  ConversionsRepo({required this.dio});

  Future<PaginatedResponse<ConversionsChatData>> getLiveConvertions(
    String limit,
    String page,
    String? searchValue,
    String isUnread,
  ) async {
    final res = await dio.get(
      APIsEndPoints.liveConvertions,
      requiresAuth: true,
      queryParameters: {
        "limit": limit,
        "page": page,
        "search": searchValue ?? "",
        "unread": isUnread,
      },
    );

    // bool hasMore = (res['page'] * res['limit']) < res['totalUsers'];
    bool hasMore =
        ((res['page'] ?? 1) * (res['limit'] ?? 0)) < (res['totalUsers'] ?? 0);

    return PaginatedResponse<ConversionsChatData>(
      success: res['success'] ?? false,
      message: res['message'] ?? '',
      page: res['page'],
      limit: res['limit'],
      totalItems: res['totalUsers'],
      totalPages: res['totalPages'],
      hasMore: hasMore,
      data: parseLiveConversions(res['data']),
    );
  }
}

List<ConversionsChatData> parseLiveConversions(dynamic data) {
  return (data as List).map((e) => ConversionsChatData.fromJson(e)).toList();
}
