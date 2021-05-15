import 'dart:typed_data';

import 'package:allscope/models/cachedImage.dart';

class CachedImages {
  static final CachedImages instance = CachedImages._internal();

  factory CachedImages() {
    return instance;
  }

  CachedImages._internal();

  List<CachedImage> list = List();

  void add(String url, Uint8List bytes) {
    if (url == null || bytes == null) return;
    if (url.isEmpty) return;

    list.add(CachedImage(url, bytes));
  }

  CachedImage exists(String url) {
    if (url == null) return null;
    if (url.isEmpty) return null;

    CachedImage _temp;

    for (CachedImage _cImg in list) {
      if (_cImg.url == url) {
        _temp = _cImg;
        break;
      }
    }

    return _temp;
  }

  void clear() {
    list.clear();
  }
}
