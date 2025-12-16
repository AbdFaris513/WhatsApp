import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/utils/my_colors.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final ChatBodyController chatBodyController = Get.put(ChatBodyController());
  // final ContactController contactController = Get.put(ContactController());
  String? phoneNumber;

  Future<void> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString('loggedInPhone');

    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      debugPrint('Logged-in phone number: $phoneNumber');
      // Call both functions after getting the phone number
      // await contactController.getUserContactList(phoneNumber: phoneNumber!);
      // await contactController.setupMessagedContactsStream(); // ← ADD THIS LINE
    } else {
      debugPrint('No phone number saved.');
    }
  }

  @override
  initState() {
    super.initState();
    getPhoneNumber();
  }

  @override
  void dispose() {
    // Clean up when widget is disposed
    // contactController.messagedContacts.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Obx(
                  () => Column(
                    children: [
                      // if (chatBodyController.bottonNavigatorIndex.value == 0) ...[
                      //   // ChatMenusList(),
                      // ] else if (chatBodyController.bottonNavigatorIndex.value == 1) ...[
                      //   Center(child: Text('Chat')),
                      // ] else if (chatBodyController.bottonNavigatorIndex.value == 2) ...[
                      //   Center(child: Text('Updates')),
                      // ] else if (chatBodyController.bottonNavigatorIndex.value == 3) ...[
                      //   // ContactListScreen(),
                      // ] else ...[
                      Center(child: Text('No Data')),
                      // ],
                    ],
                  ),
                ),
              ),
            ),
            BottomNavigator(),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class BottomNavigator extends StatelessWidget with MyColors {
  BottomNavigator({super.key});

  // final ChatBodyController chatBodyController = Get.put(ChatBodyController());

  final List<BottomNavigationComponent> bottomNavigationComponent = [
    BottomNavigationComponent(icon: Icons.message_outlined, name: 'Chats'),
    BottomNavigationComponent(icon: Icons.update_outlined, name: 'Updates'),
    BottomNavigationComponent(icon: Icons.group_outlined, name: 'Communities'),
    BottomNavigationComponent(icon: Icons.contacts_outlined, name: 'Contacts'),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(bottomNavigationComponent.length, (index) {
          // bool isSelected = chatBodyController.bottonNavigatorIndex.value == index;
          return GestureDetector(
            onTap: () {
              // chatBodyController.bottonNavigatorIndex.value = index;
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        true //isSelected
                        ? MyColors.cetagorySelectedContainerBackgroundColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    bottomNavigationComponent[index].icon,
                    size: 20,
                    color:
                        true //isSelected
                        ? MyColors.cetagorySelectedContainerForegroundColor
                        : Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  bottomNavigationComponent[index].name,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class BottomNavigationComponent {
  final String name;
  final IconData icon;

  BottomNavigationComponent({required this.name, required this.icon});
}
