import 'package:flutter/material.dart';
import 'package:whatsapp/utils/my_colors.dart';

class ChartMenuSearchBar extends StatelessWidget with MyColors {
  const ChartMenuSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.searchBackgroundColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextField(
        cursorColor: MyColors.massageNotificationColor,
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: MyColors.searchHintTextColor),
          prefixIcon: Icon(Icons.search, color: MyColors.searchHintTextColor),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
