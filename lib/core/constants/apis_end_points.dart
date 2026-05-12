class APIsEndPoints {
  static const String baseUrl = 'https://backend-v2.synqer.io/';

  static const String login = 'user/api/v1/login';
  static const String liveConvertions =
      "user/api/v1/whatsapp/conversation/users";

  static const String singleConvertion =
      "user/api/v1/whatsapp/conversation/messages";

  static const String sendMessage = "user/api/v1/whatsapp/conversation/send";

  static const String getGroups = "user/api/v1/contacts/groups";

  static const String addContacts = "user/api/v1/add-contacts";

  static String updateContact(String id) => "user/api/v1/contacts/$id";

  static String deleteContact(String id) => "user/api/v1/delete-contacts/$id";

  static const String getProfile = "user/api/v1/profile";

  static const String getTransactions = "user/api/v1/transactions";

  static const String getContacts = "user/api/v1/contacts";

  static const String getRcsLeads = "user/api/v1/rcs/interactions";

  static const String getWhatsappconversationLeads =
      "user/api/v1/whatsapp/conversation/leads";

  static String updateWhatsappLead(String id) =>
      "user/api/v1/whatsapp/conversation/leads/$id";

  static String deleteWhatsappLead(String id) =>
      "user/api/v1/whatsapp/conversation/leads/$id";

  static const getAiWebLeads = "api/v1/my/widget/leads";

  static String updateAiWebLead(String id) => "api/v1/my/widget/leads/$id";

  static String deleteAiWebLead(String id) => "api/v1/my/widget/leads/$id";
}
