import 'package:dev_libraries/models/adconfiguration.dart';

enum AdEventId {
  //load
  LoadAd,

  StartAdStream,
  StreamAd,
  EndAdStream,

  CloseAd,

  //events for usage activity
  UpdateAdImpressions,
  
  //events for system activity

  //error
  AdLoadFailed
}

class AdEvent {
  final AdEventId id;
  final AdConfiguration adConfiguration;
  AdEvent(this.id, { this.adConfiguration });
}
