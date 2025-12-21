import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/model/message_model.dart';
import 'package:whatsapp/utils/my_colors.dart';

class ChatStyle extends StatelessWidget with MyColors {
  final MessageModel messageDatas;
  final bool isSender;

  const ChatStyle({super.key, required this.messageDatas, required this.isSender});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: EdgeInsets.only(
          left: isSender ? 50 : 8,
          right: isSender ? 8 : 50,
          top: 3,
          bottom: 3,
        ),
        decoration: BoxDecoration(
          color: isSender ? MyColors.chatSenderContainerColor : MyColors.chatReciverContainerColor,
          borderRadius: isSender
              ? const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(0), // sharp corner
                )
              : const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(0), // sharp corner
                  bottomRight: Radius.circular(8),
                ),
        ),
        child: Text(
          messageDatas.msg,
          style: GoogleFonts.roboto(color: MyColors.foregroundColor),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
