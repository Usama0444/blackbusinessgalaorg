import 'dart:convert';

import 'package:bbp/common/mybaisedbutton.dart';
import 'package:bbp/common/mytextfield.dart';
import 'package:bbp/utils/app_colors.dart';
import 'package:bbp/utils/constant.dart';
import 'package:bbp/view/dashboard/dashboard_screen.dart';
import 'package:bbp/view/forgotpassword/forgotpassword_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  final scaffoldKey = new GlobalKey<ScaffoldState>();

  final userTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  showMessage(String message, Color color, IconData iconData) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.black, textColor: Colors.white, fontSize: 16.0);
  }

  signIn(String username, String password) async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> data = {'username': username, 'password': password};
    var jsonData = null;
    var reponse = await http.post(Uri.parse("${Constants.BASE_URL}/user/login/user_login"), body: json.encode(data));
    if (reponse.statusCode == 200) {
      jsonData = json.decode(reponse.body);
      var data = jsonData["data"];
      if (jsonData["status"]) {
        showMessage(jsonData["message"], Colors.green, Icons.done);
        print(data["era_tnk"] + "-----" + data["pro_img"] + "-----" + data["name"] + "-----" + data["id"]);
        await prefs.setString("token", data["era_tnk"]);
        await prefs.setString("pro_img", data["pro_img"]);
        await prefs.setString("name", data["name"]);
        await prefs.setString("id", data["id"]);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => DashboardScreen()), (route) => false);
        // Navigator.push(
        //           context,
        //           MaterialPageRoute(builder: (context) => LoginScreen()),
        //         );
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

  clearTextInput() {
    userTextController.clear();
    passwordTextController.clear();
  }

  checkValidation() {
    if (userTextController.text == null || userTextController.text.isEmpty || userTextController.text == "") {
      showMessage("Please enter username", Colors.red, Icons.close);
      return false;
    } else {
      if (passwordTextController.text == null || passwordTextController.text.isEmpty || passwordTextController.text == "") {
        showMessage("Please enter password", Colors.red, Icons.close);
        return false;
      } else {
        return true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
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
                      Image.asset(
                        "assets/images/applogo.png",
                        width: width * 0.9,
                        height: height * 0.25,
                        fit: BoxFit.fitHeight,
                      ),
                      Text(
                        'Sign in',
                        style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 26)),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      MyTextField(
                        onTap: () {},
                        placeholder: "Username",
                        leftIcon: Icons.account_circle,
                        textController: userTextController,
                        obscureText: false,
                        onChanged: (text) => userTextController.text = text,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      MyTextField(
                        placeholder: "Password",
                        leftIcon: Icons.lock,
                        textController: passwordTextController,
                        obscureText: true,
                        onChanged: (text) => passwordTextController.text = text,
                        onTap: () {},
                      ),
                      SizedBox(height: 45),
                      Container(
                        width: width * 0.85,
                        height: height <= 667.0 ? height * 0.07 : height * 0.06,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              side: BorderSide(color: Colors.black, width: 0),
                            ),
                            backgroundColor: Colors.black,
                          ),
                          onPressed: () {
                            print('press');
                            if (checkValidation()) {
                              signIn(userTextController.text, passwordTextController.text);
                            }
                          },
                          child: Text(
                            'sign in'.toUpperCase(),
                            style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.white, letterSpacing: .5, fontSize: height <= 667.0 ? 16 : 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.04,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          "Forgot password?",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(textStyle: TextStyle(color: AppColors.gold, letterSpacing: .5, fontWeight: FontWeight.w500, fontSize: 14)),
                        ),
                      )
                    ],
                  ),
                ),
              ));
  }
}
