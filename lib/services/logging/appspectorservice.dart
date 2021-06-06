//import 'package:appspector/appspector.dart' as appSpector;
import 'package:dev_libraries/contracts/logging/logservice.dart';

class AppSpectorService extends LogService {
  AppSpectorService({String? androidKey, String? iosKey}) {
    initialize(androidKey: androidKey ?? '', iosKey: iosKey ?? '');
  }

  @override
  void log(LogLevel level, Exception exception, String message) async {
    //the sdk picks up whatever is logged to the console
  }

  @override
  void initialize({String? androidKey, String? iosKey}) {
    // var config = appSpector.Config();
    // config.iosApiKey = iosKey;
    // config.androidApiKey = androidKey;
    // appSpector.AppSpectorPlugin.run(config);
  }
}
