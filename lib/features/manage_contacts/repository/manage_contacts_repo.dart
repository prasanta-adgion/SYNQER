import 'package:synqer_io/app_export.dart';
import 'package:synqer_io/core/model/paginated_response.dart';
import 'package:synqer_io/features/manage_contacts/model/contacts_model.dart';

class ManageContactsRepo {
  final DioMethodsService dio;
  const ManageContactsRepo({required this.dio});

  Future<PaginatedResponse<ContactsDataModel>> fetchContacts({
    required int page,
    required int limit,
    String? search,
  }) async {
    final response = await dio.get(
      APIsEndPoints.getContacts,
      requiresAuth: true,
      queryParameters: {"page": page, "limit": limit, "search": search},
    );

    bool hasMore =
        ((response['page'] ?? 1) * (response['limit'] ?? 0)) <
        (response['total'] ?? 0);

    final data = _parseAllContacts(response['contacts']);

    return PaginatedResponse<ContactsDataModel>(
      data: data,
      success: response['success'],
      hasMore: hasMore,
      page: response['page'],
      limit: response['limit'],
      message: response['success'].toString() == 'true'
          ? 'Contacts fetched successfully.'
          : 'Failed to fetch contacts.',
      totalItems: response['total'],
      totalPages: response['pages'],
    );
  }
}

List<ContactsDataModel> _parseAllContacts(dynamic json) {
  return (json as List).map((e) => ContactsDataModel.fromJson(e)).toList();
}
