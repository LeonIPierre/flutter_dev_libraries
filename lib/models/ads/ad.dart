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

class Ad {
  final Object adObject;
  
  Ad(this.adObject);
}