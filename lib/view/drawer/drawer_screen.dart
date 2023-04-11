import 'dart:convert';

import 'package:bbp/utils/app_colors.dart';
import 'package:bbp/utils/constant.dart';
import 'package:bbp/view/addBusiness/addbusiness_screen.dart';
import 'package:bbp/view/editProfile/editprofile_screen.dart';
import 'package:bbp/view/favorites/favorites_screen.dart';
import 'package:bbp/view/login/login_screen.dart';
import 'package:bbp/view/signup/signup_screen.dart';
import 'package:bbp/view/video/video_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  bool _isLoggedIn = false;
  String name = '';
  String imgUrl = '';

  @override
  void initState() {
    super.initState();
    getProfile();
    print("ddddd");
  }

  showMessage(String message, Color color, IconData iconData) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("token") != null) {
      setState(() {
        _isLoggedIn = true;
      });
    }
    Map<String, String> requestHeaders = {
      'era-token': prefs.getString("token") ?? ''
    };
    var jsonData = null;
    var reponse = await http.get(
        Uri.parse("${Constants.BASE_URL}/user/profile/profile"),
        headers: requestHeaders);
    if (reponse.statusCode == 200) {
      jsonData = json.decode(reponse.body);
      var data = jsonData["data"];
      if (jsonData["status"]) {
        setState(() {
          name = data["name"];
          imgUrl = data["pro_img"];
        });
        print(imgUrl);
        showMessage(jsonData["message"], Colors.red, Icons.error);
      } else {
        showMessage(jsonData["message"], Colors.red, Icons.error);
      }
    } else {
      print(reponse.body);
    }
  }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => SignupScreen()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(top: 40, left: 10, bottom: 30),
      color: AppColors.primartColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(imgUrl == null
                    ? "https://cdn0.iconfinder.com/data/icons/social-media-network-4/48/male_avatar-512.png"
                    : imgUrl),
                backgroundColor: Colors.transparent,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                name,
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Colors.white,
                        letterSpacing: .5,
                        fontWeight: FontWeight.w500,
                        fontSize: 20)),
              ),
            ],
          ),
          Column(
            children: [
              InkWell(
                onTap: () {
                  _isLoggedIn
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddBusinessScreen()),
                        )
                      : showMessage("please login to access this feature",
                          Colors.red, Icons.receipt);
                },
                child: MenuWidget(title: "Add Business", icon: AntDesign.plus),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  _isLoggedIn
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FavoritesScreen()),
                        )
                      : showMessage("please login to access this feature",
                          Colors.red, Icons.receipt);
                },
                child: MenuWidget(title: "Favorites", icon: AntDesign.star),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VideoScreen()),
                  );
                },
                child: MenuWidget(
                    title: "Watch Video", icon: AntDesign.videocamera),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  launch(
                      "https://instagram.com/blackbusinesspensacola?igshid=1rphwmqss6f5m");
                },
                child:
                    MenuWidget(title: "Instagram", icon: AntDesign.instagram),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  launch("https://www.facebook.com/blackbusinesspensacola/");
                },
                child: MenuWidget(
                    title: "Facebook", icon: AntDesign.facebook_square),
              )
            ],
          ),
          _isLoggedIn
              ? Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfileScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            AntDesign.setting,
                            color: AppColors.gold,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Edit Profile",
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: .5,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        logout();
                      },
                      child: Row(
                        children: [
                          Icon(
                            AntDesign.logout,
                            color: AppColors.gold,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Log Out",
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: .5,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16)),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            AntDesign.login,
                            color: AppColors.gold,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Login",
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: .5,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            AntDesign.login,
                            color: AppColors.gold,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Signup",
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: .5,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16)),
                          ),
                        ],
                      ),
                    )
                  ],
                )
        ],
      ),
    );
  }
}

class MenuWidget extends StatelessWidget {
  final String title;
  final IconData icon;

  const MenuWidget({Key? key, required this.title, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 25,
          color: AppColors.gold,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          title,
          style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  color: Colors.white,
                  letterSpacing: .5,
                  fontWeight: FontWeight.w500,
                  fontSize: 18)),
        )
      ],
    );
  }
}
