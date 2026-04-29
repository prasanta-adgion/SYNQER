import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:synqer_io/core/constants/apis_end_points.dart';

class DioMethodsService {
  late final Dio _dio;

  String? _authToken;

  DioMethodsService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: APIsEndPoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          Headers.acceptHeader: Headers.jsonContentType,
          Headers.contentTypeHeader: Headers.jsonContentType,
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _setupInterceptors();
  }

  // ───────────────── TOKEN ─────────────────

  void updateToken(String? token) {
    debugPrint("Updating auth token in DIO: $token");
    _authToken = token;
  }

  // ───────────────── INTERCEPTORS ─────────────────

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final requiresAuth = options.extra['requiresAuth'] ?? true;

          if (requiresAuth && _authToken != null) {
            options.headers['userToken'] = _authToken;
          }

          if (kDebugMode) {
            debugPrint("${options.method} ${options.uri}");
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint("✅ ${response.statusCode}");
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint("❌ ${error.message}");
          }
          handler.next(error);
        },
      ),
    );
  }

  // ───────────────── REQUEST METHODS ─────────────────

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );

      // return _handleResponse(response);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );

      // return _handleResponse(response);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: body,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );

      // return _handleResponse(response);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ───────────────── RESPONSE HANDLING ─────────────────

  // Map<String, dynamic> _handleResponse(Response response) {
  //   final success =
  //       response.statusCode != null &&
  //       response.statusCode! >= 200 &&
  //       response.statusCode! < 300;

  //   return {
  //     "success": success,
  //     "data": response.data,
  //     "message":
  //         response.data?["message"] ?? (success ? "Success" : "Request failed"),
  //     "statusCode": response.statusCode,
  //   };
  // }

  Map<String, dynamic> _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return _error("Connection timeout");

      case DioExceptionType.connectionError:
        return _error("No internet connection");

      case DioExceptionType.badResponse:
        return {
          "success": false,
          "message":
              error.response?.data?["message"] ??
              "Server error (${error.response?.statusCode})",
          "statusCode": error.response?.statusCode,
        };

      case DioExceptionType.cancel:
        return _error("Request cancelled");

      case DioExceptionType.badCertificate:
        return _error("SSL certificate error");

      case DioExceptionType.unknown:
        return _error(error.message ?? "Unexpected error");
    }
  }

  Map<String, dynamic> _error(String message) {
    return {"success": false, "message": message};
  }

  // ───────────────── FILE UPLOAD ─────────────────

  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required String fileField,
    required List<File> files,
    Map<String, String>? fields,
    bool requiresAuth = true,
  }) async {
    try {
      final formData = FormData();

      if (fields != null) {
        formData.fields.addAll(
          fields.entries.map((e) => MapEntry(e.key, e.value)),
        );
      }

      for (final file in files) {
        formData.files.add(
          MapEntry(
            fileField,
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );

      // return _handleResponse(response);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }
}
