import 'package:admob_flutter/admob_flutter.dart';
import 'package:dev_libraries/models/ad.dart';
import 'package:dev_libraries/models/adconfiguration.dart';
import 'package:dev_libraries/models/adservice.dart';

class AdMobService extends AdService {
  final String _appId;

  AdmobInterstitial _interstitialAd;
  AdmobReward _rewardAd;

  AdMobService(this._appId) {
    initialize();
  }
  
  @override
  void dispose() {
    _interstitialAd.dispose();
    _rewardAd.dispose();
  }

  @override
  void initialize() {
    Admob.initialize(_appId);
  }

  void loadAd(AdType adType)
  {
    switch(adType)
    {
      case AdType.Banner:
        break;
      case AdType.Interstitial:
        _interstitialAd.load();
        break;
      case AdType.Reward:
        _rewardAd.load();
        break;
      default:
        break;
    }
  }

  @override
  Future<Ad> showAd(AdConfiguration options) async
  {
    switch(options.adType)
    {
      case AdType.Banner:
        AdmobBanner ad = AdmobBanner(
          adUnitId: options.adUnitId,
          adSize: AdmobBannerSize.BANNER,
          listener: (AdmobAdEvent event, Map<String, dynamic> args)  {
            switch (event) {
              case AdmobAdEvent.loaded:
                print('Admob banner loaded!');
              break;
              case AdmobAdEvent.opened:
                print('Admob banner opened!');
              break;
              case AdmobAdEvent.closed:
              print('Admob banner closed!');
              break;
              case AdmobAdEvent.failedToLoad:
                print('Admob banner failed to load. Error code: ${args['errorCode']}');
              break;
              default:
              break;
            }            
          });
          
        return Ad(ad);
        break;
      case AdType.Interstitial:
        _interstitialAd = AdmobInterstitial(
          adUnitId: options.adUnitId,
          listener: (AdmobAdEvent event, Map<String, dynamic> args) {
            //if (event == AdmobAdEvent.closed) _interstitialAd.load();
          });

          return await _showInterstitialAd();
        break;
      case AdType.Reward:
        _rewardAd = AdmobReward(
          adUnitId:  options.adUnitId,
          listener: (AdmobAdEvent event, Map<String, dynamic> args) {
            //if (event == AdmobAdEvent.closed) _rewardAd.load();
          });

          return await _showRewardAd();
        break;
      default:
        return null;
        break;
    }
  }

  Future<Ad> _showInterstitialAd() async {
    if (await _interstitialAd.isLoaded) {
      _interstitialAd.show();
      return Ad(_interstitialAd);
    }

    return null;
  }

  Future<Ad> _showRewardAd() async {
    if (await _rewardAd.isLoaded) {
      _rewardAd.show();
      return Ad(_rewardAd);
    }

    return null;
  }
}