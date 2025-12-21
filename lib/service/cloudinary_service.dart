import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // Cloudinary configuration
  static const String _cloudName = 'djk6rwklf';
  static const String _apiKey = '289131489398422';
  static const String _apiSecret = 'C737kVzqnZLQ-YT891J2gx24SNU';

  String _generateSignature(String paramsToSign, String apiSecret) {
    var bytes = utf8.encode(paramsToSign + apiSecret);
    var digest = sha1.convert(bytes);
    return digest.toString();
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      print('Starting Cloudinary upload...');

      // Generate timestamp
      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Create params for signature
      String folder = 'whatsapp_profiles';
      String paramsToSign = 'folder=$folder&timestamp=$timestamp';

      // Generate signature
      String signature = _generateSignature(paramsToSign, _apiSecret);

      print('Signature generated');

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload'),
      );

      // Add required fields
      request.fields['api_key'] = _apiKey;
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
}
