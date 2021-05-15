import 'dart:convert';
import 'dart:io';

import 'package:allscope/api/apiService.dart';
import 'package:allscope/db/streamsDb.dart';
import 'package:allscope/io/files.dart';
import 'package:allscope/io/ioTool.dart';
import 'package:allscope/lang/appLocalization.dart';
import 'package:allscope/models/broadcast.dart';
import 'package:allscope/models/broadcastPageTypes.dart';
import 'package:allscope/models/channels.dart';
import 'package:allscope/models/savedBroadcasts.dart';
import 'package:allscope/models/stream.dart';
import 'package:allscope/models/userDetails.dart';
import 'package:allscope/pages/broadcastsPage.dart';
import 'package:allscope/pages/streamPage.dart';
import 'package:allscope/pages/userPage.dart';
import 'package:allscope/ui/dialogs.dart';
import 'package:allscope/ui/toaster.dart';
import 'package:allscope/utils/consts.dart';
import 'package:allscope/utils/networkTool.dart';
import 'package:allscope/video/flickMultiManager.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

import '../models/analytics.dart';

class BroadcastUtils {
  String getHlsUrl(Stream stream) {
    if (stream == null) return '';

    if (stream.replayUrl != null) {
      return stream.replayUrl;
    } else if (stream.httpsHlsUrl != null) {
      return stream.httpsHlsUrl;
    }

    return '';
  }

/*        
"start": "2019-09-10T21:55:41.144679074Z",   
"ping": "2019-09-10T23:11:31.656381907Z",
"end": "2019-09-10T23:11:32.418895404Z",
 */
  String calculateTime(Broadcast broadcast) {
    if (broadcast == null) return '';
    if (broadcast.start == null) return '';
    if (broadcast.end == null) return '';

    String start = timeBase(broadcast.start);
    String end = timeBase(broadcast.end);

    if (start != null && end != null) {
      String format = 'HH:mm:ss';

      var startTime = DateFormat(format).parse(start);
      var endTime = DateFormat(format).parse(end);

      var output = endTime.difference(startTime);

      String sDuration = '';

      if (output.inHours != 0) {
        sDuration += output.inHours.toString() + ':';
      }
      int mins = output.inMinutes.remainder(60);
      if (mins < 10) {
        sDuration += '0' + mins.toString() + ':';
      } else {
        sDuration += mins.toString() + ':';
      }
      int secs = output.inSeconds.remainder(60);
      if (secs < 10) {
        sDuration += '0' + secs.toString();
      } else {
        sDuration += secs.toString();
      }

      if (!sDuration.contains('-')) {
        return sDuration;
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  String timeBase(String time) {
    if (time == null) return '';
    if (time.isEmpty) return '';

    int indexOfT = time.indexOf('T');
    if (indexOfT != 0 && indexOfT != -1) {
      String result =
          time.substring(indexOfT).replaceAll('T', '').split('.')[0];

      return result;
    }

    return '';
  }

  DeviceOrientation buildOrientation(Broadcast broadcast) {
    DeviceOrientation orientation = DeviceOrientation.landscapeLeft;
    if (broadcast.height > broadcast.width) {
      orientation = DeviceOrientation.portraitUp;
    }
    return orientation;
  }

  bool checkIfBroadcastStatusEmpty(Broadcast broadcast) {
    if (broadcast == null) return false;
    if (broadcast.status == null) return true;
    if (broadcast.status.isEmpty) return true;

    return false;
  }

  void play(
      BuildContext context, Broadcast broadcast, Function onCompleted) async {
    if (context == null) return;
    if (broadcast == null) return;
    if (broadcast.id == null) return;
    if (onCompleted == null) return;

    if (!NetworkTool.instance.networkAvailable) {
      Toaster.show('network_err_broadcast');
      return;
    } else {
      //Toaster.show('stream_loading');
      DeviceOrientation orientation = buildOrientation(broadcast);

      if (broadcast.stream != null) {
        playBase(
            broadcast.stream, broadcast, orientation, context, onCompleted);
      } else {
        ApiService().getStream(broadcast.id, (stream) {
          if (stream != null) {
            playBase(stream, broadcast, orientation, context, onCompleted);
          }
        }, true);
      }
    }
  }

  void playWithId(
      BuildContext context, String broadcastId, Function onCompleted) {
    if (context == null || broadcastId == null || onCompleted == null) return;

    ApiService().getStream(broadcastId, (stream) {
      if (stream != null) {
        if (stream.broadcast != null) {
          DeviceOrientation orientation = buildOrientation(stream.broadcast);

          playBase(stream, stream.broadcast, orientation, context, onCompleted);
        }
      }
    }, true);
  }

  void playDownloaded(BuildContext context, File file, Broadcast broadcast,
      Function onCompleted) async {
    if (context == null) return;
    if (file == null) return;
    if (broadcast == null) return;
    if (broadcast.id == null) return;
    if (onCompleted == null) return;

    FirebaseAnalytics()
        .logEvent(name: Analytics.playDownloaded, parameters: null);

    //Toaster.show('stream_loading');

    DeviceOrientation orientation = buildOrientation(broadcast);

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => StreamPage(
                  downloadedBroadcast: file,
                  broadcast: broadcast,
                  orientation: orientation,
                  downloaded: true,
                )));

    if (result != null) {
      if (result is int) {
        if (result == 100) {
          onCompleted();
        }
      }
    }
  }

  void delete(BuildContext context, Broadcast broadcast, Function onDeleted) {
    if (context == null || broadcast == null) return;
    Dialogs.askQuestion(context, 'broadcast_delete_question', () async {
      deleteBroadcastBase(broadcast, onDeleted);
    });
  }

  void deleteBroadcastBase(Broadcast broadcast, Function onDeleted) async {
    if (broadcast == null || onDeleted == null) return;
    bool deleted = await IoTool.removeFile(broadcast.id + Consts.videoFileExt);

    if (deleted != null) {
      if (deleted) {
        deleteFromSavedBroadcastList(broadcast, onDeleted);
      }
    }
  }

  void deleteFromSavedBroadcastList(
      Broadcast broadcast, Function onDeleted) async {
    if (broadcast == null || onDeleted == null) return;
    SavedBroadcasts saved = await BroadcastUtils().readSavedBroadcastsFile();
    if (saved != null) {
      if (saved.broadcasts != null) {
        try {
          Broadcast temp2 = saved.broadcasts
              .where((element) => element.id == broadcast.id)
              .first;
          if (temp2 != null) {
            int i = saved.broadcasts.indexOf(temp2);
            if (i != null) {
              saved.broadcasts.removeAt(i);
              onDeleted();
            }
          }

          saveSavedBroadcast(saved);
        } catch (err) {}
      }
    }
  }

  Future<void> saveDownloadedBroadcast(Broadcast broadcast) async {
    if (broadcast == null) return;

    bool existsAlready = await IoTool.fileExists(Files.savedBroadcasts);
    SavedBroadcasts temp;
    List<Broadcast> list = List();

    if (existsAlready) {
      temp = await readSavedBroadcastsFile();
    } else {
      temp = SavedBroadcasts();
      temp.broadcasts = list;
    }

    if (temp.broadcasts != null &&
        !existsInSavedBroadcast(temp.broadcasts, broadcast)) {
      temp.broadcasts.add(broadcast);
    }

    await saveSavedBroadcast(temp);
  }

  bool existsInSavedBroadcast(List<Broadcast> broadcasts, Broadcast searching) {
    bool value = false;

    for (Broadcast broadcast in broadcasts) {
      if (broadcast.id == searching.id) {
        value = true;
        break;
      }
    }

    return value;
  }

  Future<bool> existsInSavedBroadcast2(Broadcast _broadcast) async {
    SavedBroadcasts _temp = await readSavedBroadcastsFile();
    if (_temp != null) {
      List<Broadcast> broadcasts = _temp.broadcasts;

      if (broadcasts != null) {
        bool value = false;

        for (Broadcast broadcast in broadcasts) {
          if (_broadcast.id == broadcast.id) {
            value = true;
            break;
          }
        }

        return Future.value(value);
      } else {
        return Future.value(false);
      }
    } else {
      return Future.value(false);
    }
  }

  Future<void> saveSavedBroadcast(SavedBroadcasts savedBroadcasts) async {
    if (savedBroadcasts == null) return;

    String json = jsonEncode(savedBroadcasts);

    await IoTool.saveFile(Files.savedBroadcasts, json);
  }

  Future<SavedBroadcasts> readSavedBroadcastsFile() async {
    try {
      final file = await IoTool.readFile(Files.savedBroadcasts);

      String json = await file.readAsString();
      Map map = jsonDecode(json);
      return SavedBroadcasts.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  void playBase(
      Stream stream,
      Broadcast broadcast,
      DeviceOrientation orientation,
      BuildContext context,
      Function onCompleted) async {
    if (stream != null && orientation != null && broadcast != null) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StreamPage(
                    stream: stream,
                    broadcast: broadcast,
                    orientation: orientation,
                    downloaded: false,
                  )));

      if (result != null) {
        if (result is int) {
          if (result == 100) {
            onCompleted();
          }
        }
      }
    }
  }

  void openUserBroadcastPage(String userName,
      FlickMultiManager flickMultiManager, BuildContext context) {
    if (context == null || userName == null) return;
    if (userName.isEmpty) return;

    if (flickMultiManager != null) {
      flickMultiManager.pause();
    }

    openUser(userName, context);
  }

  void openUser(String userName, BuildContext context) async {
    if (userName == null) return;
    if (userName.isEmpty) return;

    FirebaseAnalytics().logEvent(name: Analytics.viewUser, parameters: null);

    UserDetails userDetails = await ApiService().getUserDetails(userName, true);
    if (userDetails != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserPage(
                    userDetails: userDetails,
                  )));
    }
  }

  void onDynamicLinkGetted(
      BuildContext context, Uri uri, Function onCompleted) {
    if (uri != null && onCompleted != null) {
      if (!NetworkTool.instance.networkAvailable) {
        Toaster.show('network_err_broadcast');
        return;
      } else {
        final queryParams = uri.queryParameters;
        if (queryParams.length > 0) {
          String broadcastId = queryParams["stream"];

          if (broadcastId != null) {
            if (broadcastId.isNotEmpty) {
              FirebaseAnalytics().logEvent(
                  name: Analytics.playBroadcastLink, parameters: null);

              Toaster.show('stream_loading');

              BroadcastUtils().playWithId(context, broadcastId, onCompleted);
            }
          }
        }
      }
    }
  }

  void onBroadcastFromNotification(
      BuildContext context, String broadcastId, Function onCompleted) {
    if (broadcastId != null && onCompleted != null) {
      if (!NetworkTool.instance.networkAvailable) {
        Toaster.show('network_err_broadcast');
        return;
      } else {
        if (broadcastId != null) {
          if (broadcastId.isNotEmpty) {
            FirebaseAnalytics().logEvent(
                name: Analytics.playBroadcastNotification, parameters: null);

            Toaster.show('stream_loading');

            BroadcastUtils().playWithId(context, broadcastId, onCompleted);
          }
        }
      }
    }
  }

  void share(Broadcast broadcast) async {
    if (NetworkTool.instance.networkAvailable) {
      Toaster.show('please_wait');

      final DynamicLinkParameters parameters = DynamicLinkParameters(
          uriPrefix: 'http://allscope.page.link',
          link: Uri.parse(
              'http://allscope.page.link/share?stream=${broadcast.id}'),
          androidParameters:
              AndroidParameters(packageName: 'com.alp.periscodroid'),
          dynamicLinkParametersOptions: DynamicLinkParametersOptions(
              shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short),
          socialMetaTagParameters: SocialMetaTagParameters(
              title: AppLocalizations.instance.text('share_title'),
              description: AppLocalizations.instance.text('share_content')));

      final ShortDynamicLink shortLink = await parameters.buildShortLink();

      String shareText = AppLocalizations.instance.text('share_text') +
          shortLink.shortUrl.toString();

      Share.share(shareText);
    }
  }

  ChannelBroadcasts findChannelById(String channelId) {
    if (channelId == null) return null;
    if (channelId.isEmpty) return null;

    ChannelBroadcasts _channel;

    for (ChannelBroadcasts channelBroadcast
        in StreamsDb().channels.channelBroadcasts) {
      if (channelBroadcast.channel.cID == channelId) {
        _channel = channelBroadcast;
        break;
      }
    }

    return _channel;
  }

  void openChannel(BuildContext context, ChannelBroadcasts channelBroadcasts) {
    if (context == null) return;
    if (channelBroadcasts == null) return;
    if (channelBroadcasts.channel == null) return;

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BroadcastsPage(
                  type: BroadcastPageTypes.FROM_CHANNEL,
                  channel: channelBroadcasts.channel,
                )));
  }

  void openChannelId(
      BuildContext context, String channelId, Function onCompleted) async {
    Channels channels = StreamsDb().channels;

    if (context == null) return;
    if (channels == null) return;
    if (channelId == null) return;
    if (channelId.isEmpty) return;
    if (onCompleted == null) return;

    ChannelBroadcasts ourChannel;

    for (ChannelBroadcasts _channel in channels.channelBroadcasts) {
      if (_channel.channel.cID == channelId) {
        ourChannel = _channel;
        break;
      }
    }

    if (ourChannel != null) {
      FirebaseAnalytics()
          .logEvent(name: Analytics.openChannelNotification, parameters: null);

      int result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BroadcastsPage(
                    type: BroadcastPageTypes.FROM_CHANNEL,
                    channel: ourChannel.channel,
                  )));

      if (result != null) {
        if (result is int) {
          if (result == 100) {
            onCompleted();
          }
        }
      }
    }
  }
}
