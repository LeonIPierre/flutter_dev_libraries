import 'package:dev_libraries/bloc/ads/ads.dart';
import 'package:dev_libraries/models/ads/ad.dart';

import 'adconfiguration.dart';

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
  void initialize(String appId);

  AdConfiguration loadAd(AdConfiguration configuration, { Function(AdEventId) eventListener });

  Future<AdConfiguration> loadAdAsync(AdConfiguration configuration, { Function(AdEventId, AdConfiguration) eventListener });

  Future<Ad> requestAd(AdConfiguration configuration);

  void dispose();
}