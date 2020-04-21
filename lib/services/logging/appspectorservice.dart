import 'package:appspector/appspector.dart' as appSpector;
import 'package:dev_libraries/services/logging/logservice.dart';

class AppSpectorService extends LogService {
  final Map<String, String> configuration;
  AppSpectorService(this.configuration) : assert(configuration != null) {
    initialize();
  }

  @override
  void log(LogLevel level, Exception exception, String message) async {
    //the sdk picks up whatever is logged to the console
  }

  @override
  void initialize() async {
    // if(!configuration.containsKey("androidApiKey"))
    //   throw Exception("Missing key from configuration androidApiKey");

    // if(!configuration.containsKey("iosApiKey"))
    //   throw Exception("Missing key from configuration iosApiKey");

    var config = appSpector.Config();
    config.iosApiKey = configuration["iosApiKey"];
    config.androidApiKey = configuration["androidApiKey"];
    appSpector.AppSpectorPlugin.run(config);
  }
}
