import 'package:allscope/ui/design.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/screenutil.dart';

class ScreenHelper {
  static void init(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: Size(Design.width, Design.height),
      allowFontScaling: false,
    );
  }
}
