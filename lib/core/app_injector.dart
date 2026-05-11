import 'package:synqer_io/core/network/dio_methods_service.dart';
import 'package:synqer_io/features/all_leads/channel_leads/rcs_lead/repository/rcs_leads_repo.dart';
import 'package:synqer_io/features/all_leads/channel_leads/whatsapp_lead/repository/whatsapp_leads_repo.dart';
import 'package:synqer_io/features/live_chat/live_conversions/repository/conversions_repo.dart';
import 'package:synqer_io/features/live_chat/single_conversion/repository/single_conversion_repo.dart';
import 'package:synqer_io/features/live_chat/save_contact/repository/get_groups_repo.dart';
import 'package:synqer_io/features/manage_contacts/repository/manage_contacts_repo.dart';
import 'package:synqer_io/features/profile/repository/profile_repo.dart';
import 'package:synqer_io/features/transaction_screen/repository/transaction_get_repo.dart';
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

  //get transactions
  static final TransactionGetRepo transactionsRepo = TransactionGetRepo(
    dio: dio,
  );

  //get contacts
  static final ManageContactsRepo manageContactsRepo = ManageContactsRepo(
    dio: dio,
  );

  //get rcs leads
  static final RcsLeadsRepo rcsLeadsRepo = RcsLeadsRepo(dio: dio);

  //get whatsapp leads
  static final WhatsappLeadsRepo whatsappLeadsRepo = WhatsappLeadsRepo(
    dio: dio,
  );
}
