class ApiAuth {
  String token;
  String cookie;
  String sessionId;

  ApiAuth({this.token, this.cookie, this.sessionId});

  ApiAuth.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    cookie = json['cookie'];
    sessionId = json['sessionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['cookie'] = this.cookie;
    data['sessionId'] = this.sessionId;
    return data;
  }
}
