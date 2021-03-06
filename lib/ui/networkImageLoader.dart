import 'package:allscope/db/cachedImages.dart';
import 'package:allscope/models/cachedImage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:typed_data';

class NetworkImageLoader {
  String url;
  Map<String, String> headers;

  NetworkImageLoader(this.url, {this.headers});

  Future<Uint8List> load() async {
    CachedImage exists = CachedImages.instance.exists(url);
    if (exists != null) {
      return exists.bytes;
    } else {
      try {
        final Uri resolved = Uri.base.resolve(this.url);
        final http.Response response =
            await http.get(resolved, headers: headers);
        if (response == null || response.statusCode != 200)
          throw new Exception(
              'HTTP request failed, statusCode: ${response?.statusCode}, $resolved');

        final Uint8List bytes = response.bodyBytes;
        if (bytes.lengthInBytes == 0)
          throw new Exception('NetworkImage is an empty file: $resolved');

        CachedImages.instance.add(url, bytes);

        return bytes;
      } catch (err) {
        // Toaster.show('error_occured');
        return null;
      }
    }
  }
}
