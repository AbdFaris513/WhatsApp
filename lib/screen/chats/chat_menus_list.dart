import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/controllers/chat_controller.dart';
import 'package:whatsapp/controllers/user_controller.dart';
import 'package:whatsapp/model/contact_models.dart';
import 'package:whatsapp/screen/chats/chats_screen.dart';
import 'package:whatsapp/screen/chats/empty_chat_screen.dart';
import 'package:whatsapp/utils/my_colors.dart';
import 'package:whatsapp/widgets/search.dart';

class ChatMenusList extends StatefulWidget {
  const ChatMenusList({super.key});

  @override
  State<ChatMenusList> createState() => _ChatMenusListState();
}

class _ChatMenusListState extends State<ChatMenusList> {
  final ChatController _chatController = Get.put(ChatController());
  // final ContactController contactController = Get.put(ContactController());

  @override
  void initState() {
    super.initState();
    // Set up the real-time stream instead of one-time call
    debugPrint('Call @initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // contactController.setupMessagedContactsStream();
    });
  }

  @override
  void dispose() {
    // Clean up when widget is disposed
    // contactController.messagedContacts.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ChartMenuAppBar(),
          SizedBox(height: 12),

          // Use Obx to automatically rebuild when messagedContacts changes
          Obx(() {
            if (_chatController.messagedContacts.isNotEmpty) {
              return Expanded(
                child: Column(
                  children: [
                    ChartMenuSearchBar(),
                    SizedBox(height: 12),
                    ChartMenuCategories(categoriesList: ['All', 'Unread', 'Favourites', 'Groups']),
                    SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _chatController.messagedContacts.length,
                        itemBuilder: (context, index) {
                          return ChatsDetailsContainer(
                            contactData: _chatController.messagedContacts[index],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return EmptyChatScreen();
            }
          }),
        ],
      ),
    );
  }
}

class ChatsDetailsContainer extends StatefulWidget with MyColors {
  final ContactData contactData;

  ChatsDetailsContainer({super.key, required this.contactData});

  @override
  State<ChatsDetailsContainer> createState() => _ChatsDetailsContainerState();
}

class _ChatsDetailsContainerState extends State<ChatsDetailsContainer> {
  final ChatController _chatController = Get.put(ChatController());
  final UserController _userController = Get.put(UserController());

  late final String? userID;

  @override
  void initState() {
    getAwaitFunctions();
    super.initState();
  }

  Future<void> getAwaitFunctions() async {
    // userID = await chatBodyController.getUserPhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        String? currentUserId = await _userController.getPhoneNumber();

        Get.to(
          () => ChatsScreen(
            contactDetailData: widget.contactData,
            currentUserId: currentUserId ?? 'null',
          ),
        );
      },
      child: InkWell(
        onTap: () async {
          // await firstController.getChatScreen(context: context, contactData: widget.contactData);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 3),
          margin: EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(50),
                    child: Image.asset(
                      "assets/no_dp.jpeg",
                      // widget.contactData.contactImage == null
                      //     ? "assets/no_dp.jpeg"
                      //     : widget.contactData.contactImage!,
                      height: 45,
                      width: 45,
                    ),
                  ),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.contactData.contactFirstName,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: MyColors.foregroundColor,
                        ),
                      ),
                      Text(
                        widget.contactData.contactLastMsg ?? '',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: MyColors.searchHintTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _chatController.formatLastInteraction(widget.contactData.contactLastMsgTime),
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: (widget.contactData.unreadMessages) > 0
                          ? MyColors.massageNotificationColor
                          : MyColors.searchHintTextColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: widget.contactData.unreadMessages > 0
                          ? MyColors.massageNotificationColor
                          : Colors.transparent,
                      foregroundColor: widget.contactData.unreadMessages > 0
                          ? MyColors.backgroundColor
                          : Colors.transparent,
                      child: Text(
                        widget.contactData.unreadMessages.toString(),
                        style: GoogleFonts.roboto(fontSize: 11, color: MyColors.backgroundColor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartMenuCategories extends StatefulWidget with MyColors {
  final List<String> categoriesList;
  const ChartMenuCategories({super.key, required this.categoriesList});

  @override
  State<ChartMenuCategories> createState() => _ChartMenuCategoriesState();
}

class _ChartMenuCategoriesState extends State<ChartMenuCategories> with MyColors {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categoriesList.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? MyColors.cetagorySelectedContainerBackgroundColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: MyColors.cetagoryContainerBorderColor),
              ),
              child: Center(
                child: Text(
                  widget.categoriesList[index],
                  style: GoogleFonts.roboto(
                    color: isSelected
                        ? MyColors.cetagorySelectedContainerForegroundColor
                        : MyColors.searchHintTextColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChartMenuAppBar extends StatelessWidget with MyColors {
  const ChartMenuAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Chats',
          style: GoogleFonts.roboto(
            color: MyColors.foregroundColor,
            fontWeight: FontWeight.w900,
            fontSize: 34,
          ),
        ),
        Row(
          children: [
            SvgPicture.asset("assets/camera.svg", width: 25, height: 25),
            SizedBox(width: 6),
            InkWell(
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('loggedInPhone');

                  // Optional: Navigate to login screen
                  // Navigator.pushReplacement(
                  //   // ignore: use_build_context_synchronously
                  //   context,
                  //   MaterialPageRoute(builder: (context) => FirstScreen()),
                  // );
                } catch (e) {
                  ScaffoldMessenger.of(
                    // ignore: use_build_context_synchronously
                    context,
                  ).showSnackBar(SnackBar(content: Text('Logout failed: ${e.toString()}')));
                }
              },
              child: CircleAvatar(radius: 14, child: Icon(Icons.add)),
            ),
          ],
        ),
      ],
    );
  }
}

class ContactDetailsContainer extends StatelessWidget with MyColors {
  final ContactData contactData;
  ContactDetailsContainer({super.key, required this.contactData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(50),
                child: Image.asset(
                  contactData.contactImage == null
                      ? "assets/no_dp.jpeg"
                      : contactData.contactImage!,
                  height: 45,
                  width: 45,
                ),
              ),
              SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    contactData.contactFirstName,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: MyColors.foregroundColor,
                    ),
                  ),
                  Text(
                    contactData.contactStatus ?? '',
                    style: GoogleFonts.roboto(fontSize: 14, color: MyColors.searchHintTextColor),
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Mobile',
                style: GoogleFonts.roboto(fontSize: 11, color: MyColors.searchHintTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
