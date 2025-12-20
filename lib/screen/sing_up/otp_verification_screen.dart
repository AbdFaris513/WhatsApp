import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/screen/sing_up/profile_setup_screen.dart';
import 'package:whatsapp/utils/my_colors.dart';

class OtpVerificationScreen extends StatelessWidget with MyColors {
  final String verificationId;
  final String phoneNumber;

  OtpVerificationScreen({super.key, required this.verificationId, required this.phoneNumber});

  // final ContactController contactController = Get.put(ContactController());

  final TextEditingController _controller = TextEditingController(text: "- - - - - -");

  void showTopSnackBarWithOTP(BuildContext context) {
    final overlay = Overlay.of(context);
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
            child: Text(
              'Your OTP is: $verificationId',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: 3)).then((_) => overlayEntry.remove());
  }

  void _verifyOtp(BuildContext context) async {
    String rawInput = _controller.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (rawInput.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a 6-digit OTP")));
      return;
    }

    if (rawInput == verificationId) {
      // final CollectionReference users = FirebaseFirestore.instance.collection('users');

      // final doc = await users.doc(phoneNumber).get();

      // if (!doc.exists) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => ProfileSetupScreen(phoneNumber: phoneNumber)),
      );
      // } else {
      // debugPrint('Phone number already registered');
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('loggedInPhone', phoneNumber);

      // contactController.getMessagedContactsStream();
      // await contactController.getUserContactList(phoneNumber: phoneNumber);

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => HomeScreen()),
      // );
      // }
    }

    // try {
    //   PhoneAuthCredential credential = PhoneAuthProvider.credential(
    //     verificationId: verificationId,
    //     smsCode: rawInput,
    //   );

    //   await FirebaseAuth.instance.signInWithCredential(credential);

    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(const SnackBar(content: Text("Phone number verified!")));
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => ProfileInfoScreen(phoneNumber: phoneNumber),
    //     ),
    //   );
    // } catch (e) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text("OTP verification failed: $e")));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Text(
                "Verify your number",
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  color: MyColors.greenGroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.roboto(fontSize: 14.3, color: MyColors.foregroundColor),
                  children: [
                    const TextSpan(
                      text: "Waiting to automatically detect an SMS sent to your number ",
                    ),
                    TextSpan(
                      text: phoneNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ". "),
                    TextSpan(
                      text: "Wrong number?",
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pop(context);
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                child: TextField(
                  controller: _controller,
                  inputFormatters: [OtpInputFormatter()],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: MyColors.backgroundColorShade),
                    ),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    counterText: "",
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  Text(
                    "Didn't receive the code?",
                    style: GoogleFonts.roboto(fontSize: 14, color: MyColors.foregroundColor),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          showTopSnackBarWithOTP(context);
                        },
                        child: const Text("Resend SMS", style: TextStyle(color: Colors.blue)),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () => debugPrint("Call Me tapped"),
                        child: const Text("Call Me", style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.greenGroundColor,
                  foregroundColor: MyColors.backgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                ),
                onPressed: () => _verifyOtp(context),
                child: Text('Verify', style: GoogleFonts.roboto(fontWeight: FontWeight.w400)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpInputFormatter extends TextInputFormatter {
  final int maxLength = 6;

  String _formatDigits(String digits) {
    String result = '';
    for (int i = 0; i < maxLength; i++) {
      if (i < digits.length) {
        result += digits[i];
      } else {
        result += '-';
      }
      if (i != maxLength - 1) {
        result += ' ';
      }
    }
    return result;
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove all non-digit characters
    final oldDigits = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final newDigitsRaw = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    String newDigits = newDigitsRaw;

    // Detect backspace
    final isDeleting = newValue.selection.baseOffset < oldValue.selection.baseOffset;

    if (isDeleting && oldDigits.isNotEmpty) {
      newDigits = oldDigits.substring(0, oldDigits.length - 1);
    }

    // Limit to maxLength
    if (newDigits.length > maxLength) {
      newDigits = newDigits.substring(0, maxLength);
    }

    final formatted = _formatDigits(newDigits);

    // Place cursor at the end
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
