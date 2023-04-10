import 'package:bbp/utils/app_colors.dart';
import 'package:bbp/view/drawer/drawer_screen.dart';
import 'package:bbp/view/home/home_screen.dart';
import 'package:bbp/view/signup/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    _checkIfLoggedIn();
    super.initState();
  }

  _checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("token") != null) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: AppColors.primartColor,
        primaryColorLight: AppColors.primaryColorLight,
        primaryColorDark: AppColors.primaryColorDark,
        primarySwatch: Colors.grey,
      ),
      home: Scaffold(
        body: _isLoggedIn
            ? Stack(
                children: [DrawerScreen(), HomeScreen()],
              )
            : SignupScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
