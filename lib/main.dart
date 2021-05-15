import 'dart:async';
import 'package:allscope/utils/appUtil.dart';
//import 'package:device_preview/device_preview.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  AppUtil().init(() {
    runZonedGuarded(() {
      runApp(App());

      /* runApp(
        DevicePreview(
          enabled: true,
          builder: (context) => App(),
        ),
      );*/
    }, (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    });
  });
}
