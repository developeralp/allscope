import 'dart:io';

import 'package:allscope/db/streamsDb.dart';
import 'package:allscope/models/apiAuth.dart';
import 'package:allscope/models/apiSource.dart';
import 'package:allscope/models/broadcastList.dart';
import 'package:allscope/models/stream.dart';
import 'package:allscope/models/broadcast.dart';
import 'package:allscope/models/channels.dart';
import 'package:allscope/models/userBroadcasts.dart';
import 'package:allscope/models/userDetails.dart';
import 'package:allscope/ui/toaster.dart';
import 'package:allscope/utils/consts.dart';
import 'package:allscope/utils/networkTool.dart';
import 'package:flutter/cupertino.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService._privateConstructor();

  static final ApiService _instance = ApiService._privateConstructor();

  factory ApiService() {
    return _instance;
  }

  String userAgent =
      "PeriscopeWeb/App-mobile Chrome/58.0.3029.110 (Android;5.0)";
  String apiBase = 'https://proxsee.pscp.tv/api/v2/';
  String channelsBase = 'https://channels.pscp.tv/v1/';

  String cookie;
  String token;
  String sessionId;

  void setup(String cookie, String token) {
    this.cookie = cookie;
    this.token = token;
  }

  Future<void> getToken(Function onDone) async {
    if (onDone == null) return;

    int source = StreamsDb().apiSource;

    if (source == ApiSource.ALPAPPS) {
      await ApiService().getTokenAlpApps((apiAuth) async {
        await ApiService().apiAuthSaver(apiAuth);
        onDone();
      });
    } else if (source == ApiSource.PSCP) {
      await ApiService().getToken((apiAuth) async {
        await ApiService().apiAuthSaver(apiAuth);
        onDone();
      });
    }
  }

  Future<void> getTokenPscp(ValueChanged<ApiAuth> onDone) async {
    if (!NetworkTool.instance.networkAvailable) return;
    if (onDone == null) return;

    try {
      ApiAuth apiAuth;
      var response = await http.get('https://www.pscp.tv');
      if (response.statusCode == 200) {
        var document = parse(response.body);
        if (document != null) {
          var pageContainer = document.getElementById("page-container");
          if (pageContainer != null) {
            var dataStore = pageContainer.attributes['data-store'];

            if (dataStore.isNotEmpty) {
              final dataStoreJson = json.decode(dataStore);

              var token = dataStoreJson['ServiceToken']['channels']['token'];
              var cookie = dataStoreJson['Auth']['csrf'];
              var sessionId = dataStoreJson['SessionToken']['public']
                  ['broadcastHistory']['token']['session_id'];

              if (token != null && cookie != null && sessionId != null) {
                apiAuth = new ApiAuth();
                apiAuth.token = token;
                apiAuth.cookie = cookie;
                apiAuth.sessionId = sessionId;

                this.token = token;
                this.cookie = cookie;
                this.sessionId = sessionId;

                onDone(apiAuth);
              }
            }
          }
        }
      }
    } catch (err) {
      Toaster.show('error_occured');
    }
  }

  Future<void> getTokenAlpApps(ValueChanged<ApiAuth> onDone) async {
    if (!NetworkTool.instance.networkAvailable) return;

    if (onDone == null) return;
    try {
      var response = await http.get('https://www.alpapps.net/api/getpscp.php');

      if (response != null) {
        if (response.statusCode == 200) {
          if (response.body != null) {
            final responseJson = json.decode(utf8.decode(response.bodyBytes));

            ApiAuth apiAuth = ApiAuth.fromJson(responseJson);

            if (apiAuth != null) {
              this.token = apiAuth.token;
              this.cookie = apiAuth.cookie;
              this.sessionId = apiAuth.sessionId;

              onDone(apiAuth);
            }
          }
        }
      }
    } catch (err) {
      Toaster.show('error_occured');
    }
  }

  Future<void> apiAuthSaver(ApiAuth apiAuth) async {
    if (!NetworkTool.instance.networkAvailable) return;
    if (apiAuth == null) return;
    if (apiAuth.token == null) return;
    if (apiAuth.cookie == null) return;
    if (apiAuth.sessionId == null) return;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    await sharedPreferences.setString(Consts.apiCookie, apiAuth.cookie);
    await sharedPreferences.setString(Consts.apiToken, apiAuth.token);
    sessionId = apiAuth.sessionId;
  }

  void checkSessionId(Function onReady) async {
    if (this.sessionId == null) {
      getToken((apiAuth) {
        if (apiAuth != null) {
          apiAuthSaver(apiAuth);
          if (apiAuth.sessionId != null) {
            onReady();
          }
        }
      });
    } else {
      onReady();
    }
  }

  Future<Channels> getTopChannels(String langCode, bool callToken) async {
    if (!NetworkTool.instance.networkAvailable) return null;

    if (cookie == null || token == null) return null;
    if (cookie.isEmpty || token.isEmpty) return null;

    try {
      var response = await http.get(
        channelsBase +
            'top/channels/broadcasts?languages=$langCode&languages=en&languages=es',
        headers: {
          HttpHeaders.authorizationHeader: token,
          HttpHeaders.cookieHeader: cookie,
          'X-Periscope-User-Agent': userAgent,
        },
      );

      if (response != null) {
        if (response.statusCode == 200) {
          if (response.body != null) {
            final responseJson = json.decode(utf8.decode(response.bodyBytes));

            return Channels.fromJson(responseJson);
          }
        } else if (response.statusCode == 401 && callToken) {
          await getToken(() {});
          return await getTopChannels(langCode, false);
        }
      }
    } catch (err) {
      Toaster.show('error_occured');
    }

    return null;
  }

  Future<UserDetails> getUserDetails(String userName, bool callToken) async {
    if (!NetworkTool.instance.networkAvailable) return null;

    if (cookie == null || token == null) return null;
    if (cookie.isEmpty || token.isEmpty) return null;

    try {
      var response = await http
          .get(apiBase + 'getUserPublic?user_name=$userName', headers: {
        HttpHeaders.authorizationHeader: token,
        HttpHeaders.cookieHeader: cookie,
        'X-Periscope-User-Agent': userAgent,
      });

      if (response != null) {
        if (response.statusCode == 200) {
          if (response.body != null) {
            final responseJson = json.decode(utf8.decode(response.bodyBytes));

            return UserDetails.fromJson(responseJson);
          }
        } else if (response.statusCode == 401 && callToken) {
          await getToken(() {});
          return await getUserDetails(userName, false);
        }
      }
    } catch (err) {
      Toaster.show('error_occured');
    }
    return null;
  }

  Future<BroadcastList> getChannelsBroadcasts(
      String channelId, bool callToken) async {
    if (!NetworkTool.instance.networkAvailable) return null;

    if (cookie.isEmpty || token.isEmpty) return null;
    if (channelId.isEmpty) return null;

    try {
      var response = await http
          .get(channelsBase + 'channels/$channelId/broadcasts', headers: {
        HttpHeaders.authorizationHeader: token,
        HttpHeaders.cookieHeader: cookie,
        'X-Periscope-User-Agent': userAgent,
      });

      if (response != null) {
        if (response.statusCode == 200) {
          if (response.body != null) {
            final responseJson = json.decode(response.body);

            return BroadcastList.fromJson(responseJson);
          }
        } else if (response.statusCode == 401 && callToken) {
          await getToken(() {});
          return await getChannelsBroadcasts(channelId, false);
        }
      }
    } catch (err) {
      Toaster.show('error_occured');
    }
    return null;
  }

  Future<List<Broadcast>> getBroadcasts(String ids, bool callToken) async {
    if (!NetworkTool.instance.networkAvailable) return null;

    if (cookie.isEmpty || token.isEmpty) return null;
    if (ids == null) return null;
    if (ids.isEmpty) return null;

    try {
      var response = await http
          .get(apiBase + 'getBroadcastsPublic?broadcast_ids=' + ids, headers: {
        HttpHeaders.authorizationHeader: token,
        HttpHeaders.cookieHeader: cookie,
        'X-Periscope-User-Agent': userAgent,
      });

      if (response != null) {
        if (response.statusCode == 200) {
          if (response.body != null) {
            final responseJson = json.decode(utf8.decode(response.bodyBytes));

            List<Broadcast> broadcasts = (responseJson as List)
                .map((i) => Broadcast.fromJson(i))
                .toList();

            return broadcasts;
          }
        } else if (response.statusCode == 401 && callToken) {
          await getToken(() {});
          return await getBroadcasts(ids, false);
        }
      }
    } catch (err) {
      Toaster.show('error_occured');
    }

    return null;
  }

  Future<List<Broadcast>> searchBroadcasts(
      String search, bool includeReplay, bool callToken) async {
    if (!NetworkTool.instance.networkAvailable) return null;

    if (cookie.isEmpty || token.isEmpty) return null;
    if (search == null) return null;
    if (search.isEmpty) return null;

    try {
      var response = await http.get(
          apiBase +
              'broadcastSearchPublic?search=$search&inludeReplay=$includeReplay',
          headers: {
            'X-Periscope-User-Agent': userAgent,
          });

      if (response != null) {
        if (response.statusCode == 200) {
          if (response.body != null) {
            final responseJson = json.decode(utf8.decode(response.bodyBytes));

            List<Broadcast> broadcasts = (responseJson as List)
                .map((i) => Broadcast.fromJson(i))
                .toList();

            return broadcasts;
          }
        }
      }
    } catch (err) {
      Toaster.show('error_occured');
    }

    return null;
  }

  Future<UserBroadcasts> getUserBroadcasts(
      String userId, bool callToken) async {
    if (!NetworkTool.instance.networkAvailable) return null;

    if (cookie == null || token == null || sessionId == null) return null;
    if (userId == null) return null;
    if (userId.isEmpty) return null;

    try {
      var response = await http.get(
          apiBase +
              'getUserBroadcastsPublic?user_id=$userId&session_id=$sessionId',
          headers: {
            HttpHeaders.authorizationHeader: token,
            HttpHeaders.cookieHeader: cookie,
            'X-Periscope-User-Agent': userAgent,
          });

      if (response != null) {
        if (response.statusCode == 200) {
          if (response.body != null) {
            final responseJson = json.decode(utf8.decode(response.bodyBytes));

            return UserBroadcasts.fromJson(responseJson);
          }
        } else if (response.statusCode == 401 && callToken) {
          await getToken(() {});
          return await getUserBroadcasts(userId, false);
        }
      }
    } catch (err) {
      Toaster.show('error_occured');
    }

    return null;
  }

  Future<void> getStream(
      String id, ValueChanged<Stream> onStreamGetted, bool callToken) async {
    if (!NetworkTool.instance.networkAvailable) return null;

    if (cookie.isEmpty || token.isEmpty) return null;
    if (id == null) return null;
    if (id.isEmpty) return null;

    try {
      var response = await http
          .get(apiBase + 'accessVideoPublic?broadcast_id=' + id, headers: {
        HttpHeaders.authorizationHeader: token,
        HttpHeaders.cookieHeader: cookie,
        'X-Periscope-User-Agent': userAgent,
      });

      if (response != null) {
        if (response.statusCode == 200) {
          if (response.body != null) {
            final responseJson =
                await json.decode(utf8.decode(response.bodyBytes));

            Stream stream = Stream.fromJson(responseJson);

            if (stream != null) {
              onStreamGetted(stream);
            }
          }
        } else if (response.statusCode == 401 && callToken) {
          await getToken(() {});
          await getStream(id, (stream) {
            onStreamGetted(stream);
          }, false);
        }
      }
    } catch (err) {
      Toaster.show('error_occured');
    }
  }

  void getStreams(List<String> ids, ValueChanged<Stream> onStreamGetted) async {
    if (!NetworkTool.instance.networkAvailable) return null;

    if (cookie.isEmpty || token.isEmpty) return null;
    if (ids == null) return null;
    if (ids.length == 0) return null;

    for (String id in ids) {
      if (id != null) {
        if (id.isNotEmpty) {
          getStream(id, onStreamGetted, true);
        }
      }
    }
  }

  Future<int> tryTokenAndGetChannels(String langCode) async {
    if (!NetworkTool.instance.networkAvailable) return null;
    if (cookie == null || token == null) return null;

    try {
      var response = await http.get(
          channelsBase +
              'top/channels/broadcasts?languages=$langCode&languages=en&languages=es',
          headers: {
            HttpHeaders.authorizationHeader: token,
            HttpHeaders.cookieHeader: cookie,
            'X-Periscope-User-Agent': userAgent,
          });

      if (response != null) {
        if (response.statusCode == 200) {
          if (response.body != null) {
            final responseJson = json.decode(utf8.decode(response.bodyBytes));

            Channels temp = Channels.fromJson(responseJson);
            StreamsDb().channels = temp;
          }
        }
        return response.statusCode;
      } else {
        return -1;
      }
    } catch (err) {
      Toaster.show('error_occured');
      return -1;
    }
  }
}
