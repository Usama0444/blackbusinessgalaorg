import 'dart:convert';

import 'package:bbp/common/mybaisedbutton.dart';
import 'package:bbp/common/mytextfield.dart';
import 'package:bbp/utils/app_colors.dart';
import 'package:bbp/utils/constant.dart';
import 'package:bbp/view/dashboard/dashboard_screen.dart';
import 'package:bbp/view/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isLoading = false;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final nameTextController = TextEditingController();
  final userTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  signup(
    String name,
    String username,
    String email,
    String password,
  ) async {
    Map<String, String> data = {"email": email, "name": name, "username": username, "password": password, "fcm_token": "21316854azc"};
    var jsonData = null;
    var reponse = await http.post(Uri.parse("${Constants.BASE_URL}/user/reg/create_user"), body: json.encode(data));
    print('&&&&&&&&&&&&&&&&&&');
    print('response $reponse');
    print('&&&&&&&&&&&&&&&&&&');

    if (reponse.statusCode == 200) {
      jsonData = json.decode(reponse.body);
      if (jsonData["status"]) {
        showMessage(jsonData["message"], Colors.green, Icons.done);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
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

  showMessage(String message, Color color, IconData iconData) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.black, textColor: Colors.white, fontSize: 16.0);
  }

  clearTextInput() {
    userTextController.clear();
    passwordTextController.clear();
    emailTextController.clear();
    passwordTextController.clear();
  }

  checkValidation() {
    if (nameTextController.text == null || nameTextController.text.isEmpty || nameTextController.text == "") {
      showMessage("Please enter name", Colors.red, Icons.close);
      return false;
    } else {
      if (userTextController.text == null || userTextController.text.isEmpty || userTextController.text == "") {
        showMessage("Please enter username", Colors.red, Icons.close);
        return false;
      } else {
        if (emailTextController.text == null || emailTextController.text.isEmpty || emailTextController.text == "") {
          showMessage("Please enter email", Colors.red, Icons.close);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        key: scaffoldKey,
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
                        height: 110,
                      ),
                      Image.asset("assets/images/applogo.png", width: width * 0.7, height: height * 0.1, fit: BoxFit.contain),
                      SizedBox(
                        height: 35,
                      ),
                      Text(
                        'Create an account',
                        style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: height <= 667.0 ? 24 : 26)),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      MyTextField(
                        placeholder: "Name",
                        leftIcon: Icons.person,
                        textController: nameTextController,
                        obscureText: false,
                        onChanged: (text) => nameTextController.text = text,
                        onTap: () {},
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      MyTextField(
                        placeholder: "Username",
                        onTap: () {},
                        leftIcon: Icons.account_circle,
                        textController: userTextController,
                        obscureText: false,
                        onChanged: (text) => userTextController.text = text,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      MyTextField(
                        placeholder: "Email",
                        onTap: () {},
                        leftIcon: Icons.email,
                        textController: emailTextController,
                        obscureText: false,
                        onChanged: (text) => emailTextController.text = text,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      MyTextField(
                        placeholder: "Password",
                        onTap: () {},
                        leftIcon: Icons.lock,
                        textController: passwordTextController,
                        obscureText: true,
                        onChanged: (text) => passwordTextController.text = text,
                      ),
                      SizedBox(height: 45),
                      // MyRaisedButton(
                      //   title: "Sign up",
                      //   isBackground: true,
                      //   onPressed: () {
                      // print('press');
                      // if (checkValidation()) {
                      //   signup(nameTextController.text, userTextController.text, emailTextController.text, passwordTextController.text);
                      // }
                      //   },
                      // ),
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
                              signup(nameTextController.text, userTextController.text, emailTextController.text, passwordTextController.text);
                            }
                          },
                          child: Text(
                            'sign up'.toUpperCase(),
                            style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.white, letterSpacing: .5, fontSize: height <= 667.0 ? 16 : 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'OR',
                        style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black87, letterSpacing: .5, fontSize: 16)),
                      ),
                      // SizedBox(height: 10),
                      // MyRaisedButton(
                      //   title: "Sign in",
                      //   isBackground: true,
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => LoginScreen()),
                      //     );
                      //   },
                      // ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => DashboardScreen()), (route) => false);
                        },
                        child: Container(
                          width: width * 0.85,
                          height: height * 0.03,
                          child: Text(
                            "Skip".toUpperCase(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(color: AppColors.gold, letterSpacing: .5, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, fontSize: height <= 667.0 ? 14 : 16)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      InkWell(
                        onTap: () {
                          launch("http://app.blackbusinesspensacola.org/tc.html");
                        },
                        child: Container(
                            width: width * 0.85,
                            height: height * 0.03,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "By signing up you agree to our".toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: height <= 667.0 ? 10 : 11)),
                                ),
                                Text(
                                  " terms of service".toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(textStyle: TextStyle(color: AppColors.gold, letterSpacing: .5, fontWeight: FontWeight.bold, fontSize: height <= 667.0 ? 10 : 11)),
                                ),
                              ],
                            )),
                      )
                    ],
                  ),
                ),
              ));
  }
}
