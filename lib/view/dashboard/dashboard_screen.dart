import 'package:bbp/view/drawer/drawer_screen.dart';
import 'package:bbp/view/home/home_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            DrawerScreen(),
            HomeScreen()
          ],
        ),
    );
  }
}
