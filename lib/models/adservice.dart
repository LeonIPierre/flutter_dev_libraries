import 'package:dev_libraries/models/ad.dart';
import 'package:dev_libraries/models/adconfiguration.dart';

enum AdType {
  Any,

  Internal, //ads for other products I own
  Banner,
  
  Interstitial, //full screen ad
  Reward,
  Native
}

abstract class AdService {
  void initialize(String appId);

  AdService loadAd(AdConfiguration options, { dynamic evenListener });
  
  Future<Ad> requestAd(AdConfiguration options);

  void dispose();
}