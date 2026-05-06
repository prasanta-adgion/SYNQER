import 'package:flutter/foundation.dart';
import 'package:synqer_io/app_export.dart';
import 'package:synqer_io/features/profile/model/user_profile_model.dart';

class ProfileRepo {
  final DioMethodsService dio;

  ProfileRepo({required this.dio});

  Future<UserProfile> fetchUserProfile() async {
    final response = await dio.get(APIsEndPoints.getProfile);
    return await compute(_parseUserProfile, response);
  }
}

UserProfile _parseUserProfile(dynamic json) => UserProfile.fromJson(json);
