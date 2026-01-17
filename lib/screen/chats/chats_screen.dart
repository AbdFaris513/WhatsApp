// ChatsScreen - FIXED with proper reactive updates

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/controllers/chat_controller.dart';
import 'package:whatsapp/model/contact_models.dart';
import 'package:whatsapp/model/message_model.dart';
import 'package:whatsapp/utils/my_colors.dart';
import 'package:whatsapp/widgets/chat_style.dart';

class ChatsScreen extends StatefulWidget {
  String currentUserId;
  ContactData contactDetailData;
  ChatsScreen({super.key, required this.contactDetailData, required this.currentUserId});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ScrollController _scrollController = ScrollController();
  final ChatController chatController = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();

    // ✅ Scroll to bottom whenever messages list changes
    ever(chatController.messagesList, (_) {
      WidgetsBinding.instance.addPostFrameCallback((__) {
        if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });

    // ✅ Initial scroll after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  ChatsScreenHeader(
                    contactDetailData: widget.contactDetailData,
                    currentUserId: widget.currentUserId,
                  ),
                  Expanded(
                    child: Obx(() {
                      debugPrint(
                        "🔄 Building ListView with ${chatController.messagesList.length} messages",
                      );

                      if (chatController.messagesList.isEmpty) {
                        return Center(
                          child: Text(
                            "No messages yet",
                            style: GoogleFonts.roboto(
                              color: MyColors.massageFieldForeGroundColor,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return Container(
                        margin: EdgeInsets.only(top: 4),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: chatController.messagesList.length,
                          itemBuilder: (context, index) {
                            final message = chatController.messagesList[index];
                            final isSender = message.msgSender == widget.currentUserId;

                            return ChatStyle(messageDatas: message, isSender: isSender);
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            ChatsScreenFooter(
              contactDetailData: widget.contactDetailData,
              currentUserId: widget.currentUserId,
              scrollController: _scrollController,
            ),
          ],
        ),
      ),
    );
  }
}

// Footer
class ChatsScreenFooter extends StatefulWidget with MyColors {
  String currentUserId;
  ContactData contactDetailData;
  ScrollController scrollController;

  ChatsScreenFooter({
    super.key,
    required this.contactDetailData,
    required this.currentUserId,
    required this.scrollController,
  });

  @override
  State<ChatsScreenFooter> createState() => _ChatsScreenFooterState();
}

class _ChatsScreenFooterState extends State<ChatsScreenFooter> with MyColors {
  final ChatController chatController = Get.find<ChatController>();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      debugPrint("🎤 Mic pressed");
      return;
    }

    debugPrint("📤 Sending message: $text");

    final MessageModel message = MessageModel(
      id: '',
      msg: text,
      msgSender: widget.currentUserId,
      msgReceiver: widget.contactDetailData.contactNumber,
      type: MessageType.text,
      status: MessageStatus.sending,
      sendTime: DateTime.now(),
    );

    _messageController.clear();
    await chatController.sendMessage(msg: message);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: MyColors.massageFieldBackGroundColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_emotions_outlined,
                  color: MyColors.massageFieldForeGroundColor,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: MyColors.foregroundColor,
                      fontWeight: FontWeight.w300,
                    ),
                    decoration: InputDecoration(
                      hintText: "Message",
                      hintStyle: GoogleFonts.roboto(
                        fontSize: 18,
                        color: MyColors.massageFieldForeGroundColor,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSendMessage(),
                  ),
                ),
                Icon(
                  Icons.attach_file_sharp,
                  color: MyColors.massageFieldForeGroundColor,
                  size: 25,
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _messageController,
                  builder: (context, value, _) {
                    return value.text.isEmpty
                        ? Icon(
                            Icons.camera_alt_outlined,
                            color: MyColors.massageFieldForeGroundColor,
                            size: 25,
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: _handleSendMessage,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MyColors.massageNotificationColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _messageController,
              builder: (context, value, _) {
                return Icon(
                  value.text.isEmpty ? Icons.mic : Icons.send_rounded,
                  color: MyColors.backgroundColor,
                  size: 21,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Header
class ChatsScreenHeader extends StatelessWidget with MyColors {
  String currentUserId;
  ContactData contactDetailData;
  ChatsScreenHeader({super.key, required this.contactDetailData, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      shadowColor: MyColors.backgroundColor,
      child: Container(
        color: MyColors.backgroundColor,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(Icons.arrow_back_rounded, color: MyColors.foregroundColor, size: 26),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: contactDetailData.contactImage.toString().isNotEmpty
                      ? Image.network(
                          contactDetailData.contactImage.toString(),
                          width: 37,
                          height: 37,
                        )
                      : Image.asset("assets/no_dp.jpeg", width: 37, height: 37),
                ),
                SizedBox(width: 8),
                Text(
                  contactDetailData.contactFirstName,
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: MyColors.foregroundColor,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(Icons.videocam_outlined, color: MyColors.foregroundColor, size: 30),
                ),
                Icon(Icons.call_outlined, color: MyColors.foregroundColor, size: 25),
                Icon(Icons.more_vert, color: MyColors.foregroundColor, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
