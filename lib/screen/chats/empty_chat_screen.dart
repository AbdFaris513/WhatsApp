import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/controllers/chat_controller.dart';
import 'package:whatsapp/screen/contact/add_contact.dart';
import 'package:whatsapp/utils/my_colors.dart';

class EmptyChatScreen extends StatefulWidget with MyColors {
  EmptyChatScreen({super.key});

  @override
  State<EmptyChatScreen> createState() => _EmptyChatScreenState();
}

class _EmptyChatScreenState extends State<EmptyChatScreen> {
  final ChatController _chatController = Get.put(ChatController());

  void _openPopupAfterDelay() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ContactPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasContacts = _chatController.contactDataList.isNotEmpty;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Start Chatting',
            style: GoogleFonts.roboto(
              color: MyColors.foregroundColor,
              fontWeight: FontWeight.w500,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hasContacts
                ? 'Chat with your ${_chatController.contactDataList.length} WhatsApp contacts or create a new contact.'
                : 'No contacts yet?\nStart fresh by adding a new one!',
            style: GoogleFonts.roboto(
              color: MyColors.foregroundColor,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!hasContacts) ...[
            // You can replace this with an illustration too
            Icon(Icons.contact_page_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Tap below to add your first contact 👇',
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
          if (hasContacts) ...[
            SizedBox(
              height: 100,
              child: Obx(
                () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _chatController
                      .contactDataList
                      .length, // change to _chatController.contactDataList.length
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () async {
                        await _chatController.getChatScreen(
                          context: context,
                          contactData: _chatController.contactDataList[index],
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 70,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset("assets/no_dp.jpeg", height: 60, width: 60),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _chatController.contactDataList[index].contactFirstName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          OutlinedButton(
            onPressed: () {
              // chatBodyController.bottonNavigatorIndex.value = 3;

              _openPopupAfterDelay();
            },

            style: OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              side: BorderSide(color: Colors.grey.shade400),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Add a contact',
              style: TextStyle(
                color: MyColors.massageNotificationColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
