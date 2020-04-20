import 'package:dev_libraries/services/ads/adservice.dart';

enum AdEventId {
  //load
  LoadAd, 
  
  //error
  AdLoadFailed,
}

class AdEvent {
  final AdEventId id;
  AdEvent(this.id);
}

class AdLoadEvent extends AdEvent {
  final AdType adType;
  final List<String> keywords;

  AdLoadEvent(this.adType, {this.keywords}) : super(AdEventId.LoadAd);
}