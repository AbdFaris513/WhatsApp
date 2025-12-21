import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:whatsapp/controllers/user_controller.dart';
import 'package:whatsapp/model/contact_models.dart';
import 'package:whatsapp/service/firestore_service.dart';
import 'package:whatsapp/service/snackbars_service.dart';

class ChatController extends GetxController {
  final UserController _userController = UserController();
  RxInt buttomNavigationIndex = (0).obs;

  RxList<ContactData> contactDataList = <ContactData>[].obs;

  Future<bool> doesUserExistByPhone(String phoneNumber, BuildContext context) async {
    bool isExistes = await FirebaseHelper.doesUserExistByPhone(phoneNumber);
    if (!isExistes) {
      SnackbarsService.showTopSnackBarContactNotExisits(context);
    }
    return isExistes;
  }

  void addContact(ContactData contactData, BuildContext context) async {
    String userPhone = await _userController.getPhoneNumber() ?? "Error";
    bool isExistes = await doesUserExistByPhone(userPhone, context);
    if (!isExistes) return;
    await FirebaseHelper.upsertContact(contact: contactData, userPhone: userPhone);
    final List<Map<String, dynamic>> contactList = await FirebaseHelper.getContactList(userPhone);
    contactDataList.value = contactList.map((e) => ContactData.fromContactOnlyJson(e)).toList();
  }

  Future<void> getChatScreen({
    required BuildContext context,
    required ContactData contactData,
  }) async {}
}
