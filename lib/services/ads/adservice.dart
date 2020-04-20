enum AdType {
  Internal,
  Banner,
  
  Interstitial, //full screen ad
  Reward,
  Native
}

abstract class AdService {
  void initialize();
  
  Future<bool> showAd(AdType adType, { List<String> keywords });

  void dispose();
}