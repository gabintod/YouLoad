import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config {
  static const String configMemKey = 'config_mem_key';
  static Config? _instance;

  Directory? downloadDirectory;

  Config._({required this.downloadDirectory});

  Config.fromJson(Map<String, dynamic> json)
      : downloadDirectory = json['downloadDirectory'];

  Map<String, dynamic> toJson() => {
        'downloadDirectory': downloadDirectory,
      };

  static Future<Config?> load() async {
    String? savedConfig =
        (await SharedPreferences.getInstance()).getString(configMemKey);

    if (savedConfig == null) return null;

    return Config.fromJson(jsonDecode(savedConfig));
  }

  Future<bool> save() async => (await SharedPreferences.getInstance())
      .setString(configMemKey, jsonEncode(toJson()));

  static Future<Config> getInstance() async {
    _instance ??= await load();
    _instance ??= await Config.defaultConfig;

    return _instance!;
  }

  static Future<Config> get defaultConfig async => Config._(
        downloadDirectory: await getExternalStorageDirectory(),
      );
}
