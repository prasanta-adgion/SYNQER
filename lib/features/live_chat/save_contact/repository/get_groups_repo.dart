import 'package:synqer_io/core/constants/apis_end_points.dart';
import 'package:synqer_io/core/model/paginated_response.dart';
import 'package:synqer_io/core/network/dio_methods_service.dart';
import 'package:synqer_io/features/live_chat/save_contact/model/groups_model.dart';

class GetGroupsRepo {
  final DioMethodsService dio;
  const GetGroupsRepo({required this.dio});

  Future<PaginatedResponse<GroupsDataModel>> fetchGroups({
    int page = 1,
    int limit = 20,
    String? searchValue,
  }) async {
    final res = await dio.get(
      APIsEndPoints.getGroups,
      requiresAuth: true,
      queryParameters: {"page": page, "limit": limit, 'search': searchValue},
    );

    final List<GroupsDataModel> groups = (res['data'] as List)
        .map((e) => GroupsDataModel.fromJson(e))
        .toList();

    bool hasMore =
        ((res['page'] ?? 1) * (res['limit'] ?? 0)) < (res['totalGroups'] ?? 0);

    return PaginatedResponse(
      data: groups,
      success: res['success'] ?? false,
      message: res['message'] ?? '',
      page: res['page'],
      limit: res['limit'],
      totalItems: res['totalGroups'],
      totalPages: res['totalPages'],
      hasMore: hasMore,
    );
  }

  Future<dynamic> addContact({
    required String fullName,
    required String groupName,
    required String phone,
  }) async {
    final responseData = await dio.post(APIsEndPoints.addContacts, {
      "fullName": fullName.toString().trim(),
      "groupName": groupName.toString().trim(),
      "mobileNumber": phone,
    });

    return responseData;
  }
}
