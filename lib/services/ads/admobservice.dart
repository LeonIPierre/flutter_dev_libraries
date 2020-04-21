import 'package:admob_flutter/admob_flutter.dart';
import 'package:dev_libraries/models/ad.dart';
import 'package:dev_libraries/services/ads/adservice.dart';

class AdMobService extends AdService {
  final String _appId;

  Map<String, dynamic> _configuration;
  AdmobInterstitial _interstitialAd;
  AdmobReward _rewardAd;

  AdMobService(this._appId, { Map<String, dynamic> configuration }) {
    this._configuration = configuration;
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

  @override
  Future<Ad> showAd(AdType adType, {List<String> keywords}) async
  {
    switch(adType)
    {
      case AdType.Banner:
        AdmobBanner ad = AdmobBanner(
          adUnitId: _configuration["adUnitId"],
          adSize: AdmobBannerSize.SMART_BANNER,
          listener: (AdmobAdEvent event, Map<String, dynamic> args)  {
          });
        return Ad(ad);
        break;
      case AdType.Interstitial:
        _interstitialAd = AdmobInterstitial(
          adUnitId: _configuration["adUnitId"],
          listener: (AdmobAdEvent event, Map<String, dynamic> args) {
            if (event == AdmobAdEvent.closed) _interstitialAd.load();
          });
          return await _showInterstitialAd();
        break;
      case AdType.Reward:
        _rewardAd = AdmobReward(
          adUnitId: _configuration["adUnitId"],
          listener: (AdmobAdEvent event, Map<String, dynamic> args) {
            if (event == AdmobAdEvent.closed) _rewardAd.load();
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