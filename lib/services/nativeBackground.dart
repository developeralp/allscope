import 'package:allscope/interfaces/homePageCb.dart';
import 'package:allscope/io/ioTool.dart';
import 'package:allscope/models/broadcast.dart';
import 'package:allscope/models/ffmpegStatuses.dart';
import 'package:allscope/ui/notifications.dart';
import 'package:allscope/ui/toaster.dart';
import 'package:allscope/models/analytics.dart';
import 'package:allscope/utils/broadcastUtils.dart';
import 'package:allscope/utils/consts.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class NativeBackground {
  final methodChannel = MethodChannel(Consts.packageName + '/background');

  bool downloading;
  bool cancelDownloadCalled;
  Broadcast currentBroadcast;
  Function openDownloadsPage;
  HomePageCb homePageCb;

  String broadcastId;
  String channelId;

  FlutterFFmpeg flutterFFmpeg;

  static NativeBackground _instance;
  factory NativeBackground() => _instance ??= NativeBackground._();

  NativeBackground._() {
    init();
  }

  void init() {
    clearVariables();
    handlePlatformChannelMethods();
  }

  void clearVariables() {
    downloading = false;
    cancelDownloadCalled = false;
    broadcastId = '';
    channelId = '';
  }

  Future<void> handlePlatformChannelMethods() async {
    methodChannel.setMethodCallHandler((methodCall) {
      switch (methodCall.method) {
        case 'cancelDownload':
          cancelDownload();
          break;

        case 'setNotifBroadcastId':
          if (homePageCb != null) {
            homePageCb.setNotifBroadcastId(
                methodCall.arguments['title'],
                methodCall.arguments['text'],
                methodCall.arguments['broadcastId']);
          }
          break;

        case 'setNotifChannelId':
          if (homePageCb != null) {
            homePageCb.setNotifChannelId(
                methodCall.arguments['title'],
                methodCall.arguments['text'],
                methodCall.arguments['channelId']);
          }
          break;
      }

      return Future.value(true);
    });
  }

  Future<void> download(
      Broadcast broadcast, String hlsUrl, Function openDownloadsPage) async {
    if (broadcast == null || hlsUrl == null || openDownloadsPage == null)
      return;
    // if (!NetworkTool.instance.networkAvailable) return;
    await IoTool.checkDirectory();

    FirebaseAnalytics()
        .logEvent(name: Analytics.downloadStarted, parameters: null);

    this.openDownloadsPage = openDownloadsPage;
    this.cancelDownloadCalled = false;
    this.currentBroadcast = broadcast;

    hlsUrl = hlsUrl.replaceAll('https://', 'http://');
    String fileLocation =
        await IoTool.appFolderPath + '/' + broadcast.id + Consts.videoFileExt;
    bool existsAlready =
        await BroadcastUtils().existsInSavedBroadcast2(broadcast);

    if (!existsAlready) {
      flutterFFmpeg = FlutterFFmpeg();

      Notifications.instance.showDownloadBroadcast(broadcast.id);

      downloading = true;

      String ffmpegDownload = '-i $hlsUrl -c copy $fileLocation';
      Toaster.showLong('broadcast_download_info');
      int rc = await flutterFFmpeg.execute(ffmpegDownload);

      if (rc != null) {
        await BroadcastUtils().saveDownloadedBroadcast(broadcast);

        if (!cancelDownloadCalled) {
          Notifications.instance.clearNotifications();

          if (rc == FFMpegStatuses.SUCCESS) {
            Notifications.instance
                .pushNotification('info', 'broadcast_downloaded');
            FirebaseAnalytics()
                .logEvent(name: Analytics.downloadSuccess, parameters: null);
          } else {
            Notifications.instance
                .pushNotification('info', 'broadcast_download_err');
            FirebaseAnalytics()
                .logEvent(name: Analytics.downloadErr, parameters: null);
          }
        }

        this.currentBroadcast = null;
        this.downloading = false;
      }
    } else {
      Notifications.instance.pushNotification('info', 'broadcast_download_err');
    }
    return Future.value(true);
  }

  void onNetworkGone() {
    cancelDownload();
  }

  void cancelDownload() async {
    if (flutterFFmpeg == null || currentBroadcast == null) return;
    cancelDownloadCalled = true;
    Notifications.instance.clearNotifications();
    flutterFFmpeg.cancel();
    Notifications.instance.pushNotification('info', 'broadcast_down_cancelled');
    downloading = false;
  }

  Future<dynamic> checkNotifications() async {
    return await methodChannel.invokeMethod('checkNotifications');
  }

  void viewDownloads() {
    if (openDownloadsPage == null) return;

    openDownloadsPage.call();
  }
}
