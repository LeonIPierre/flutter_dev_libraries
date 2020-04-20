import 'package:dev_libraries/services/ads/adservice.dart';
//import 'package:firebase_admob/firebase_admob.dart';

class FirebaseAdMobService extends AdService {
  final Map<String, String> configuration;
  //MobileAd ad;

  FirebaseAdMobService(this.configuration);

  @override
  void initialize() {
  }

  @override
  Future<bool> showAd(AdType adType, { List<String> keywords }) async {
    return false;
    // MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    //   keywords: keywords,
    //   contentUrl: 'https://flutter.io',
    //   childDirected: false,
    //   testDevices: <String>[], // Android emulators are considered test devices
    //   );

    // switch(adType)
    // {
    //   case AdType.Banner:
    //     ad = BannerAd(
    //       adUnitId: BannerAd.testAdUnitId,
    //       size: AdSize.smartBanner,
    //       targetingInfo: targetingInfo,
    //       listener: (MobileAdEvent event) {
    //         print("BannerAd event is $event");
    //       });
    //     break;
    //   case AdType.Interstitial:
    //     ad = InterstitialAd(
    //       adUnitId: InterstitialAd.testAdUnitId,
    //       targetingInfo: targetingInfo,
    //       listener: (MobileAdEvent event) {
    //         print("InterstitialAd event is $event");
    //       });
    //     break;
    //   case AdType.Reward:
    //     //ad = RewardedVideoAd.instance;
    //     //RewardedVideoAd.instance.load(adUnitId: InterstitialAd.testAdUnitId, targetingInfo: targetingInfo);
    //     //RewardedVideoAd.instance.show();
    //     break;
    //   default:
    //     break;
    // }
    
    // return await ad.load()
    //     .then((loadedAd) async {
    //       return loadedAd && await ad.show()
    //         .then((success) => success)
    //         .catchError((error) => false);
    //     })
    //     .catchError((error) => false);
  }

  @override
  void dispose() {
    //ad?.dispose();
  }
}