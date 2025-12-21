import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:whatsapp/model/user_profile_model.dart';
import 'package:whatsapp/service/firestore_service.dart';

class UserController extends GetxController {
  late Rx<UserProfile> userProfile = UserProfile.empty().obs;
  Future<bool> getUserData(String phoneNumber) async {
    try {
      final responce = await FirebaseHelper.getUserData(phoneNumber);
      if (responce != null) {
        userProfile.value = UserProfile.fromMap(responce);
      }
      debugPrint("Profile : ${userProfile.value.toMap()}");
      return responce != null;
    } catch (e) {
      debugPrint("Error on getUserData() $e ");
      return false;
    }
  }
}
