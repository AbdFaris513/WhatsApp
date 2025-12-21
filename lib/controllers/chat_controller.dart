import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:whatsapp/model/contact_models.dart';

class ChatController extends GetxController {
  RxInt buttomNavigationIndex = (0).obs;

  RxList<ContactData> contactData = <ContactData>[].obs;

  void addContact(ContactData contactData, BuildContext context) {}

  Future<void> getChatScreen({
    required BuildContext context,
    required ContactData contactData,
  }) async {}
}
