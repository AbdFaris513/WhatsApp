import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/screen/chats/home_screen.dart';
import 'package:whatsapp/service/cloudinary_service.dart';
import 'package:whatsapp/service/firestore_service.dart';
import 'package:whatsapp/widgets/image_crop_screen.dart';

class ProfileSetupController extends GetxController {
  final nameController = TextEditingController();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();
  final RxBool isUploading = false.obs;

  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> showImageSourceDialog() async {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        title: Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Get.theme.primaryColor),
              title: Text('Gallery'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Get.theme.primaryColor),
              title: Text('Camera'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final croppedImage = await Get.to(() => ImageCropScreen(imagePath: pickedFile.path));

        if (croppedImage != null) {
          selectedImage.value = croppedImage;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error picking image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> showImageOptionsDialog() async {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        title: Text('Profile Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Get.theme.primaryColor),
              title: Text('Change Photo'),
              onTap: () {
                Get.back();
                showImageSourceDialog();
              },
            ),
            if (selectedImage.value != null)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remove Photo'),
                onTap: () {
                  selectedImage.value = null;
                  Get.back();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> handleProfileSetup(String phoneNumber) async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isUploading.value = true;

    try {
      String profilePictureUrl = '';

      if (selectedImage.value != null) {
        Get.snackbar(
          'Uploading',
          'Uploading to Cloudinary...',
          backgroundColor: Get.theme.primaryColor,
          colorText: Colors.white,
          showProgressIndicator: true,
          duration: Duration(seconds: 1),
        );

        profilePictureUrl = await _cloudinaryService.uploadImage(selectedImage.value!);
      }

      await FirebaseHelper.createUser(
        name: nameController.text.trim(),
        phone: phoneNumber,
        profilePictureUrl: profilePictureUrl,
      );

      isUploading.value = false;

      Get.snackbar(
        'Success',
        'Profile created successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAll(() => HomeScreen());

      print('Profile setup completed successfully!');
      print('Name: ${nameController.text}');
      print('Phone: $phoneNumber');
      print('Profile Picture URL: $profilePictureUrl');
    } catch (e) {
      isUploading.value = false;

      Get.snackbar(
        'Error',
        'Error: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }
}
