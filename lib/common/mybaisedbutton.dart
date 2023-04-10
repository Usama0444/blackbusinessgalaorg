import 'package:bbp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyRaisedButton extends StatelessWidget {
  final String title;
  final bool isBackground;
  final Function onPressed;

  const MyRaisedButton({Key? key, required this.title, required this.isBackground, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return isBackground
        ? Container(
            width: width * 0.85,
            height: height <= 667.0 ? height * 0.07 : height * 0.06,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: isBackground ? BorderSide(color: Colors.black, width: 0) : BorderSide(color: Colors.black, width: 2),
                ),
                backgroundColor: Colors.black,
              ),
              onPressed: onPressed(),
              child: Text(
                title.toUpperCase(),
                style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.white, letterSpacing: .5, fontSize: height <= 667.0 ? 16 : 18, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        : Container(
            width: width * 0.85,
            height: height <= 667.0 ? height * 0.07 : height * 0.06,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(color: AppColors.gold, width: 2),
                ),
                backgroundColor: Colors.white,
              ),
              onPressed: onPressed(),
              child: Text(
                "Sign in".toUpperCase(),
                style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: height <= 667.0 ? 16 : 18, fontWeight: FontWeight.bold)),
              ),
            ),
          );
  }
}
