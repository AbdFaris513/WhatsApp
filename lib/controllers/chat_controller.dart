import 'dart:async';

import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp/controllers/user_controller.dart';
import 'package:whatsapp/model/contact_models.dart';
import 'package:whatsapp/model/message_model.dart';
import 'package:whatsapp/screen/chats/chats_screen.dart';
import 'package:whatsapp/service/firestore_service.dart';
import 'package:whatsapp/service/snackbars_service.dart';

class ChatController extends GetxController {
  final UserController _userController = UserController();
  RxInt buttomNavigationIndex = (0).obs;

  RxList<MessageModel> messagesList = <MessageModel>[].obs;
  StreamSubscription? _messagesSubscription;

  RxList<ContactData> contactDataList = <ContactData>[].obs;
  RxList<ContactData> messagedContacts = <ContactData>[].obs;

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    super.onClose();
  }

  Future<bool> doesUserExistByPhone(String phoneNumber, BuildContext context) async {
    bool isExistes = await FirebaseHelper.doesUserExistByPhone(phoneNumber);
    if (!isExistes) {
      SnackbarsService.showTopSnackBarContactNotExisits(context);
    }
    return isExistes;
  }

  void getContactList() async {
    String userPhone = await _userController.getPhoneNumber() ?? "Error";
    final List<Map<String, dynamic>> contactList = await FirebaseHelper.getContactList(userPhone);
    contactDataList.value = contactList.map((e) => ContactData.fromContactOnlyJson(e)).toList();
  }

  void addContact(ContactData contactData, BuildContext context) async {
    String userPhone = await _userController.getPhoneNumber() ?? "Error";
    bool isExistes = await doesUserExistByPhone(contactData.contactNumber, context);
    if (!isExistes) return;
    await FirebaseHelper.upsertContact(contact: contactData, userPhone: userPhone);
    getContactList();
  }

  Future<void> getChatScreen({
    required final BuildContext context,
    required final ContactData contactData,
  }) async {
    String? currentUserId = await _userController.getPhoneNumber() ?? "Error";

    // ✅ CRITICAL: Start listening BEFORE navigation
    await listenToMessages(currentUserId, contactData.contactNumber);

    Get.to(() => ChatsScreen(contactDetailData: contactData, currentUserId: currentUserId));
  }

  String formatLastInteraction(DateTime? dateTime) {
    if (dateTime == null) return "";

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return DateFormat("h:mm a").format(dateTime).toLowerCase();
    } else if (dateToCheck == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat("dd/MM/yyyy").format(dateTime);
    }
  }

  // ✅ ADDED: Listen to messages stream
  Future<void> listenToMessages(String user1, String user2) async {
    // Cancel any existing subscription
    _messagesSubscription?.cancel();

    // Subscribe to the stream
    _messagesSubscription = FirebaseHelper.listenToMessages(user1, user2).listen(
      (messages) {
        messagesList.assignAll(messages);
        debugPrint("✅ Messages updated: ${messages.length} messages");
      },
      onError: (error) {
        debugPrint("❌ Error in message stream: $error");
      },
    );
  }

  Future<void> sendMessage({required MessageModel msg}) async {
    try {
      await FirebaseHelper.sendMessage(msg: msg);
      debugPrint("✅ Message sent successfully");
    } catch (e) {
      debugPrint("❌ Error on sendMessage() : $e");
    }
  }
}
