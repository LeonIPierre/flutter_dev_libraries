import 'package:dev_libraries/bloc/events.dart';
import 'package:dev_libraries/models/ad.dart';
import 'package:dev_libraries/models/adconfiguration.dart';

enum AdType {
  Any,

  Internal, //ads for other products I own
  Banner,
  Interstitial, //full screen ad
  InterstitialVideo, //full screen video ad
  Reward,
  Native,
  NativeVideo
}

abstract class AdService {
  String getAdUnitId(AdStreamConfiguration adConfiguration);

  void initialize(String appId);

  Future<AdConfiguration> loadAd(AdConfiguration configuration, { Function(AdEventId) eventListener });
  
  Future<Ad> requestAd(AdConfiguration configuration);

  void dispose();
}