import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesRepository {
  final Future<SharedPreferences> preferences = SharedPreferences.getInstance();

  Future<Map<String, dynamic>> getAll({ List<String> keys }) async {
    if(keys == null)
      throw Exception("no keys found");

    return await preferences
      .then((preferences) {
        Map<String, dynamic> configuration = Map<String, dynamic>();

        keys.forEach((key) {
          configuration.update(key, (value) => preferences.get(key));
        });
        return configuration;
      });
  }

  void save(String key, dynamic value) async {
    await preferences
      .then((preferences) {
        //preferences.
      });
  }
}