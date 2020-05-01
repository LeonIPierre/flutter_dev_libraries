import 'package:admob_flutter/admob_flutter.dart';
import 'package:dev_libraries/models/ad.dart';
import 'package:dev_libraries/models/adconfiguration.dart';
import 'package:dev_libraries/models/adservice.dart';

class AdMobService extends AdService {
  AdmobBanner _bannerAd;
  AdmobInterstitial _interstitialAd;
  AdmobReward _rewardAd;

  AdMobService(String appId) {
    initialize(appId);
  }
  
  @override
  void dispose() {
    _interstitialAd.dispose();
    _rewardAd.dispose();
  }

  @override
  void initialize(String appId) {
    Admob.initialize(appId);
  }

  @override
  AdService loadAd(AdConfiguration options, { dynamic evenListener })
  {
    switch(options.adType)
    {
      case AdType.Banner:
        _bannerAd = AdmobBanner(
          adUnitId: options.adUnitId,
          adSize: AdmobBannerSize.BANNER,
          listener: (AdmobAdEvent event, Map<String, dynamic> args) {
            if(event == AdmobAdEvent.failedToLoad) print("Ad failed to load");
          });
        break;
      case AdType.Interstitial:
        _interstitialAd = AdmobInterstitial(
          adUnitId: options.adUnitId,
          listener: (AdmobAdEvent event, Map<String, dynamic> args) {
            //if (event == AdmobAdEvent.closed) _interstitialAd.load();
          });

        _interstitialAd.load();
        break;
      case AdType.Reward:
        _rewardAd = AdmobReward(
          adUnitId:  options.adUnitId,
          listener: (AdmobAdEvent event, Map<String, dynamic> args) {
            //if (event == AdmobAdEvent.closed) _rewardAd.load();
          });

        _rewardAd.load();
        break;
      default:
        break;
    }

    return this;
  }

  @override
  Future<Ad> requestAd(AdConfiguration options) async {
    switch(options.adType)
    {
      case AdType.Banner:
        return Ad(_bannerAd);
      case AdType.Interstitial:
        return await _showInterstitialAd();
      case AdType.Reward:
        return await _showRewardAd();
      default:
        return throw Exception("Unable to request ad for ${options.adType}");
        break;
    }
  }

  Future<Ad> _showInterstitialAd() async {
    if (await _interstitialAd.isLoaded) {
      _interstitialAd.show();
      return Ad(_interstitialAd);
    }

    return throw Exception("Unable to load $_interstitialAd");
  }

  Future<Ad> _showRewardAd() async {
    if (await _rewardAd.isLoaded) {
      _rewardAd.show();
      return Ad(_rewardAd);
    }

    return throw Exception("Unable to load $_rewardAd");
  }
}