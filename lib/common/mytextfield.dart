import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextField extends StatelessWidget {
  final String placeholder;
  final IconData leftIcon;
  final TextEditingController textController;
  final Function onChanged;
  final bool obscureText;
  final bool? isEnabled;
  var onTap;
  final bool? isReadOnly;
  MyTextField({
    Key? key,
    required this.placeholder,
    required this.leftIcon,
    required this.textController,
    required this.onChanged,
    required this.obscureText,
    this.isEnabled,
    this.onTap,
    this.isReadOnly,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      // padding: EdgeInsets.all(5),
      width: width * 0.85,
      height: height <= 667.0 ? height * 0.07 : height * 0.06,
      child: TextField(
        onTap: onTap() ?? () {},
        enabled: isEnabled,
        obscureText: obscureText,
        onChanged: onChanged(),
        controller: textController,
        readOnly: isReadOnly == null ? false : true,
        cursorColor: Colors.black,
        decoration: new InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            prefixIcon: Icon(
              leftIcon,
              size: height <= 667.0 ? 23 : 25,
            ),
            border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(25.0),
              ),
            ),
            filled: true,
            hintStyle: new TextStyle(color: Colors.grey[800]),
            hintText: placeholder,
            isDense: true,
            fillColor: Colors.white70),
        style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: height <= 667.0 ? 14 : 16)),
      ),
    );
  }
}
