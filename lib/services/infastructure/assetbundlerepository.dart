import 'package:dev_libraries/contracts/infastructure/configurationrepository.dart';
import 'package:flat/flat.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'dart:convert';
import 'dart:io' as io;

class AssetBundleRepository extends ConfigurationRepository {
  final AssetBundle _bundle;
  final String _configFilePath;
  final String _delimiter;

  AssetBundleRepository(
      {AssetBundle? bundle,
      String configFilePath = "assets/config.json",
      String delimiter = ":"})
      : _configFilePath = configFilePath,
        _delimiter = delimiter,
        _bundle = bundle ?? rootBundle;

  Future<Map<String, dynamic>> getAll({ List<String>? keys }) async => io.File(_configFilePath).exists()
      .then((exists) => exists ? _bundle.loadString(_configFilePath) : throw Exception("File not found $_configFilePath"))
      .then((content) => flatten(json.decode(content), delimiter: _delimiter));

  Future<bool> save<T>(String key, T value) async =>
      throw Exception("Not implemented");
}
