import 'dart:convert';
import 'dart:io';

import 'package:bbp/common/mybaisedbutton.dart';
import 'package:bbp/common/mytextfield.dart';
import 'package:bbp/utils/app_colors.dart';
import 'package:bbp/utils/constant.dart';
import 'package:bbp/view/signup/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isLoading = false;
  Map<String?, dynamic>? _profile;
  File? _image;
  final nameTextController = TextEditingController();
  final userTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  String? _name;
  String? _username;
  String? _email;
  String? _password;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  _asyncFileUpload(File file, String? name, String? email, String? username, String? password) async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {'era-token': prefs.getString("token") ?? ''};
    var request = http.MultipartRequest('POST', Uri.parse('${Constants.BASE_URL}/user/editProfile/update_profile'));
    request.headers.addAll(requestHeaders);
    request.fields["name"] = name!;
    request.fields["username"] = username!;
    if (password == "" || password!.isEmpty) {
    } else {
      request.fields["password"] = password;
    }
    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath('pro_img', file.path));
    }
    var res = await request.send();
    print(res.statusCode);
    if (res.statusCode == 200) {
      res.stream.transform(utf8.decoder).listen((value) {
        showMessage(json.decode(value)["message"], Colors.red, Icons.error);
      });
      setState(() {
        _isLoading = false;
      });
    } else {
      // print(reponse.body);
    }
  }

  showMessage(String message, Color color, IconData iconData) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.black, textColor: Colors.white, fontSize: 16.0);
  }

  getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {'era-token': prefs.getString("token") ?? ''};
    var jsonData = null;
    var reponse = await http.get(Uri.parse("${Constants.BASE_URL}/user/profile/profile"), headers: requestHeaders);
    if (reponse.statusCode == 200) {
      jsonData = json.decode(reponse.body);
      var data = jsonData["data"];
      if (jsonData["status"]) {
        setState(() {
          _profile = data as Map<String?, dynamic>;
        });
        nameTextController.text = data["name"];
        userTextController.text = data["username"];
        emailTextController.text = data["email"];
        // passwordTextController.text = data["password"];
        _username = data["username"];
        _email = data["email"];
        _name = data["name"];
      } else {
        showMessage(jsonData["message"], Colors.red, Icons.error);
      }
    } else {
      print(reponse.body);
    }
  }

  updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {'era-token': prefs.getString("token") ?? ''};
    var jsonData = null;
    var reponse = await http.get(Uri.parse("${Constants.BASE_URL}/user/editProfile/update_profile"), headers: requestHeaders);
    if (reponse.statusCode == 200) {
      jsonData = json.decode(reponse.body);
      var data = jsonData["data"];
      if (jsonData["status"]) {
        setState(() {
          _profile = data as Map<String?, dynamic>;
        });
        nameTextController.text = data["name"];
        userTextController.text = data["username"];
        emailTextController.text = data["email"];
        passwordTextController.text = data["password"];
      } else {
        showMessage(jsonData["message"], Colors.red, Icons.error);
      }
    } else {
      print(reponse.body);
    }
  }

  checkValidation() {
    if (_name == null || _name!.isEmpty || _name == "") {
      showMessage("Please enter name", Colors.red, Icons.close);
      return false;
    } else {
      if (_image == null && _profile!["pro_img"] == "") {
        showMessage("Please select profile image", Colors.red, Icons.close);
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
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 22)),
        ),
        backgroundColor: Colors.white,
        elevation: 2.0,
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
              child: Container(
              height: height * 0.875,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: width * 0.95,
                          height: height <= 667 ? height * 0.65 : height * 0.55,
                          child: Card(
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 85,
                                ),
                                MyTextField(
                                  isEnabled: true,
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
                                  isEnabled: false,
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
                                  isEnabled: false,
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
                                  isEnabled: true,
                                  placeholder: "Password",
                                  leftIcon: Icons.lock,
                                  textController: passwordTextController,
                                  obscureText: true,
                                  onChanged: (text) => _password = text,
                                ),
                                SizedBox(height: 45),
                                MyRaisedButton(
                                  title: "Submit",
                                  isBackground: true,
                                  onPressed: () {
                                    if (checkValidation()) {
                                      if (_password == null || _password == "") {
                                        _asyncFileUpload(_image!, _name, _email, _username, "");
                                      } else {
                                        _asyncFileUpload(_image!, _name, _email, _username, _password);
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                            top: -60,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.gold,
                                  radius: width * 0.15,
                                  child: ClipOval(
                                    child: _image == null
                                        ? _profile!["pro_img"] == ""
                                            ? Image.network("https://cdn0.iconfinder.com/data/icons/social-media-network-4/48/male_avatar-512.png", width: width * 0.28, height: width * 0.28)
                                            : Image.network(
                                                _profile!["pro_img"],
                                                width: width * 0.28,
                                                height: width * 0.28,
                                                fit: BoxFit.cover,
                                              )
                                        : Image.file(
                                            _image!,
                                            width: width * 0.28,
                                            height: width * 0.28,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                Positioned(
                                    bottom: -2.0,
                                    right: 0.0,
                                    child: InkWell(
                                      onTap: () {
                                        getImage();
                                      },
                                      child: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: AppColors.gold,
                                        child: Icon(
                                          Icons.camera_enhance,
                                          color: Colors.white,
                                          size: width * 0.065,
                                        ),
                                      ),
                                    ))
                              ],
                            )),
                      ],
                    )
                  ],
                ),
              ),
            )),
    );
  }
}
