import 'package:flutter/material.dart';
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

  //edit contact
  Future<dynamic> updateContact({
    required String contactId,
    required String fullName,
    required String groupName,
    required String phone,
  }) async {
    final responseData = await dio.put(APIsEndPoints.updateContact(contactId), {
      "fullName": fullName.toString().trim(),
      "groupName": groupName.toString().trim(),
      "mobileNumber": phone,
    });

    return responseData;
  }

  //delete contact
  Future<dynamic> deleteContact({required String contactId}) async {
    final responseData = await dio.delete(
      APIsEndPoints.deleteContact(contactId),
    );
    debugPrint(responseData.toString());
    return responseData;
  }
}

List<ContactsDataModel> _parseAllContacts(dynamic json) {
  return (json as List).map((e) => ContactsDataModel.fromJson(e)).toList();
}
