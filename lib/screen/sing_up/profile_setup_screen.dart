import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/controllers/profile_setup_controller.dart';
import 'package:whatsapp/utils/my_colors.dart';

class ProfileSetupScreen extends StatelessWidget with MyColors {
  final String phoneNumber;

  ProfileSetupScreen({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileSetupController());
    final Size mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: Obx(
        () => Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: mediaQuery.width / 2.8),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Profile Info',
                          style: GoogleFonts.roboto(
                            color: MyColors.greenGroundColor,
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 42.0, vertical: 6),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(color: MyColors.foregroundColor, fontSize: 14),
                              children: [
                                const TextSpan(
                                  text: 'Please Provide Your Name and an optional profile photo',
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 13),
                        GestureDetector(
                          onTap: controller.isUploading.value
                              ? null
                              : (controller.selectedImage.value == null
                                    ? controller.showImageSourceDialog
                                    : controller.showImageOptionsDialog),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: controller.selectedImage.value != null
                                    ? Image.file(
                                        controller.selectedImage.value!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        "assets/no_dp.jpeg",
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Icon(
                                    controller.selectedImage.value != null
                                        ? Icons.edit
                                        : Icons.add_circle_rounded,
                                    color: MyColors.massageNotificationColor,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 13),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 64),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: SizedBox(
                                      height: 40,
                                      child: TextField(
                                        controller: controller.nameController,
                                        enabled: !controller.isUploading.value,
                                        cursorColor: Colors.white,
                                        style: GoogleFonts.roboto(
                                          color: MyColors.foregroundColor,
                                          fontSize: 18,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Type your name here',
                                          hintStyle: GoogleFonts.roboto(
                                            color: MyColors.foregroundColor.withOpacity(0.5),
                                            fontSize: 18,
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: MyColors.greenGroundColor,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: MyColors.greenGroundColor,
                                              width: 2,
                                            ),
                                          ),
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: MyColors.greenGroundColor,
                                            ),
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 90),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.greenGroundColor,
                        foregroundColor: MyColors.backgroundColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                        padding: EdgeInsets.symmetric(horizontal: 50),
                      ),
                      onPressed: () => controller.handleProfileSetup(phoneNumber),
                      child: controller.isUploading.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(MyColors.backgroundColor),
                              ),
                            )
                          : Text('NEXT', style: GoogleFonts.roboto(fontWeight: FontWeight.w400)),
                    ),
                  ),
                ],
              ),
            ),
            // Full screen loading overlay
            if (controller.isUploading.value)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(MyColors.greenGroundColor),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Setting up your profile...',
                        style: GoogleFonts.roboto(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
