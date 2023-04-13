import 'dart:convert';
import 'dart:io';

import 'package:bbp/common/mybaisedbutton.dart';
import 'package:bbp/common/mytextfield.dart';
import 'package:bbp/utils/app_colors.dart';
import 'package:bbp/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeatureScreen extends StatefulWidget {
  @override
  _FeatureScreenState createState() => _FeatureScreenState();
}

class _FeatureScreenState extends State<FeatureScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //Declartion
  final contactNameTextController = TextEditingController();
  final companyTitleTextController = TextEditingController();
  final contactPhoneTextController = TextEditingController();
  final contactEmailTextController = TextEditingController();
  final businessNameTextController = TextEditingController();
  final businessPhoneTextController = TextEditingController();
  final businessEmailTextController = TextEditingController();
  final businessAddressTextController = TextEditingController();

  File? _image;
  final picker = ImagePicker();

  bool _isLoading = false;

  Future getImage() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        _image = File(pickedFile!.path);
      });
    } catch (e) {
      //  showMessage(e.toString(), Colors.red, Icons.add);
    }
  }

  businessInquiry(
      String contactName, String companyTitle, String contactPhone, String contactEmail, String businessName, String businessPhone, String businessEmail, String businessAddress, File file) async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {'era-token': prefs.getString("token") ?? ''};
    var jsonData = null;
    var request = http.MultipartRequest('POST', Uri.parse('${Constants.BASE_URL}/business/BusinessInquiry/create_business_inquiry'));
    request.headers.addAll(requestHeaders);
    request.fields["inq_person"] = contactName;
    request.fields["inq_busi_title"] = companyTitle;
    request.fields["inq_per_phone"] = contactPhone;
    request.fields["inq_person_email"] = contactEmail;
    request.fields["inq_busi_name"] = businessName;
    request.fields["inq_busi_phone"] = businessPhone;
    request.fields["inq_busi_email"] = businessEmail;
    request.fields["inq_busi_add"] = businessAddress;

    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath('inq_busi_logo', file.path));
    }
    var res = await request.send();
    print(res.statusCode);
    if (res.statusCode == 200) {
      res.stream.transform(utf8.decoder).listen((value) {
        showMessage(json.decode(value)["message"], Colors.red, Icons.error);
        clearText();
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      print(res.statusCode);
      showMessage(res.reasonPhrase.toString(), Colors.red, Icons.error);
    }
  }

  checkValidation() {
    if (contactNameTextController.text == null || contactNameTextController.text.isEmpty || contactNameTextController.text == "") {
      showMessage("Please enter contact person name", Colors.red, Icons.close);
      return false;
    } else {
      if (companyTitleTextController.text == null || companyTitleTextController.text.isEmpty || companyTitleTextController.text == "") {
        showMessage("Please enter title with the company", Colors.red, Icons.close);
        return false;
      } else {
        if (contactPhoneTextController.text == null || contactPhoneTextController.text.isEmpty || contactPhoneTextController.text == "") {
          showMessage("Please enter contact phone", Colors.red, Icons.close);
          return false;
        } else {
          if (contactEmailTextController.text == null || contactEmailTextController.text.isEmpty || contactEmailTextController.text == "") {
            showMessage("Please enter contact email", Colors.red, Icons.close);
            return false;
          } else {
            if (businessNameTextController.text == null || businessNameTextController.text.isEmpty || businessNameTextController.text == "") {
              showMessage("Please enter business name", Colors.red, Icons.close);
              return false;
            } else {
              if (businessPhoneTextController.text == null || businessPhoneTextController.text.isEmpty || businessPhoneTextController.text == "") {
                showMessage("Please enter business phone", Colors.red, Icons.close);
                return false;
              } else {
                if (businessEmailTextController.text == null || businessEmailTextController.text.isEmpty || businessEmailTextController.text == "") {
                  showMessage("Please enter business email", Colors.red, Icons.close);
                  return false;
                } else {
                  if (businessAddressTextController.text == null || businessAddressTextController.text.isEmpty || businessAddressTextController.text == "") {
                    showMessage("Please enter business address", Colors.red, Icons.close);
                    return false;
                  } else {
                    if (_image == null) {
                      showMessage("Please select the image", Colors.red, Icons.close);
                      return false;
                    } else {
                      return true;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  showMessage(String message, Color color, IconData iconData) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.black, textColor: Colors.white, fontSize: 16.0);
  }

  clearText() {
    contactNameTextController.clear();
    companyTitleTextController.clear();
    contactPhoneTextController.clear();
    contactEmailTextController.clear();
    businessNameTextController.clear();
    businessPhoneTextController.clear();
    businessEmailTextController.clear();
    businessAddressTextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        key: _scaffoldKey,
        // backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Get featured",
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
            : Container(
                width: width,
                height: height,
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: contactNameTextController,
                          placeholder: "Contant Person Name",
                          leftIcon: Icons.person,
                          obscureText: false,
                          onChanged: (text) => contactNameTextController.text = text,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: companyTitleTextController,
                          placeholder: "Title with the company",
                          leftIcon: Icons.business,
                          obscureText: false,
                          onChanged: (text) => companyTitleTextController.text = text,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: contactPhoneTextController,
                          placeholder: "Contact Phone",
                          leftIcon: Icons.phone,
                          obscureText: false,
                          onChanged: (text) => contactPhoneTextController.text = text,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: contactEmailTextController,
                          placeholder: "Contact email",
                          leftIcon: Entypo.mail,
                          obscureText: false,
                          onChanged: (text) => contactEmailTextController.text = text,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: businessNameTextController,
                          placeholder: "Business name",
                          leftIcon: Icons.business_center,
                          obscureText: false,
                          onChanged: (text) => businessNameTextController.text = text,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: businessPhoneTextController,
                          placeholder: "Business phone",
                          leftIcon: MaterialIcons.phone,
                          obscureText: false,
                          onChanged: (text) => businessPhoneTextController.text = text,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: businessEmailTextController,
                          placeholder: "Business email",
                          leftIcon: Icons.email,
                          obscureText: false,
                          onChanged: (text) => businessEmailTextController.text = text,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: businessAddressTextController,
                          placeholder: "Business address",
                          leftIcon: Entypo.address,
                          obscureText: false,
                          onChanged: (text) => businessAddressTextController.text = text,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        InkWell(
                          onTap: () {
                            getImage();
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: _image == null
                                ? Image.network(
                                    "https://cdn.onlinewebfonts.com/svg/img_234957.png",
                                    width: width * 0.25,
                                    height: width * 0.25,
                                    fit: BoxFit.fill,
                                  )
                                : Image.file(
                                    _image!,
                                    width: width * 0.25,
                                    height: width * 0.25,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: width * 0.85,
                          height: height <= 667.0 ? height * 0.07 : height * 0.06,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: const BorderSide(color: Colors.black, width: 0),
                              ),
                              backgroundColor: Colors.black,
                            ),
                            onPressed: () {
                              if (checkValidation()) {
                                businessInquiry(contactNameTextController.text, companyTitleTextController.text, contactPhoneTextController.text, contactEmailTextController.text,
                                    businessNameTextController.text, businessPhoneTextController.text, businessEmailTextController.text, businessAddressTextController.text, _image!);
                              }
                            },
                            child: Text(
                              "Submit".toUpperCase(),
                              style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.white, letterSpacing: .5, fontSize: height <= 667.0 ? 16 : 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ));
  }
}
