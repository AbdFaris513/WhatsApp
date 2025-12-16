import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/screen/sing_up/otp_verification_screen.dart';
import 'package:whatsapp/utils/my_colors.dart';

class PhoneNumberInputScreen extends StatefulWidget with MyColors {
  const PhoneNumberInputScreen({super.key});

  @override
  State<PhoneNumberInputScreen> createState() => _PhoneNumberInputScreenState();
}

class _PhoneNumberInputScreenState extends State<PhoneNumberInputScreen> {
  void _onPrivacyPolicyTap() {
    debugPrint('Privacy Policy tapped');
    // Navigate or handle logic here
  }

  String selectedValue = 'India';
  final List<String> items = ['India', 'USA', 'Finland'];

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController(text: '+91');

  String showTopSnackBarWithOTP(BuildContext context) {
    final overlay = Overlay.of(context);
    final random = Random();
    final otp = (100000 + random.nextInt(999999)).toString(); // 4-digit number

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewPadding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Your OTP is: $otp', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: 3)).then((_) => overlayEntry.remove());
    return otp;
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
                  Text(
                    'Enter your phone number',
                    style: GoogleFonts.roboto(
                      color: MyColors.greenGroundColor,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(color: MyColors.foregroundColor, fontSize: 14),
                        children: [
                          const TextSpan(text: 'WhatsApp will need to verify your phone number.'),
                          TextSpan(
                            text: " What’s my number?",
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()..onTap = _onPrivacyPolicyTap,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 13),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: MyColors
                                  .backgroundColorShade, // Background color of dropdown items
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedValue,
                              icon: Icon(Icons.arrow_drop_down),
                              style: TextStyle(color: MyColors.foregroundColor, fontSize: 16),

                              underline: Container(height: 1, color: MyColors.greenGroundColor),
                              alignment: Alignment.center,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedValue = newValue!;
                                });
                              },
                              items: items.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  alignment: Alignment.center,
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: _countryCodeController,
                                  cursorColor: Colors.white,
                                  style: GoogleFonts.roboto(
                                    color: MyColors.foregroundColor,
                                    fontSize: 18,
                                  ),

                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(bottom: 0),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: MyColors.greenGroundColor),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: MyColors.greenGroundColor,
                                        width: 2,
                                      ),
                                    ),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(color: MyColors.greenGroundColor),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16), // spacing between the fields
                            Expanded(
                              flex: 4,
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: _phoneNumberController,
                                  cursorColor: Colors.white,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                      10,
                                    ), // Optional: limit to 10 digits
                                  ],
                                  style: GoogleFonts.roboto(
                                    color: MyColors.foregroundColor,
                                    fontSize: 18,
                                  ),
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: MyColors.greenGroundColor),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: MyColors.greenGroundColor,
                                        width: 2,
                                      ),
                                    ),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(color: MyColors.greenGroundColor),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),

                  Text(
                    ' Carrier charges may apply',
                    style: GoogleFonts.roboto(color: MyColors.foregroundColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.greenGroundColor,
                  foregroundColor: MyColors.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50),
                ),
                onPressed: () async {
                  String otp = showTopSnackBarWithOTP(context);
                  String countryCode = _countryCodeController.text.trim();
                  String phoneNumber = _phoneNumberController.text.trim();
                  String fullPhoneNumber = '$countryCode$phoneNumber';

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OtpVerificationScreen(verificationId: otp, phoneNumber: fullPhoneNumber),
                    ),
                  );
                },
                child: Text('NEXT', style: GoogleFonts.roboto(fontWeight: FontWeight.w400)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
