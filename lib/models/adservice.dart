import 'package:dev_libraries/models/ad.dart';
import 'package:dev_libraries/models/adconfiguration.dart';

enum AdType {
  Any,

  Internal,
  Banner,
  
  Interstitial, //full screen ad
  Reward,
  Native
}

abstract class AdService {
  void initialize();

  void loadAd(AdType adType);
  
  Future<Ad> showAd(AdConfiguration options);

  void dispose();
}