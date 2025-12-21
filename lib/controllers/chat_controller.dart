import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp/controllers/user_controller.dart';
import 'package:whatsapp/model/contact_models.dart';
import 'package:whatsapp/service/firestore_service.dart';
import 'package:whatsapp/service/snackbars_service.dart';

class ChatController extends GetxController {
  final UserController _userController = UserController();
  RxInt buttomNavigationIndex = (0).obs;

  RxList<ContactData> contactDataList = <ContactData>[].obs;
  RxList<ContactData> messagedContacts = <ContactData>[
    ContactData(
      contactNumber: '9876543210',
      contactFirstName: 'Arjun',
      contactSecondName: 'Kumar',
      contactStatus: 'Available',
      isOnline: true,
      unreadMessages: 3,
      contactLastMsg: 'Hey, are you coming?',
      contactLastMsgType: 'text',
      contactLastMsgTime: DateTime.now().subtract(const Duration(minutes: 5)),
      lastInteraction: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ContactData(
      contactNumber: '9123456780',
      contactFirstName: 'Priya',
      contactSecondName: 'Sharma',
      contactStatus: 'Busy',
      isContactMuted: true,
      unreadMessages: 0,
      contactLastMsg: 'Call you later',
      contactLastMsgType: 'text',
      contactLastMsgTime: DateTime.now().subtract(const Duration(hours: 2)),
      lastInteraction: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ContactData(
      contactNumber: '9988776655',
      contactFirstName: 'Rahul',
      contactBusinessName: 'Tech Solutions',
      contactStatus: 'Available',
      isContactPinned: true,
      unreadMessages: 12,
      contactLastMsg: 'Invoice sent',
      contactLastMsgType: 'image',
      contactLastMsgTime: DateTime.now().subtract(const Duration(minutes: 30)),
      lastInteraction: DateTime.now().subtract(const Duration(minutes: 30)),
      labels: ['Business', 'Important'],
    ),
    ContactData(
      contactNumber: '9090909090',
      contactFirstName: 'Sneha',
      contactSecondName: 'Iyer',
      contactStatus: 'Offline',
      isContactArchived: true,
      unreadMessages: 0,
      contactLastMsg: 'Thanks!',
      contactLastMsgType: 'text',
      contactLastMsgTime: DateTime.now().subtract(const Duration(days: 1)),
      lastInteraction: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ContactData(
      contactNumber: '9555443322',
      contactFirstName: 'Vikram',
      contactStatus: 'Available',
      isContactBlocked: false,
      unreadMessages: 1,
      contactLastMsg: 'See you tomorrow',
      contactLastMsgType: 'text',
      contactLastMsgTime: DateTime.now().subtract(const Duration(minutes: 10)),
      lastInteraction: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ].obs;

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

  String formatLastInteraction(DateTime? dateTime) {
    if (dateTime == null) return "";

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      // same day → show time like 10:22 pm
      return DateFormat("h:mm a").format(dateTime).toLowerCase();
    } else if (dateToCheck == yesterday) {
      return "Yesterday";
    } else {
      // show full date like 18/08/2025
      return DateFormat("dd/MM/yyyy").format(dateTime);
    }
  }
}
