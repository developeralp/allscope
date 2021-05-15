import 'dart:io';
import 'package:allscope/lang/appLocalization.dart';
import 'package:allscope/utils/consts.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';

class Notifications {
  static final Notifications instance = Notifications._internal();

  factory Notifications() {
    return instance;
  }

  Notifications._internal();
  MethodChannel methodChannel;

  /*final BehaviorSubject<ReceivedNotification>
      didReceiveLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();*/

  final String channelId = 'AllScopeNotifChannelID';
  final String channelName = 'AllScopeNotifChannel';
  final String channelDesc = 'Desc';

  void init() {
    methodChannel = MethodChannel(Consts.packageName + '/method');
  }

  Future<int> showDownloadBroadcast(String broadcastId) async {
    return await methodChannel.invokeMethod('showDownloadNotification', {
      'title': AppLocalizations.instance.text('please_wait'),
      'text': AppLocalizations.instance.text('broadcast_downloading'),
      'cancel': AppLocalizations.instance.text('cancel'),
      'view': AppLocalizations.instance.text('view')
    });
  }

  void pushNotification(
    String title,
    String text,
  ) async {
    await methodChannel.invokeMethod('pushNotification', {
      'title': AppLocalizations.instance.text(title),
      'text': AppLocalizations.instance.text(text),
    });
  }

  void pushNotificationText(
    String title,
    String text,
  ) async {
    await methodChannel.invokeMethod('pushNotification', {
      'title': title,
      'text': text,
    });
  }

  void clearNotifications() async {
    await methodChannel.invokeMethod('clearNotifications');
  }

  Future<String> getIconForAndroidVersion() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo != null) {
        var sdkInt = androidInfo.version.sdkInt;
        if (sdkInt != null) {
          if (sdkInt is int) {
            if (sdkInt >= 21) {
              return 'icon_notif';
            } else {
              return 'ic_launcher';
            }
          }
        }
      }
    }

    return 'ic_launcher';
  }
}
