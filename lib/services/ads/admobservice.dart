import 'dart:async';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:dev_libraries/bloc/events.dart';
import 'package:dev_libraries/models/ad.dart';
import 'package:dev_libraries/models/adconfiguration.dart';
import 'package:dev_libraries/models/adservice.dart';
import 'package:dev_libraries/models/adsize.dart';

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

  String getAdUnitId(AdStreamConfiguration adConfiguration) {
    switch (adConfiguration.adType) {
      case AdType.Banner:
        return adConfiguration.adUnitIds["googleAdMob:bannerAdUnitId"];
      case AdType.Interstitial:
        return adConfiguration.adUnitIds["googleAdMob:intersitialAdUnitId"];
      case AdType.InterstitialVideo:
        return adConfiguration.adUnitIds["googleAdMob:intersitialVideoAdUnitId"];
      case AdType.Native:
        return adConfiguration.adUnitIds["googleAdMob:nativeAdUnitId"];
      case AdType.NativeVideo:
        return adConfiguration.adUnitIds["googleAdMob:nativeVideoAdUnitId"];
      case AdType.Reward:
        return adConfiguration.adUnitIds["googleAdMob:rewardAdUnitId"];
      case AdType.Internal:
        return adConfiguration.adUnitIds["googleAdMob:internalAdUnitId"];
      default:
        throw Exception("Invalid adType: ${adConfiguration.adType}");
    }
  }

  @override
  Future<AdConfiguration> loadAd(AdConfiguration configuration,
      {Function(AdEventId) eventListener}) {

    String adUnitId = configuration is AdStreamConfiguration
        ? getAdUnitId(configuration)
        : configuration.adUnitId;
    Completer<AdConfiguration> completer = Completer();

    switch (configuration.adType) {
      case AdType.Banner:
        _bannerAd = AdmobBanner(
            adUnitId: adUnitId,
            adSize: configuration.adSize == null ? AdmobBannerSize.BANNER : _mapToAdSize(configuration.adSize),
            listener: (AdmobAdEvent event, Map<String, dynamic> args) {
              if(eventListener != null)
                eventListener(_mapToAdEventId(event));
            });
        
        completer.complete(Future(() => configuration));
        break;
      case AdType.Interstitial:
      case AdType.InterstitialVideo:
        _interstitialAd = AdmobInterstitial(
            adUnitId: adUnitId,
            listener: (AdmobAdEvent event, Map<String, dynamic> args) {
              if(eventListener != null)
                eventListener(_mapToAdEventId(event));
            });

        completer.complete(Future(() {
          _interstitialAd.load();
          return configuration;
        }));
        break;
      case AdType.Reward:
        _rewardAd = AdmobReward(
            adUnitId: adUnitId,
            listener: (AdmobAdEvent event, Map<String, dynamic> args) {
              if(eventListener != null)
                eventListener(_mapToAdEventId(event));
            });

        completer.complete(Future(() {
          _rewardAd.load();
          return configuration;
        }));
        break;
      default:
        break;
    }

    return completer.future;
  }

  @override
  Future<Ad> requestAd(AdConfiguration configuration) async {
    switch (configuration.adType) {
      case AdType.Banner:
        return Ad(_bannerAd);
      case AdType.Interstitial:
        return await _showInterstitialAd();
      case AdType.Reward:
        return await _showRewardAd();
      default:
        return throw Exception("Invalid request type: ${configuration.adType}");
    }
  }

  AdmobBannerSize _mapToAdSize(AdSize adSize) => AdmobBannerSize(height: adSize.height, width: adSize.width);
  
  AdEventId _mapToAdEventId(AdmobAdEvent eventId) {
    switch(eventId)
    {
      case AdmobAdEvent.closed:
        return AdEventId.AdClosed;
      case AdmobAdEvent.loaded:
        return AdEventId.AdLoaded;
      case AdmobAdEvent.failedToLoad:
      //case AdmobAdEvent.completed
      //case AdmobAdEvent.leftApplication:
        return throw Exception("Failed to load ad");
      default:
        return throw Exception("Invalid event type: $eventId");
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
