import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/controllers/app_startup_controller.dart';
import 'package:whatsapp/controllers/chat_controller.dart';
import 'package:whatsapp/screen/chats/chat_menus_list.dart';
import 'package:whatsapp/screen/contact/contact_list.dart';
import 'package:whatsapp/utils/my_colors.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatController _chatController = Get.put(ChatController());

  @override
  void initState() {
    _chatController.getContactList();
    super.initState();
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
                      if (_chatController.buttomNavigationIndex.value == 0) ...[
                        ChatMenusList(),
                      ] else if (_chatController.buttomNavigationIndex.value == 1) ...[
                        Center(child: Text('Updates')),
                      ] else if (_chatController.buttomNavigationIndex.value == 2) ...[
                        Center(child: Text('Communities')),
                      ] else if (_chatController.buttomNavigationIndex.value == 3) ...[
                        ContactListScreen(),
                      ] else ...[
                        Center(child: Text('No Data')),
                      ],
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

  final ChatController _chatController = Get.put(ChatController());
  final AppStartupController _appStartupController = Get.put(AppStartupController());

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
          bool isSelected = _chatController.buttomNavigationIndex.value == index;
          return GestureDetector(
            onTap: () {
              _chatController.buttomNavigationIndex.value = index;
              if (index == 2) {
                _appStartupController.logOut(context);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MyColors.cetagorySelectedContainerBackgroundColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    bottomNavigationComponent[index].icon,
                    size: 20,
                    color: isSelected
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
