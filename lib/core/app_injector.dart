import 'package:synqer_io/core/network/dio_methods_service.dart';
import 'package:synqer_io/features/live_chat/live_conversions/repository/conversions_repo.dart';
import 'package:synqer_io/features/live_chat/single_conversion/repository/single_conversion_repo.dart';
import 'package:synqer_io/features/live_chat/save_contact/repository/get_groups_repo.dart';
import 'package:synqer_io/features/profile/repository/profile_repo.dart';
import 'package:synqer_io/features/user_login/repo/login_repo.dart';

class AppInjector {
  static final DioMethodsService dio = DioMethodsService();
  //Login
  static final LoginRepo loginRepo = LoginRepo(dio: dio);

  //Live Chat
  static final ConversionsRepo conversionsRepo = ConversionsRepo(dio: dio);

  //single chats history
  static final SingleConversionRepo singleConversionHistoryRepo =
      SingleConversionRepo(dio: dio);

  //get groups
  static final GetGroupsRepo getGroupsRepo = GetGroupsRepo(dio: dio);

  //profile
  static final ProfileRepo profileRepo = ProfileRepo(dio: dio);
}
