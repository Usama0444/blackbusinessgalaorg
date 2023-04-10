import 'dart:convert';

import 'package:bbp/utils/MapUtils.dart';
import 'package:bbp/utils/app_colors.dart';
import 'package:bbp/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchScreen extends StatefulWidget {
  final String searchText;

  SearchScreen(this.searchText, {Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  List searchBusinessList = [];
  String businessRating = "0";

  @override
  void initState() {
    super.initState();
    getBusiness(widget.searchText);
  }

  showMessage(String message, Color color, IconData iconData) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.black, textColor: Colors.white, fontSize: 16.0);
  }

  getBusiness(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("token") != null) {
      setState(() {
        _isLoggedIn = true;
      });
    }
    setState(() {
      _isLoading = true;
    });
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position.latitude.toString());
    Map<String, String> data = {"cat": "", "lat": position.latitude.toString(), "lng": position.longitude.toString(), "name": search};
    var jsonData = null;
    var reponse = await http.post(Uri.parse("${Constants.BASE_URL}/business/getBusiness/business"), body: json.encode(data));
    if (reponse.statusCode == 200) {
      jsonData = json.decode(reponse.body);
      var data = jsonData["data"];
      if (jsonData["status"]) {
        // showMessage(jsonData["message"], Colors.red, Icons.error);
        searchBusinessList = data;
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
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
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                        child: Image.network(business["business_img"], width: width, height: height * 0.25, fit: BoxFit.fill),
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                        width: width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(business["business_name"],
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 24, fontWeight: FontWeight.bold))),
                            Row(
                              children: [
                                Text(business["cat_name"], style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 16, fontWeight: FontWeight.w400))),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.star,
                                  size: 18,
                                  color: AppColors.gold,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(businessRating, style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 16, fontWeight: FontWeight.w400))),
                                SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                          ],
                        )),
                    Container(
                        width: width,
                        padding: EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            SizedBox(
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
                                    : Center(),
                                SizedBox(
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
                                    : Center(),
                                SizedBox(
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
                                    : Center(),
                                SizedBox(
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
                                    : Center(),
                                SizedBox(
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
                                    : Center(),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(business["description"], style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.grey, letterSpacing: .5, fontSize: 15, fontWeight: FontWeight.w500))),
                            SizedBox(
                              height: 5,
                            ),
                            RatingBar.builder(
                              initialRating: 3,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
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
                            SizedBox(
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
                                        side: BorderSide(color: AppColors.gold, width: 2),
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
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  width: width * 0.35,
                                  height: height <= 667.0 ? height * 0.06 : height * 0.05,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        side: BorderSide(color: AppColors.gold, width: 2),
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

    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Search Results",
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
          : searchBusinessList.isEmpty
              ? Center(
                  child: Text(
                    "No business available",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 26, fontWeight: FontWeight.w500),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  itemCount: searchBusinessList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10, top: 0),
                      child: GestureDetector(
                        onTap: () => showModalSheet(context, searchBusinessList[index]),
                        child: CategoryWidget(
                          width: width,
                          business: searchBusinessList[index],
                          isLoggedIn: _isLoggedIn,
                        ),
                      ),
                    );
                  }),
    );
  }
}

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({Key? key, required this.width, required this.business, required this.isLoggedIn}) : super(key: key);

  final double width;
  final Map<String, dynamic> business;
  final bool isLoggedIn;
  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  bool _isFavorite = false;

  showMessage(String message, Color color, IconData iconData) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.black, textColor: Colors.white, fontSize: 16.0);
  }

  addFavorite(String businessId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {'era-token': prefs.getString("token") ?? ''};
    Map<String, String> data = {"id": businessId};
    var jsonData = null;
    var reponse = await http.post(Uri.parse("${Constants.BASE_URL}/user/Favoriteunfavorite/add_to_favorite"), body: json.encode(data), headers: requestHeaders);
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

  removeFavorite(String businessId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {'era-token': prefs.getString("token") ?? ''};
    Map<String, String> data = {"id": businessId};
    var jsonData = null;
    var reponse = await http.post(Uri.parse("${Constants.BASE_URL}/user/Favoriteunfavorite/remove_to_favorite"), body: json.encode(data), headers: requestHeaders);
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

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(widget.business["business_img"], width: widget.width * 0.25, height: widget.width * 0.25, fit: BoxFit.cover),
                  )),
              Container(
                  width: widget.width * 0.56,
                  height: widget.width * 0.25,
                  padding: EdgeInsets.only(bottom: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(widget.business["business_name"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 16, fontWeight: FontWeight.w600))),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 20,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(widget.business["description"],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.grey, letterSpacing: .5, fontSize: 13, fontWeight: FontWeight.w500))),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.star,
                            size: 20,
                            color: AppColors.gold,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text("${widget.business["rating"]}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.grey, letterSpacing: .5, fontSize: 13, fontWeight: FontWeight.w500))),
                          ),
                          Expanded(
                            child: Text("${double.parse(widget.business["distance"].toStringAsFixed(2))} Mi",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.grey, letterSpacing: .5, fontSize: 13, fontWeight: FontWeight.w500))),
                          ),
                          InkWell(
                            onTap: () {
                              if (widget.isLoggedIn) {
                                setState(() {
                                  _isFavorite = !_isFavorite;
                                });
                                _isFavorite ? addFavorite(widget.business["busii_id"]) : removeFavorite(widget.business["busii_id"]);
                              } else {
                                showMessage("please login to access this feature", Colors.red, Icons.receipt);
                              }
                            },
                            child: Icon(
                              _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                              size: 30,
                              color: AppColors.gold,
                            ),
                          )
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        ));
  }
}
