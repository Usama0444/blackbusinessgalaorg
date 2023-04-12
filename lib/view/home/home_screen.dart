import 'dart:convert';

import 'package:bbp/utils/MapUtils.dart';
import 'package:bbp/utils/app_colors.dart';
import 'package:bbp/utils/constant.dart';
import 'package:bbp/view/addBusiness/addbusiness_screen.dart';
import 'package:bbp/view/category/category_screen.dart';
import 'package:bbp/view/getFeature/feature_screen.dart';
import 'package:bbp/view/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  double xOffset = 0.0;

  double yOffset = 0.0;

  double scaleFactor = 1;
  bool isDrawerOpen = false;

  List categoryList = [];
  List topBusinessList = [];

  String businessRating = "0";

  final searchTextController = TextEditingController();

  String _search = '';

  @override
  void initState() {
    super.initState();
    getFeatureBusiness();
    getCategory();
    // ;
  }

  showMessage(String message, Color color, IconData iconData) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.black, textColor: Colors.white, fontSize: 16.0);
  }

  getCategory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("token") != null) {
      setState(() {
        _isLoggedIn = true;
      });
    }
    setState(() {
      _isLoading = true;
    });
    Map<String, String> requestHeaders = {'era-token': prefs.getString("token") ?? ''};
    var jsonData = null;
    var reponse = await http.get(Uri.parse("${Constants.BASE_URL}/user/category/categories"), headers: requestHeaders);
    if (reponse.statusCode == 200) {
      jsonData = json.decode(reponse.body);
      var data = jsonData["data"];
      if (jsonData["status"]) {
        categoryList = data as List;
        showMessage(jsonData["message"], Colors.green, Icons.done);
        // print(data["era_tnk"] + "-----" + data["pro_img"] + "-----" + data["name"] + "-----" + data["id"]);
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

  getFeatureBusiness() async {
    // Position position = await Geolocator()
    //     .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {'era-token': prefs.getString("token") ?? ''};
    Map<String, String> data = {"lat": "21.9612", "lng": "70.7939"};
    var jsonData = null;
    var reponse = await http.post(Uri.parse("${Constants.BASE_URL}/business/VIPBusiness/vip_business"), body: data, headers: requestHeaders);
    if (reponse.statusCode == 200) {
      print(json.decode(reponse.body));
      jsonData = json.decode(reponse.body);
      var data = jsonData["data"];
      if (jsonData["status"]) {
        topBusinessList = data as List;
        // showMessage(jsonData["=======><><><>message"], Colors.green, Icons.done);
        //       // print(data["era_tnk"] + "-----" + data["pro_img"] + "-----" + data["name"] + "-----" + data["id"]);
      } else {
        showMessage(jsonData["message"], Colors.red, Icons.error);
      }
    } else {
      //   print(reponse.body);
    }
  }

  //Rate Business
  rateBusiness(String businessId, String rating) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {'era-token': prefs.getString("token") ?? ''};
    Map<String, String> data = {"busi": businessId, "rating": rating};
    var jsonData = null;
    var reponse = await http.post(Uri.parse("${Constants.BASE_URL}/business/giveRating/give_rating"), body: json.encode(data), headers: requestHeaders);
    if (reponse.statusCode == 200) {
      jsonData = json.decode(reponse.body);
      var data = jsonData["data"];
      if (jsonData["status"]) {
        showMessage(jsonData["message"], Colors.green, Icons.done);
      } else {
        showMessage(jsonData["message"], Colors.red, Icons.error);
      }
    } else {
      print(reponse.body);
    }
  }

  void showModalSheet(BuildContext context, Map<String, dynamic> business) {
    setState(() {
      businessRating = business["rating"].toString();
    });
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        clipBehavior: Clip.hardEdge,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          var width = MediaQuery.of(context).size.width;
          var height = MediaQuery.of(context).size.height;
          return new Container(
              height: height * 0.7,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                color: Colors.grey[100],
              ),
              // width: double.infinity,
              child: SingleChildScrollView(
                  child: Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      width: width,
                      height: height * 0.25,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                        child: Image.network(business["business_img"], width: width, height: height * 0.25, fit: BoxFit.fill),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                        width: width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(business["business_name"],
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(textStyle: const TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 24, fontWeight: FontWeight.bold))),
                            Row(
                              children: [
                                Text(business["cat_name"], style: GoogleFonts.poppins(textStyle: const TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 16, fontWeight: FontWeight.w400))),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Icon(
                                  Icons.star,
                                  size: 18,
                                  color: AppColors.gold,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(businessRating, style: GoogleFonts.poppins(textStyle: const TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 16, fontWeight: FontWeight.w400))),
                                const SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                          ],
                        )),
                    Container(
                        width: width,
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                business["phone"] != ""
                                    ? Container(
                                        width: width * 0.12,
                                        height: width * 0.12,
                                        child: FloatingActionButton(
                                          backgroundColor: Colors.white,
                                          child: Image.asset("assets/images/phone.png", width: width * 0.07, height: width * 0.07, fit: BoxFit.contain),
                                          onPressed: () {
                                            launch("tel:${business["phone"]}");
                                          },
                                        ),
                                      )
                                    : const Center(),
                                const SizedBox(
                                  width: 20,
                                ),
                                business["email"] != ""
                                    ? Container(
                                        width: width * 0.12,
                                        height: width * 0.12,
                                        child: FloatingActionButton(
                                          backgroundColor: Colors.white,
                                          child: Image.asset("assets/images/gmail.png", width: width * 0.07, height: width * 0.07, fit: BoxFit.contain),
                                          onPressed: () {
                                            launch("mailto:${business["email"]}");
                                          },
                                        ),
                                      )
                                    : const Center(),
                                const SizedBox(
                                  width: 20,
                                ),
                                business["website"] != ""
                                    ? Container(
                                        width: width * 0.12,
                                        height: width * 0.12,
                                        child: FloatingActionButton(
                                          backgroundColor: Colors.white,
                                          child: Image.asset("assets/images/www.png", width: width * 0.07, height: width * 0.07, fit: BoxFit.contain),
                                          onPressed: () {
                                            launch("${business["website"]}");
                                          },
                                        ),
                                      )
                                    : const Center(),
                                const SizedBox(
                                  width: 20,
                                ),
                                business["facebook_url"] != ""
                                    ? Container(
                                        width: width * 0.12,
                                        height: width * 0.12,
                                        child: FloatingActionButton(
                                          backgroundColor: Colors.white,
                                          child: Image.asset("assets/images/facebook.png", width: width * 0.07, height: width * 0.07, fit: BoxFit.contain),
                                          onPressed: () {
                                            launch("${business["facebook_url"]}");
                                          },
                                        ),
                                      )
                                    : const Center(),
                                const SizedBox(
                                  width: 20,
                                ),
                                business["instagram_url"] != ""
                                    ? Container(
                                        width: width * 0.12,
                                        height: width * 0.12,
                                        child: FloatingActionButton(
                                          backgroundColor: Colors.white,
                                          child: Image.asset("assets/images/instagram.png", width: width * 0.07, height: width * 0.07, fit: BoxFit.contain),
                                          onPressed: () {
                                            launch("${business["instagram_url"]}");
                                          },
                                        ),
                                      )
                                    : const Center(),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Text(business["description"], style: GoogleFonts.poppins(textStyle: const TextStyle(color: Colors.grey, letterSpacing: .5, fontSize: 15, fontWeight: FontWeight.w500))),
                            const SizedBox(
                              height: 5,
                            ),
                            RatingBar.builder(
                              initialRating: 3,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  businessRating = rating.toString();
                                });
                                print(rating);
                              },
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: width * 0.35,
                                  height: height <= 667.0 ? height * 0.06 : height * 0.05,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        side: const BorderSide(color: AppColors.gold, width: 2),
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      _isLoggedIn ? rateBusiness(business["busii_id"], businessRating) : showMessage("please login to access this feature", Colors.red, Icons.receipt);
                                    },
                                    child: Text(
                                      "Rate",
                                      style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: height <= 667.0 ? 18 : 18, fontWeight: FontWeight.w400)),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  width: width * 0.35,
                                  height: height <= 667.0 ? height * 0.06 : height * 0.05,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        side: const BorderSide(color: AppColors.gold, width: 2),
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      MapUtils.openMap(double.parse(business["lat"]), double.parse(business["lng"]));
                                    },
                                    child: Text(
                                      "Directions",
                                      style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: height <= 667.0 ? 18 : 18, fontWeight: FontWeight.w400)),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        )),
                  ],
                ),
              )));
        });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return AnimatedContainer(
      height: double.infinity,
      transform: Matrix4.translationValues(xOffset, yOffset, 0)
        ..scale(scaleFactor)
        ..rotateY(isDrawerOpen ? -0.5 : 0.0),
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(isDrawerOpen ? 40.0 : 0.0)),
      // color: Colors.white,
      child: Column(
        children: [
          const SizedBox(
            height: 22,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isDrawerOpen
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 35,
                        ),
                        onPressed: () {
                          setState(() {
                            xOffset = 0.0;
                            yOffset = 0.0;
                            scaleFactor = 1;
                            isDrawerOpen = false;
                          });
                        })
                    : IconButton(
                        icon: const Icon(
                          Icons.menu,
                          size: 35,
                        ),
                        onPressed: () {
                          setState(() {
                            xOffset = 230;
                            yOffset = 150;
                            scaleFactor = 0.6;
                            isDrawerOpen = true;
                          });
                        }),
                Image.asset(
                  "assets/images/applogo.png",
                  width: width * 0.5,
                  height: height * 0.15,
                  fit: BoxFit.fitHeight,
                ),
                IconButton(
                    icon: const Icon(
                      Icons.add,
                      size: 35,
                    ),
                    onPressed: () {
                      _isLoggedIn
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddBusinessScreen()),
                            )
                          : showMessage("please login to access this feature", Colors.red, Icons.receipt);
                    })
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: height * 0.01),
            // padding: EdgeInsets.all(5),
            width: width * 0.85,
            height: height <= 667.0 ? height * 0.07 : height * 0.06,
            child: TextField(
              // onTap: onTap,
              // enabled: isEnabled,
              // obscureText: obscureText,
              onChanged: (text) => _search = text,
              controller: searchTextController,
              // readOnly: isReadOnly == null ? false : true,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                searchTextController.text = "";
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchScreen(value),
                    ));
              },
              cursorColor: Colors.black,
              decoration: new InputDecoration(
                filled: true,
                fillColor: const Color(0xffDCDCDC),
                contentPadding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                prefixIcon: Icon(
                  Icons.search,
                  size: height <= 667.0 ? 23 : 25,
                ),
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(25.0),
                  ),
                  borderSide: const BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
                hintStyle: new TextStyle(color: Colors.grey[800]),
                hintText: "Search",
                isDense: true,
              ),
              style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: height <= 667.0 ? 14 : 16)),
            ),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.black,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                )
              : Expanded(
                  child: SingleChildScrollView(
                      child: Padding(
                  padding: const EdgeInsets.only(left: 15, top: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        child: Text(
                          "Discover",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(textStyle: const TextStyle(color: Colors.black, letterSpacing: .5, fontWeight: FontWeight.w600, fontSize: 24)),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        height: height * 0.30,
                        // color: Colors.red,
                        child: ListView.builder(
                            itemCount: categoryList.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Card(
                                      semanticContainer: true,
                                      color: Colors.transparent,
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      elevation: 1,
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => CategoryScreen(categoryList[index])),
                                            );
                                          },
                                          child: Hero(
                                            tag: categoryList[index],
                                            child: Container(
                                              width: height * 0.30,
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                image: NetworkImage(categoryList[index]["image"]),
                                                fit: BoxFit.cover,
                                              )),
                                              child: Container(
                                                width: height * 0.30,
                                                color: Colors.black.withOpacity(0.3),
                                                child: Stack(
                                                  children: [
                                                    Positioned(
                                                      top: 10,
                                                      right: 10,
                                                      child: new Text(categoryList[index]["name"],
                                                          style: GoogleFonts.poppins(textStyle: const TextStyle(color: Colors.white, letterSpacing: .5, fontWeight: FontWeight.w600, fontSize: 22))),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ))));
                            }),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        width: double.infinity,
                        child: Text(
                          "Featured Businesses",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(textStyle: const TextStyle(color: Colors.black, letterSpacing: .5, fontWeight: FontWeight.w600, fontSize: 24)),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        height: height <= 667 ? height * 0.2 : height * 0.19,
                        // color: Colors.red,
                        child: ListView.builder(
                            itemCount: topBusinessList.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  showModalSheet(context, topBusinessList[index]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Container(
                                      width: height * 0.25,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: height * 0.25,
                                            height: height * 0.12,
                                            child: Card(
                                                semanticContainer: true,
                                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20.0),
                                                ),
                                                elevation: 1,
                                                child: Image.network(
                                                  topBusinessList[index]["business_img"],
                                                  fit: BoxFit.fill,
                                                )),
                                          ),
                                          Text(topBusinessList[index]["business_name"],
                                              maxLines: 1,
                                              style: GoogleFonts.poppins(textStyle: const TextStyle(color: Colors.black, letterSpacing: .5, fontWeight: FontWeight.w600, fontSize: 18)),
                                              textAlign: TextAlign.center),
                                          Text(topBusinessList[index]["cat_name"],
                                              style: GoogleFonts.poppins(textStyle: const TextStyle(color: Colors.black, letterSpacing: .5, fontWeight: FontWeight.w300, fontSize: 16)))
                                        ],
                                      )),
                                ),
                              );
                            }),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
                          child: InkWell(
                            onTap: () {
                              _isLoggedIn
                                  ? Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => FeatureScreen()),
                                    )
                                  : showMessage("please login to access this feature", Colors.red, Icons.receipt);
                            },
                            child: Card(
                                semanticContainer: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                elevation: 1,
                                child: Image.network(
                                  "http://app.blackbusinesspensacola.org/bbp_asset/images/gf.jpg",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: height * 0.18,
                                )),
                          )),
                    ],
                  ),
                )))
        ],
      ),
    );
  }
}
