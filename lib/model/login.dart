class Login {
  bool? statue;
  String? message;
  Data? data;

  Login({required this.statue, required this.message, required this.data});

  Login.fromMap(Map<String, dynamic> map) {
    statue = map['statue'];
    message = map['message'];
    data = map['data'];
  }
}

class Data {
  String? id, name, username, proImage, usermail, eraToken;

  Data({
    required this.id,
    required this.name,
    required this.username,
    required this.usermail,
    required this.proImage,
    required this.eraToken,
  });

  Data.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    username = map['username'];
    usermail = map['usermail'];
    proImage = map['proImage'];
    eraToken = map['eraToken'];
  }
}
