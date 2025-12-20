import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
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
  bool _isUploading = false;

  // Function to generate Cloudinary signature
  String _generateSignature(String paramsToSign, String apiSecret) {
    var bytes = utf8.encode(paramsToSign + apiSecret);
    var digest = sha1.convert(bytes);
    return digest.toString();
  }

  // Function to upload image to Cloudinary with signature
  Future<String> _uploadImageToCloudinary(File imageFile) async {
    try {
      print('Starting Cloudinary upload...');

      // Cloudinary configuration
      const String cloudName = 'djk6rwklf';
      const String apiKey = '289131489398422';
      const String apiSecret = 'C737kVzqnZLQ-YT891J2gx24SNU';

      // Generate timestamp
      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Create params for signature
      String folder = 'whatsapp_profiles';
      String paramsToSign = 'folder=$folder&timestamp=$timestamp';

      // Generate signature
      String signature = _generateSignature(paramsToSign, apiSecret);

      print('Signature generated');

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
      );

      // Add required fields
      request.fields['api_key'] = apiKey;
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;
      request.fields['folder'] = folder;

      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      print('Uploading to Cloudinary...');

      // Send request
      var response = await request.send();

      // Get response
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseString);
        String imageUrl = jsonResponse['secure_url'];

        print('Upload successful! URL: $imageUrl');
        return imageUrl;
      } else {
        print('Upload failed: $responseString');
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      rethrow;
    }
  }

  // Function to create user in Firestore
  Future<void> _createUserInFirestore({
    required String name,
    required String phone,
    required String profilePictureUrl,
  }) async {
    try {
      print('Creating user in Firestore...');
      print('Phone: $phone');
      print('Name: $name');

      // Get Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create user document
      await firestore.collection('users').doc(phone).set({
        'name': name,
        'phone': phone,
        'profilePicture': profilePictureUrl,
        'about': '',
        'createdAt': FieldValue.serverTimestamp(),
        'isOnline': true,
        'lastSeen': '',
        'contactList': [], // Empty array initially
      });

      print('User created successfully in Firestore');
    } catch (e) {
      print('Error creating user in Firestore: $e');
      print('Error details: ${e.toString()}');
      rethrow;
    }
  }

  // Function to handle profile setup completion
  Future<void> _handleProfileSetup() async {
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your name'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String profilePictureUrl = '';

      // Upload image if selected
      if (_selectedImage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Uploading to Cloudinary...'),
              ],
            ),
            duration: Duration(seconds: 30),
            backgroundColor: MyColors.greenGroundColor,
          ),
        );

        profilePictureUrl = await _uploadImageToCloudinary(_selectedImage!);
      }

      // Create user in Firestore
      await _createUserInFirestore(
        name: _nameController.text.trim(),
        phone: widget.phoneNumber,
        profilePictureUrl: profilePictureUrl,
      );

      setState(() {
        _isUploading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile created successfully!'), backgroundColor: Colors.green),
      );

      // TODO: Navigate to home screen or next screen
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => HomeScreen()),
      // );

      print('Profile setup completed successfully!');
      print('Name: ${_nameController.text}');
      print('Phone: ${widget.phoneNumber}');
      print('Profile Picture URL: $profilePictureUrl');
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

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
        // Navigate to crop screen
        final croppedImage = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ImageCropScreen(imagePath: pickedFile.path)),
        );

        if (croppedImage != null) {
          setState(() {
            _selectedImage = croppedImage;
          });
        }
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Function to show options to change or remove image
  Future<void> _showImageOptionsDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MyColors.backgroundColor,
          title: Text('Profile Photo', style: GoogleFonts.roboto(color: MyColors.foregroundColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: MyColors.greenGroundColor),
                title: Text(
                  'Change Photo',
                  style: GoogleFonts.roboto(color: MyColors.foregroundColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showImageSourceDialog();
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Remove Photo',
                    style: GoogleFonts.roboto(color: MyColors.foregroundColor),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedImage = null;
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
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
      body: Stack(
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
                        onTap: _isUploading
                            ? null
                            : (_selectedImage == null
                                  ? _showImageSourceDialog
                                  : _showImageOptionsDialog),
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
                                  _selectedImage != null ? Icons.edit : Icons.add_circle_rounded,
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
                                      enabled: !_isUploading,
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
                    onPressed: _isUploading ? null : _handleProfileSetup,
                    child: _isUploading
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
          if (_isUploading)
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
    );
  }
}

// Separate Image Crop Screen
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
          onPressed: () => Navigator.pop(context),
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
                  // CropResult is a sealed class, pattern match it
                  if (cropResult is CropSuccess) {
                    // Save cropped image to temporary file
                    final tempDir = Directory.systemTemp;
                    final tempFile = File(
                      '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
                    );

                    await tempFile.writeAsBytes(cropResult.croppedImage);

                    // Return the cropped file
                    if (context.mounted) {
                      Navigator.pop(context, tempFile);
                    }
                  } else if (cropResult is CropFailure) {
                    print('Crop failed: ${cropResult.cause}');
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to crop image'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  print('Error saving cropped image: $e');
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error saving cropped image'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              aspectRatio: 1.0, // Square aspect ratio
              withCircleUi: true, // Circular crop UI
              baseColor: Colors.black,
              maskColor: Colors.black.withOpacity(0.5),
              radius: 20,
              cornerDotBuilder: (size, edgeAlignment) => const DotControl(color: Colors.white),
            ),
    );
  }
}

//////////////////////////////////////////////////////////////
class FirebaseHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a contact to user's contact list
  static Future<void> addContactToUser({
    required String userPhone,
    required String contactName,
    required String contactPhone,
  }) async {
    try {
      await _firestore.collection('users').doc(userPhone).update({
        'contactList': FieldValue.arrayUnion([
          {'contactName': contactName, 'phoneNumber': contactPhone},
        ]),
      });
      print('Contact added successfully');
    } catch (e) {
      print('Error adding contact: $e');
      rethrow;
    }
  }

  // Update user's about
  static Future<void> updateUserAbout({required String userPhone, required String about}) async {
    try {
      await _firestore.collection('users').doc(userPhone).update({'about': about});
      print('About updated successfully');
    } catch (e) {
      print('Error updating about: $e');
      rethrow;
    }
  }

  // Update user's online status
  static Future<void> updateOnlineStatus({
    required String userPhone,
    required bool isOnline,
  }) async {
    try {
      Map<String, dynamic> updateData = {'isOnline': isOnline};

      // If going offline, update lastSeen
      if (!isOnline) {
        updateData['lastSeen'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('users').doc(userPhone).update(updateData);
      print('Online status updated');
    } catch (e) {
      print('Error updating online status: $e');
      rethrow;
    }
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData(String userPhone) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userPhone).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
  }

  // Update profile picture
  static Future<void> updateProfilePicture({
    required String userPhone,
    required String profilePictureUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(userPhone).update({
        'profilePicture': profilePictureUrl,
      });
      print('Profile picture updated successfully');
    } catch (e) {
      print('Error updating profile picture: $e');
      rethrow;
    }
  }

  // Remove a contact from user's contact list
  static Future<void> removeContactFromUser({
    required String userPhone,
    required String contactPhone,
  }) async {
    try {
      // Get current user data
      DocumentSnapshot doc = await _firestore.collection('users').doc(userPhone).get();
      if (doc.exists) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        List<dynamic> contactList = userData['contactList'] ?? [];

        // Remove the contact with matching phone number
        contactList.removeWhere((contact) => contact['phoneNumber'] == contactPhone);

        // Update the document
        await _firestore.collection('users').doc(userPhone).update({'contactList': contactList});
        print('Contact removed successfully');
      }
    } catch (e) {
      print('Error removing contact: $e');
      rethrow;
    }
  }

  // Get all contacts for a user
  static Future<List<Map<String, dynamic>>> getUserContacts(String userPhone) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userPhone).get();

      if (doc.exists) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        List<dynamic> contactList = userData['contactList'] ?? [];
        return contactList.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error getting user contacts: $e');
      rethrow;
    }
  }
}
