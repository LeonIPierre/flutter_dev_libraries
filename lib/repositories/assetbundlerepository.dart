import 'package:flat/flat.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'dart:convert';

class AssetBundleRepository {
  final String _configFilePath;
  final String _delimiter;
  final AssetBundle _bundle;

  AssetBundleRepository({AssetBundle bundle, String configFilePath, String delimiter}) :
      _configFilePath = configFilePath ?? "assets/config.json",
      _delimiter = delimiter ?? ":",
      _bundle = bundle ?? rootBundle;

  Future<Map<String, dynamic>> getAll({ List<String> keys }) async => await _bundle.loadString(_configFilePath)
    .then((content) => flatten(json.decode(content), delimiter: _delimiter));
  
  void save(String key, dynamic value) => throw Exception("Not implemented");
}