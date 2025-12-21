import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/my_colors.dart';

class ImageCropScreen extends StatefulWidget {
  final String imagePath;

  const ImageCropScreen({super.key, required this.imagePath});

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> with MyColors {
  final _cropController = CropController();
  late Uint8List _imageData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final file = File(widget.imagePath);
    final bytes = await file.readAsBytes();
    setState(() {
      _imageData = bytes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: MyColors.backgroundColor,
        title: Text(
          'Crop Profile Photo',
          style: GoogleFonts.roboto(color: MyColors.foregroundColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: MyColors.foregroundColor),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: MyColors.greenGroundColor),
            onPressed: () {
              _cropController.crop();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: MyColors.greenGroundColor))
          : Crop(
              image: _imageData,
              controller: _cropController,
              onCropped: (cropResult) async {
                try {
                  if (cropResult is CropSuccess) {
                    final tempDir = Directory.systemTemp;
                    final tempFile = File(
                      '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
                    );

                    await tempFile.writeAsBytes(cropResult.croppedImage);

                    if (context.mounted) {
                      Get.back(result: tempFile);
                    }
                  } else if (cropResult is CropFailure) {
                    print('Crop failed: ${cropResult.cause}');
                    if (context.mounted) {
                      Get.back();
                      Get.snackbar(
                        'Error',
                        'Failed to crop image',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  }
                } catch (e) {
                  print('Error saving cropped image: $e');
                  if (context.mounted) {
                    Get.back();
                    Get.snackbar(
                      'Error',
                      'Error saving cropped image',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                }
              },
              aspectRatio: 1.0,
              withCircleUi: true,
              baseColor: Colors.black,
              maskColor: Colors.black.withOpacity(0.5),
              radius: 20,
              cornerDotBuilder: (size, edgeAlignment) => const DotControl(color: Colors.white),
            ),
    );
  }
}
