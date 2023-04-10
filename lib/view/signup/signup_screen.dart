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
  String _name = '';
  String _username = '';
  String _email = '';
  String _password = '';

  signup(String name, String username, String email, String password) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> data = {"email": email, "name": name, "username": username, "password": password, "fcm_token": "21316854azc"};
    var jsonData = null;
    var reponse = await http.post(Uri.parse("${Constants.BASE_URL}/user/reg/create_user"), body: json.encode(data));
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
    // scaffoldKey.currentState.showSnackBar(SnackBar(
    //   content: Container(
    //     width: double.infinity,
    //     height: 50,
    //     child: Center(
    //       child: Row(
    //         children: [
    //           Expanded(
    //             child: Icon(iconData),
    //             flex: 1,
    //           ),
    //           SizedBox(
    //             width: 10,
    //           ),
    //           Expanded(
    //             child: Container(
    //               child: Text(message,
    //                   style: GoogleFonts.poppins(
    //                       textStyle: TextStyle(
    //                           color: Colors.white,
    //                           letterSpacing: .5,
    //                           fontSize: 16))),
    //             ),
    //             flex: 8,
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    //   backgroundColor: color,
    //   // behavior: SnackBarBehavior.floating,
    //   shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.all(Radius.circular(10))),
    // ));
  }

  clearTextInput() {
    userTextController.clear();
    passwordTextController.clear();
    emailTextController.clear();
    passwordTextController.clear();
  }

  checkValidation() {
    if (_name == null || _name.isEmpty || _name == "") {
      showMessage("Please enter name", Colors.red, Icons.close);
      return false;
    } else {
      if (_username == null || _username.isEmpty || _username == "") {
        showMessage("Please enter username", Colors.red, Icons.close);
        return false;
      } else {
        if (_email == null || _email.isEmpty || _email == "") {
          showMessage("Please enter email", Colors.red, Icons.close);
          return false;
        } else {
          if (_password == null || _password.isEmpty || _password == "") {
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
                        onChanged: (text) => _name = text,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      MyTextField(
                        placeholder: "Username",
                        leftIcon: Icons.account_circle,
                        textController: userTextController,
                        obscureText: false,
                        onChanged: (text) => _username = text,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      MyTextField(
                        placeholder: "Email",
                        leftIcon: Icons.email,
                        textController: emailTextController,
                        obscureText: false,
                        onChanged: (text) => _email = text,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      MyTextField(
                        placeholder: "Password",
                        leftIcon: Icons.lock,
                        textController: passwordTextController,
                        obscureText: true,
                        onChanged: (text) => _password = text,
                      ),
                      SizedBox(height: 45),
                      MyRaisedButton(
                        title: "Sign up",
                        isBackground: true,
                        onPressed: () {
                          if (checkValidation()) {
                            signup(_name, _username, _email, _password);
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      Text(
                        'OR',
                        style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black87, letterSpacing: .5, fontSize: 16)),
                      ),
                      SizedBox(height: 10),
                      MyRaisedButton(
                        title: "Sign in",
                        isBackground: false,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                      ),
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
