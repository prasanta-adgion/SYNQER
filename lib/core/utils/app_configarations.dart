import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class AppConfig {
  // static Future<String?> pickEmail() async {
  //   try {
  //     final EmailResult? result = await AccountPicker.emailHint();
  //     return result?.email;
  //   } catch (e) {
  //     debugPrint("Email pick error: $e");
  //     return null;
  //   }
  // }

  static void showSnackBar(String message, BuildContext context, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  static String removeCountryCode(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\s+'), '');

    if (cleaned.startsWith('+91')) {
      return cleaned.substring(3);
    } else if (cleaned.startsWith('91')) {
      return cleaned.substring(2);
    }

    return cleaned;
  }

  static Future<void> launchCaller(String phoneNumber) async {
    final uri = Uri.parse("tel:$phoneNumber");
    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(uri);
    } else {
      debugPrint("Could not launch phone call");
    }
  }

  static Future<void> openWebsite(String url) async {
    if (url.isEmpty) return;

    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');

    if (!await url_launcher.launchUrl(
      uri,
      mode: url_launcher.LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }
}
