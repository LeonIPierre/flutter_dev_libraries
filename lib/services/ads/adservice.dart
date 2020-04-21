import 'package:dev_libraries/models/ad.dart';

enum AdType {
  Internal,
  Banner,
  
  Interstitial, //full screen ad
  Reward,
  Native
}

abstract class AdService {
  void initialize();
  
  Future<Ad> showAd(AdType adType, { List<String> keywords });

  void dispose();
}