import 'package:dev_libraries/models/adconfiguration.dart';

enum AdEventId {
  //load
  LoadAd,
  StartAdStream,
  EndAdStream,

  //error
  AdLoadFailed
}

class AdEvent {
  final AdEventId id;
  AdEvent(this.id);
}

class AdLoadEvent extends AdEvent {
  final AdConfiguration adConfiguration;
  AdLoadEvent(this.adConfiguration) : super(AdEventId.LoadAd);
}