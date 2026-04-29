// import 'package:synqer_io/core/constants/apis_end_points.dart';
// import 'package:synqer_io/core/network/dio_methods_service.dart';

import 'package:synqer_io/app_export.dart';

class LoginRepo {
  final DioMethodsService dio;

  LoginRepo({required this.dio});

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(APIsEndPoints.login, {
      "username": email,
      "password": password,
    });

    return response;
  }
}
