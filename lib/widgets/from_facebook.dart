import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FromFacebook extends StatelessWidget {
  const FromFacebook({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('from', style: GoogleFonts.roboto(color: Color(0XFF867373))),
        Text(
          'FACEBOOK',
          style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
        ),
        SizedBox(height: 90),
      ],
    );
  }
}
