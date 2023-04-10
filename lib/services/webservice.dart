import 'dart:async';
import 'dart:convert';
import 'package:bbp/model/login.dart';
import 'package:http/http.dart' as http;
// import 'package:news_app/models/news_articles.dart';
// import 'package:news_app/utils/constant.dart';

class Webservice {
  final _baseUrl = 'http://localhost/bbp_admin_panel_api/era';

  http.Client _client = http.Client();

  set client(http.Client value) => _client = value;

  static final Webservice _internal = Webservice.internal();
  factory Webservice() => _internal;
  Webservice.internal();

  Future<Login> getLogin() async {
    var response = await _client.get(Uri.parse('$_baseUrl/user/login/user_login'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      // List<dynamic> planetsData = data['results'];
      // List<Planet> planets = planetsData.map((p) => Planet.fromMap(p)).toList();

      print(data);
      Login login = Login(statue: null, message: null, data: data);

      return login;
    } else {
      throw Exception('Failed to get data');
    }
  }
}
