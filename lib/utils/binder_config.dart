import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Config {

  static Future<File> getConfigFile() async {
    Directory filePath = await getApplicationDocumentsDirectory();
    return File("${filePath.path}/config.conf");
  }

  static Future<bool> isConfigured() async {
    var config = await readConfig();
    if (
      (config["userid"]   != null || config["userid"].toString().isNotEmpty) &&
      (config["carplate"] != null || config["carplate"].toString().isNotEmpty)
    ) {
      return true;
    }

    return false;
  }

  static Future<Map<String, dynamic>> readConfig() async {
    File file = await getConfigFile();
    try {
      String fcontent = await file.readAsString();
      return jsonDecode(fcontent);
    } catch (err) {
      return {"userid": null, "carplate": null};
    }
  }

  static void writeConfig(String jsonString,Function onsuccess,Function onerror) async {
    try {
      File file = await getConfigFile();
      file.writeAsString(jsonString);
      onsuccess();
    }
    catch(err) {
      onerror();
    }
  }

}
