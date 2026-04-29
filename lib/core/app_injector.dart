import 'package:synqer_io/core/network/dio_methods_service.dart';
import 'package:synqer_io/features/live_conversions/repository/conversions_repo.dart';
import 'package:synqer_io/features/user_login/repo/login_repo.dart';

class AppInjector {
  static final DioMethodsService dio = DioMethodsService();

  static final LoginRepo loginRepo = LoginRepo(dio: dio);
  static final ConversionsRepo conversionsRepo = ConversionsRepo(dio: dio);
}
