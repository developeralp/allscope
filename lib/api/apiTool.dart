import 'dart:convert';

import 'package:allscope/api/apiService.dart';
import 'package:allscope/db/streamsDb.dart';
import 'package:allscope/interfaces/apiCb.dart';
import 'package:allscope/models/apiSourceData.dart';
import 'package:allscope/ui/toaster.dart';
import 'package:allscope/utils/consts.dart';
import 'package:allscope/utils/networkTool.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiTool {
  ApiCallback apiCallback;
  String langCode;

  void setup(ApiCallback apiCallback, String langCode) async {
    this.langCode = langCode;
    this.apiCallback = apiCallback;
    this.checkNetwork();
  }

  void checkNetwork() async {
    bool network = await NetworkTool.instance.checkNetwork();
    if (network) {
      setupBase();
    } else {
      apiCallback.onNetworkError();
    }
  }

  void setupBase() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString(Consts.apiToken);
    String cookie = sharedPreferences.getString(Consts.apiCookie);
    if (token != null && cookie != null) {
      if (token.isNotEmpty && cookie.isNotEmpty) {
        ApiService().setup(cookie, token);
        testApi(langCode);
      } else {
        getToken();
      }
    } else {
      getToken();
    }
  }

  void testApi(String langCode) async {
    int result = await ApiService().tryTokenAndGetChannels(langCode);
    switch (result) {
      case 200:
        apiCallback.onReady();
        break;

      default:
        getToken();
        break;
    }
  }

  void getToken() async {
    checkApiSource();
  }

  void checkApiSource() async {
    if (!NetworkTool.instance.networkAvailable) return;

    try {
      var response = await http.get(
          '');//API CHOOSE URL
      if (response != null) {
        if (response.statusCode == 200) {
          final responseJson = json.decode(utf8.decode(response.bodyBytes));

          ApiSourceData data = ApiSourceData.fromJson(responseJson);
          if (data != null) {
            if (data.source != null) {
              StreamsDb().apiSource = data.source;
              ApiService().getToken(() {
                getChannels();
              });
            }
          }
        }
      }
    } catch (err) {
      Toaster.show('error_occured');
    }
  }

  void getChannels() async {
    if (apiCallback == null) return;

    int result = await ApiService().tryTokenAndGetChannels(langCode);
    if (result == 200) {
      apiCallback.onReady();
    }
  }
}
