import 'dart:typed_data';

class CachedImage {
  CachedImage(this.url, this.bytes);

  String url;
  Uint8List bytes;
}
