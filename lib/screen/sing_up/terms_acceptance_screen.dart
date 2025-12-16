import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/screen/sing_up/phone_number_input_screen.dart';
import 'package:whatsapp/utils/my_colors.dart';
import 'package:whatsapp/widgets/from_facebook.dart';

class TermsAcceptanceScreen extends StatelessWidget with MyColors {
  const TermsAcceptanceScreen({super.key});

  void _onPrivacyPolicyTap() {
    debugPrint('Privacy Policy tapped');
    // Navigate or handle logic here
  }

  void _onTermsOfServiceTap() {
    debugPrint('Terms of Service tapped');
    // Navigate or handle logic here
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: Padding(
        padding: EdgeInsets.only(top: mediaQuery.width / 2.8),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Image.asset("assets/first_page_img_b.png", width: 250, height: 250),
                  SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(color: MyColors.foregroundColor, fontSize: 14),
                        children: [
                          const TextSpan(text: 'Read our '),
                          TextSpan(
                            text: "Privacy Policy. ",
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()..onTap = _onPrivacyPolicyTap,
                          ),
                          const TextSpan(text: "Tap “Agree and continue” to accept the "),
                          TextSpan(
                            text: 'Terms of Service.',
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()..onTap = _onTermsOfServiceTap,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 13),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.greenGroundColor,
                      foregroundColor: MyColors.backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2), // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 50),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PhoneNumberInputScreen()),
                      );
                    },
                    child: Text(
                      'AGREE AND CONTINUE',
                      style: GoogleFonts.roboto(fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),

            FromFacebook(),
          ],
        ),
      ),
    );
  }
}
