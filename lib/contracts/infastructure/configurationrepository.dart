abstract class ConfigurationRepository {
  Future<Map<String, dynamic>> getAll({ List<String>? keys });
  
  Future<bool> save<T>(String key, T value);
}