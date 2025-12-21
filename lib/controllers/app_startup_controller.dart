import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/screen/chats/home_screen.dart';
import 'package:whatsapp/screen/sing_up/terms_acceptance_screen.dart';

class AppStartupController extends GetxController {
  void checkLoginStatus(final bool mounted, final BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    bool userExists = prefs.containsKey('loggedInPhone');

    if (userExists) {
      // contactController.getMessagedContactsStream();
    }

    if (mounted) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          // builder: (context) =>
          // userExists ? TermsAcceptanceScreen() : const TermsAcceptanceScreen(),
          builder: (context) => userExists ? HomeScreen() : const TermsAcceptanceScreen(),
        ),
      );
    }
  }
}
