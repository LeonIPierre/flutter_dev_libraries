// import 'package:dev_libraries/services/ads/adservice.dart';
// import 'package:firebase_admob/firebase_admob.dart';

// class FirebaseAdMobService extends AdService {
//   final String _appId;
//   Map<String, dynamic> _configuration;
//   MobileAd ad;

//   FirebaseAdMobService(this._appId, { Map<String, dynamic> configuration}) {
//     this._configuration = configuration;
//   }

//   @override
//   void initialize() async {
//     await FirebaseAdMob.instance.initialize(appId: _appId);
//   }

//   @override
//   Future<bool> showAd(AdType adType, { List<String> keywords }) async {
    
//     MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//       keywords: keywords,
//       contentUrl: 'https://flutter.io',
//       childDirected: false,
//       testDevices: <String>[], // Android emulators are considered test devices
//       );

//     switch(adType)
//     {
//       case AdType.Banner:
//         ad = BannerAd(
//           adUnitId: BannerAd.testAdUnitId,
//           size: AdSize.smartBanner,
//           targetingInfo: targetingInfo,
//           listener: (MobileAdEvent event) {
//             print("BannerAd event is $event");
//           });
//         break;
//       case AdType.Interstitial:
//         ad = InterstitialAd(
//           adUnitId: InterstitialAd.testAdUnitId,
//           targetingInfo: targetingInfo,
//           listener: (MobileAdEvent event) {
//             print("InterstitialAd event is $event");
//           });
//         break;
//       case AdType.Reward:
//         //ad = RewardedVideoAd.instance;
//         //RewardedVideoAd.instance.load(adUnitId: InterstitialAd.testAdUnitId, targetingInfo: targetingInfo);
//         //RewardedVideoAd.instance.show();
//         break;
//       default:
//         break;
//     }
    
//     return await ad.load()
//         .then((loadedAd) async {
//           return loadedAd && await ad.show()
//             .then((success) => success)
//             .catchError((error) => false);
//         })
//         .catchError((error) => false);
//   }

//   @override
//   void dispose() {
//     ad?.dispose();
//   }
// }