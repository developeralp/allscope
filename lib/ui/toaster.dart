import 'package:allscope/lang/appLocalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Toaster {
  static void show(String text) {
    if (text == null) return;
    if (text.isEmpty) return;

    _showBase(AppLocalizations.instance.text(text), Toast.LENGTH_SHORT);
  }

  static void showLong(String text) {
    if (text == null) return;
    if (text.isEmpty) return;

    _showBase(AppLocalizations.instance.text(text), Toast.LENGTH_LONG);
  }

  static void showLongText(String text) {
    if (text == null) return;
    if (text.isEmpty) return;

    _showBase(text, Toast.LENGTH_LONG);
  }

  static void showText(String text) {
    if (text == null) return;
    if (text.isEmpty) return;
    _showBase(text, Toast.LENGTH_SHORT);
  }

  static void _showBase(String text, Toast length) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: length,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[700],
        textColor: Colors.white,
        fontSize: ScreenUtil().setSp(42));
  }

  static void showSp(String text, Toast length, double sp) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: length,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[700],
        textColor: Colors.white,
        fontSize: sp);
  }
}
