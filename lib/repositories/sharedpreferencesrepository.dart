import 'package:dev_libraries/contracts/configurationrepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesRepository extends ConfigurationRepository {
  final Future<SharedPreferences> preferences = SharedPreferences.getInstance();

  Future<Map<String, dynamic>> getAll({ List<String> keys }) async {
    if(keys == null)
      throw Exception("no keys found");

    return await preferences
      .then((preferences) {
        Map<String, dynamic> configuration = Map<String, dynamic>();

        keys.forEach((key) {
          var prefValue = preferences.get(key);
          configuration.update(key, (value) => prefValue, ifAbsent: () => prefValue);
        });
        
        return configuration;
      });
  }

  Future<bool> save<T>(String key, T value) async {
    return await preferences
      .then((preferences) {
          if(value is bool)
            return preferences.setBool(key, value);
          else if(value is String)
            return preferences.setString(key, value);
          else if(value is List<String>)
            return preferences.setStringList(key, value);
          else if(value is double)
            return preferences.setDouble(key, value);
          else if(value is int)
            return preferences.setInt(key, value);
          else
            throw Exception("unhandled type");
      });
  }
}