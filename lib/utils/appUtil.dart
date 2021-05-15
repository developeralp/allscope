import 'package:allscope/db/cachedImages.dart';
import 'package:allscope/services/nativeBackground.dart';
import 'package:allscope/ui/notifications.dart';
import 'package:allscope/utils/networkTool.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class AppUtil {
  void init(Function onReady) async {
    if (onReady == null) return;
    WidgetsFlutterBinding.ensureInitialized();
    Notifications.instance.init();
    NativeBackground();
    CachedImages();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        NetworkTool.instance.networkAvailable = true;
      } else {
        NetworkTool.instance.networkAvailable = false;
        NativeBackground().onNetworkGone();
      }
    });

    await NetworkTool.instance.checkNetwork();

    await Firebase.initializeApp();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    onReady();
  }
}
