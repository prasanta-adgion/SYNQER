import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  //All Service Model Icons and Color

  static Color serviceColor(String service) {
    switch (service) {
      case 'sms':
        return const Color(0xFF4F46E5);
      case 'whatsapp':
        return const Color(0xFF10B981);
      case 'rcs':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF64748B);
    }
  }

  static Widget serviceIcon(String service, {double size = 20, Color? color}) {
    switch (service) {
      case 'sms' || 'bulk sms':
        return Icon(Icons.sms_rounded, size: size, color: color);

      case 'whatsapp':
        return FaIcon(FontAwesomeIcons.whatsapp, size: size, color: color);

      case 'rcs':
        return Icon(CupertinoIcons.text_bubble, size: size, color: color);

      default:
        return Icon(Icons.receipt_long_rounded, size: size, color: color);
    }
  }
}
