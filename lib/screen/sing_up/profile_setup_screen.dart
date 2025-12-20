import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/utils/my_colors.dart';

// ignore: must_be_immutable
class ProfileSetupScreen extends StatefulWidget {
  String phoneNumber;
  ProfileSetupScreen({super.key, required this.phoneNumber});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> with MyColors {
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Function to show image source selection dialog
  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MyColors.backgroundColor,
          title: Text(
            'Select Image Source',
            style: GoogleFonts.roboto(color: MyColors.foregroundColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: MyColors.greenGroundColor),
                title: Text('Gallery', style: GoogleFonts.roboto(color: MyColors.foregroundColor)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: MyColors.greenGroundColor),
                title: Text('Camera', style: GoogleFonts.roboto(color: MyColors.foregroundColor)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
                    onTap: _showImageSourceDialog,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
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
                              Icons.add_circle_rounded,
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
                                  controller: _nameController,
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
                onPressed: () {
                  // Validate name is not empty
                  if (_nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter your name'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // TODO: Save profile data and navigate to next screen
                  // You can access:
                  // - _nameController.text for the name
                  // - _selectedImage for the profile image (can be null)
                  // - widget.phoneNumber for the phone number

                  print('Name: ${_nameController.text}');
                  print('Phone: ${widget.phoneNumber}');
                  print('Image path: ${_selectedImage?.path ?? "No image selected"}');
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
