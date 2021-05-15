import 'dart:io';

import 'package:allscope/utils/consts.dart';
import 'package:path_provider/path_provider.dart';

class IoTool {
  static Future<String> get appFolderPath async {
    final directory = await getExternalStorageDirectory();

    return directory.path
            .replaceAll('/Android/data/${Consts.packageName}/files', '') +
        '/${Consts.appName}';
  }

  static Future<File> readFile(String fileName) async {
    String path = await IoTool.appFolderPath;
    return File('$path/$fileName');
  }

  static Future<bool> fileExists(String fileName) async {
    return IoTool.readFile(fileName).then((File file) {
      return file.exists();
    });
  }

  static Future<void> checkDirectory() async {
    String path = await IoTool.appFolderPath;

    final Directory appFolder = Directory(path);
    if (!await appFolder.exists()) {
      await appFolder.create(recursive: true);
      return Future.value(true);
    }

    return Future.value(true);
  }

  static Future<File> saveFile(String fileName, String data) async {
    final file = await IoTool.readFile(fileName);

    return file.writeAsString('$data');
  }

  static Future<bool> removeFile(String fileName) async {
    try {
      IoTool.fileExists(fileName).then((bool exists) async {
        if (exists) {
          final file = await IoTool.readFile(fileName);

          file.delete();
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
