import 'package:flutter/services.dart';

class OrientationTool {
  static Future<void> handle() async {
    return await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
}
