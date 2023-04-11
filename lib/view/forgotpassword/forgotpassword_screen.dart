import 'dart:convert';

import 'package:bbp/common/mybaisedbutton.dart';
import 'package:bbp/common/mytextfield.dart';
import 'package:bbp/utils/app_colors.dart';
import 'package:bbp/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailTextController = TextEditingController();

  var _isLoading = false;

  String _email = '';

  showMessage(String message, Color color, IconData iconData) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.black, textColor: Colors.white, fontSize: 16.0);
  }

  forgotPassword(String email) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> data = {'email': email};
    var jsonData = null;
    var reponse = await http.post(Uri.parse("${Constants.BASE_URL}/user/forgotPassword/reset_pass"), body: json.encode(data));
    if (reponse.statusCode == 200) {
      jsonData = json.decode(reponse.body);
      var data = jsonData["data"];
      if (jsonData["status"]) {
        showMessage(jsonData["message"], Colors.green, Icons.done);
        clearTextInput();
      } else {
        showMessage(jsonData["message"], Colors.red, Icons.error);
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      print(reponse.body);
    }
  }

  checkValidation() {
    if (_email == null || _email.isEmpty || _email == "") {
      showMessage("Please enter email", Colors.red, Icons.close);
      return false;
    } else {
      return true;
    }
  }

  clearTextInput() {
    emailTextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              )
            : SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Image.asset("assets/images/applogo.png", width: width * 0.7, height: height * 0.1, fit: BoxFit.contain),
                      SizedBox(
                        height: 35,
                      ),
                      Text(
                        'Recover password',
                        style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 26)),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      MyTextField(onTap: () {}, textController: emailTextController, onChanged: (text) => _email = text, placeholder: "email", leftIcon: Icons.email, obscureText: false),
                      SizedBox(height: 45),
                      MyRaisedButton(
                        title: "Submit",
                        isBackground: true,
                        onPressed: () {
                          if (checkValidation()) {
                            forgotPassword(_email);
                          }
                        },
                      ),
                      SizedBox(
                        height: height * 0.04,
                      ),
                    ],
                  ),
                ),
              ));
  }
}
