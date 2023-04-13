import 'dart:convert';
import 'dart:io';

import 'package:bbp/common/mybaisedbutton.dart';
import 'package:bbp/common/mytextfield.dart';
import 'package:bbp/utils/app_colors.dart';
import 'package:bbp/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';

import 'package:flutter_picker/flutter_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddBusinessScreen extends StatefulWidget {
  @override
  _AddBusinessScreenState createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String?> category = [];
  List categoryList = [];
  //Declartion
  final bsNameTextController = TextEditingController();
  final categoryTextController = TextEditingController();
  final opreatingHoursTextController = TextEditingController();
  final phoneTextController = TextEditingController();
  final addressTextController = TextEditingController();
  final descriptionTextController = TextEditingController();
  final websiteController = TextEditingController();
  final emailTextController = TextEditingController();
  final fbTextController = TextEditingController();
  final instagramTextController = TextEditingController();
  final hourseTextController = TextEditingController();
  final websiteTextController = TextEditingController();

  String? _catId;
  File? _image;
  final picker = ImagePicker();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getCategory();
  }

  Future getImage() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        _image = File(pickedFile!.path);
      });
    } catch (e) {
      //  showMessage(e.toString?(), Colors.red, Icons.add);
    }
  }

  addBusiness(String businessName, String category, String hours, String phone, String address, String description, String website, String email, String fbUrl, String instagramUrl, File file) async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {'era-token': prefs.getString("token") ?? ''};
    var jsonData = null;
    var request = http.MultipartRequest('POST', Uri.parse('${Constants.BASE_URL}/business/createBusiness/create_business'));
    request.headers.addAll(requestHeaders);
    request.fields["business_name"] = businessName;
    request.fields["operating_hours"] = hours;
    request.fields["phone"] = phone;
    request.fields["address"] = address;
    request.fields["description"] = description;
    request.fields["website"] = websiteTextController.text;
    request.fields["email"] = email;
    request.fields["facebook_url"] = fbUrl;
    request.fields["instagram_url"] = instagramUrl;
    request.fields["cat_id"] = _catId!;

    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath('business_img', file.path));
    }
    var res = await request.send();
    print(res.statusCode);
    if (res.statusCode == 200) {
      print('business add');
      res.stream.transform(utf8.decoder).listen((value) {
        showMessage(json.decode(value)["message"], Colors.red, Icons.error);
        clearText();
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      print(res.statusCode);
      setState(() {
        _isLoading = false;
      });
      showMessage('${res.reasonPhrase}', Colors.red, Icons.error);
    }
  }

  getCategory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {'era-token': prefs.getString("token") ?? ''};
    var jsonData = null;
    var reponse = await http.get(Uri.parse("${Constants.BASE_URL}/user/category/categories"), headers: requestHeaders);
    if (reponse.statusCode == 200) {
      jsonData = json.decode(reponse.body);
      var data = jsonData["data"] as List;
      if (jsonData["status"]) {
        categoryList = data;
        data.forEach((element) {
          category.add(element["name"]);
        });
      } else {}
    } else {
      print(reponse.body);
    }
  }

  showPicker(BuildContext context) {
    Picker picker = Picker(
        adapter: PickerDataAdapter<String>(pickerData: category),
        // changeToFirst: true,
        textAlign: TextAlign.center,
        columnPadding: const EdgeInsets.all(8.0),
        onConfirm: (Picker picker, List value) {
          categoryTextController.text = picker.getSelectedValues().first;
          categoryTextController.text = picker.getSelectedValues().first;
          categoryList.forEach((element) {
            if (element["name"] == picker.getSelectedValues().first) {
              setState(() {
                _catId = element["cat_id"].toString();
              });
            }
          });
        });
    picker.show(_scaffoldKey.currentState!);
  }

  checkValidation() {
    if (bsNameTextController.text == null || bsNameTextController.text.isEmpty || bsNameTextController.text == "") {
      showMessage("Please enter business name", Colors.red, Icons.close);
      return false;
    } else {
      if (categoryTextController.text == null || categoryTextController.text.isEmpty || categoryTextController.text == "") {
        showMessage("Please select category", Colors.red, Icons.close);
        return false;
      } else {
        if (hourseTextController.text == null || hourseTextController.text.isEmpty || hourseTextController.text == "") {
          showMessage("Please enter operating hours", Colors.red, Icons.close);
          return false;
        } else {
          if (phoneTextController.text == null || phoneTextController.text.isEmpty || phoneTextController.text == "") {
            showMessage("Please enter phone number", Colors.red, Icons.close);
            return false;
          } else {
            if (addressTextController.text == null || addressTextController.text.isEmpty || addressTextController.text == "") {
              showMessage("Please enter address", Colors.red, Icons.close);
              return false;
            } else {
              if (descriptionTextController.text == null || descriptionTextController.text.isEmpty || descriptionTextController.text == "") {
                showMessage("Please enter description", Colors.red, Icons.close);
                return false;
              } else {
                if (emailTextController.text == null || emailTextController.text.isEmpty || emailTextController.text == "") {
                  showMessage("Please enter email", Colors.red, Icons.close);
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

  showMessage(String? message, Color color, IconData iconData) {
    Fluttertoast.showToast(msg: message!, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.black, textColor: Colors.white, fontSize: 16.0);
  }

  clearText() {
    bsNameTextController.clear();
    categoryTextController.clear();
    opreatingHoursTextController.clear();
    phoneTextController.clear();
    addressTextController.clear();
    descriptionTextController.clear();
    websiteController.clear();
    emailTextController.clear();
    fbTextController.clear();
    instagramTextController.clear();
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
            "Add Business",
            style: GoogleFonts.poppins(textStyle: const TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 22)),
          ),
          backgroundColor: Colors.white,
          elevation: 2.0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: _isLoading
            ? const Center(
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
                        const SizedBox(
                          height: 30,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: bsNameTextController,
                          placeholder: "Business Name",
                          leftIcon: Icons.business,
                          obscureText: false,
                          onChanged: (text) => bsNameTextController.text = text,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: width * 0.85,
                          height: height <= 667.0 ? height * 0.07 : height * 0.06,
                          child: TextField(
                            onTap: () {
                              showPicker(context);
                            },
                            controller: categoryTextController,
                            cursorColor: Colors.black,
                            readOnly: true,
                            decoration: new InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                prefixIcon: Icon(
                                  Icons.category,
                                  size: height <= 667.0 ? 23 : 25,
                                ),
                                border: new OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(25.0),
                                  ),
                                ),
                                filled: true,
                                hintStyle: new TextStyle(color: Colors.grey[800]),
                                hintText: 'Category',
                                isDense: true,
                                fillColor: Colors.white70),
                            style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: height <= 667.0 ? 14 : 16)),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: hourseTextController,
                          placeholder: "Operating Hours",
                          leftIcon: FontAwesome5.clock,
                          obscureText: false,
                          onChanged: (text) => hourseTextController.text = text,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: phoneTextController,
                          placeholder: "Phone",
                          leftIcon: Icons.phone,
                          obscureText: false,
                          onChanged: (text) => phoneTextController.text = text,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: addressTextController,
                          placeholder: "Address",
                          leftIcon: Entypo.address,
                          obscureText: false,
                          onChanged: (text) => addressTextController.text = text,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: descriptionTextController,
                          placeholder: "Description",
                          leftIcon: Icons.description,
                          obscureText: false,
                          onChanged: (text) => descriptionTextController.text = text,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: websiteTextController,
                          placeholder: "Website",
                          leftIcon: MaterialIcons.public,
                          obscureText: false,
                          onChanged: (text) => websiteTextController.text = text,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: emailTextController,
                          placeholder: "Email",
                          leftIcon: Icons.email,
                          obscureText: false,
                          onChanged: (text) => emailTextController.text = text,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: fbTextController,
                          placeholder: "Facebook URL",
                          leftIcon: Entypo.facebook,
                          obscureText: false,
                          onChanged: (text) => fbTextController.text = text,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        MyTextField(
                          onTap: () {},
                          textController: instagramTextController,
                          placeholder: "Instagram URL",
                          leftIcon: Entypo.instagram,
                          obscureText: false,
                          onChanged: (text) => instagramTextController.text = text,
                        ),
                        const SizedBox(
                          height: 20,
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
                        const SizedBox(height: 20),
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
                                addBusiness(
                                  bsNameTextController.text,
                                  categoryTextController.text,
                                  hourseTextController.text,
                                  phoneTextController.text,
                                  addressTextController.text,
                                  descriptionTextController.text,
                                  websiteTextController.text,
                                  emailTextController.text,
                                  fbTextController.text,
                                  instagramTextController.text,
                                  _image!,
                                );
                              }
                            },
                            child: Text(
                              "Submit".toUpperCase(),
                              style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.white, letterSpacing: .5, fontSize: height <= 667.0 ? 16 : 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ));
  }
}
