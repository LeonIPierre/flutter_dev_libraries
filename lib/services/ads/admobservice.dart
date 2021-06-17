import 'dart:async';
import 'dart:math';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:dev_libraries/blocs/ads/adbloc.dart';
import 'package:dev_libraries/contracts/ads/adservice.dart';
import 'package:dev_libraries/models/ads/ad.dart';
import 'package:dev_libraries/models/ads/adconfiguration.dart';
import 'package:dev_libraries/models/ads/adsize.dart';

class AdMobService extends AdService {
  late AdmobBanner _bannerAd;
  late AdmobInterstitial _interstitialAd;
  late AdmobReward _rewardAd;
  final Map<String, dynamic> _adUnitIds;

  AdMobService(String appId, this._adUnitIds) {
    //initialize(appId);
  }

  @override
  void dispose() {
    _interstitialAd.dispose();
    _rewardAd.dispose();
  }

  @override
  void initialize(String appId) {
    Admob.initialize();
  }

  @override
  AdConfiguration loadAd(AdConfiguration configuration,
      {Function(AdEventId)? eventListener}) {
    String adUnitId = _getAdUnitId(configuration.adType, _adUnitIds);

    switch (configuration.adType) {
      case AdType.Banner:
        _bannerAd = AdmobBanner(
            adUnitId: adUnitId,
            adSize: configuration.adSize == null
                ? AdmobBannerSize.BANNER
                : _mapToAdSize(configuration.adSize!),
            listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
              if (eventListener != null) eventListener(_mapToAdEventId(event));
            });
        break;
      case AdType.Interstitial:
      case AdType.InterstitialVideo:
        _interstitialAd = AdmobInterstitial(
            adUnitId: adUnitId,
            listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
              if (eventListener != null) eventListener(_mapToAdEventId(event));
            });
        _interstitialAd.load();
        break;
      case AdType.Reward:
        _rewardAd = AdmobReward(
            adUnitId: adUnitId,
            listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
              if (eventListener != null) eventListener(_mapToAdEventId(event));
            });
        _rewardAd.load();
        break;
      default:
        break;
    }

    return configuration;
  }

  @override
  Future<AdConfiguration?> loadAdAsync(AdConfiguration configuration,
      {Function(AdEventId, AdConfiguration)? eventListener}) {
    String adUnitId = _getAdUnitId(configuration.adType, _adUnitIds);
    Completer<AdConfiguration> completer = Completer<AdConfiguration>();

    switch (configuration.adType) {
      case AdType.Banner:
        return Future.value(_bannerAd = AdmobBanner(
                adUnitId: adUnitId,
                adSize: configuration.adSize == null
                    ? AdmobBannerSize.BANNER
                    : _mapToAdSize(configuration.adSize!),
                listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
                  if (eventListener != null)
                    eventListener(_mapToAdEventId(event), configuration);
                }))
            .then((_) => configuration);
      case AdType.Interstitial:
      case AdType.InterstitialVideo:
        var ad = Future.value(_interstitialAd = AdmobInterstitial(
                adUnitId: adUnitId,
                listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
                  if (eventListener != null)
                    completer.complete(
                        eventListener(_mapToAdEventId(event), configuration));
                }))
            .then((ad) {
          ad.load();
          return configuration;
        });

        return Future.wait([ad, completer.future]).then((value) => value.last);
      case AdType.Reward:
        return Future.wait([
          Future.value(_rewardAd = AdmobReward(
                  adUnitId: adUnitId,
                  listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
                    if (eventListener != null)
                      completer.complete(
                          eventListener(_mapToAdEventId(event), configuration));
                  }))
              .then((value) => configuration),
          completer.future
        ]).then((value) => value.last);
      case AdType.Internal:
        return Future.value(configuration);
      default:
        return throw Exception("Invalid request type: ${configuration.adType}");
    }
  }

  @override
  Future<Ad> requestAd(AdConfiguration configuration) async {
    switch (configuration.adType) {
      case AdType.Banner:
        return Ad(_bannerAd);
      case AdType.Interstitial:
        return _showInterstitialAd(_interstitialAd);
      case AdType.Reward:
        return _showRewardAd(_rewardAd);
      default:
        return throw Exception("Invalid request type: ${configuration.adType}");
    }
  }

  String _getAdUnitId(AdType adType, Map<String, dynamic> adUnitIds) {
    switch (adType) {
      case AdType.Banner:
        return adUnitIds["googleAdMob:bannerAdUnitId"];
      case AdType.Interstitial:
        return adUnitIds["googleAdMob:intersitialAdUnitId"];
      case AdType.InterstitialVideo:
        return adUnitIds["googleAdMob:intersitialVideoAdUnitId"];
      case AdType.Native:
        return adUnitIds["googleAdMob:nativeAdUnitId"];
      case AdType.NativeVideo:
        return adUnitIds["googleAdMob:nativeVideoAdUnitId"];
      case AdType.Reward:
        return adUnitIds["googleAdMob:rewardAdUnitId"];
      case AdType.Internal:
        return adUnitIds["googleAdMob:internalAdUnitId"];
      default:
        throw Exception("Invalid adType: $adType");
    }
  }

  /// maps the requested ad size to the closest ad mob banner size
  AdmobBannerSize _mapToAdSize(AdSize adSize) {
    var ads = [
      AdmobBannerSize.ADAPTIVE_BANNER(width: adSize.width),
      AdmobBannerSize.BANNER,
      AdmobBannerSize.FULL_BANNER,
      AdmobBannerSize.MEDIUM_RECTANGLE,
      AdmobBannerSize.LARGE_BANNER,
      AdmobBannerSize.LEADERBOARD
    ];

    var requestedSize = Point(adSize.height, adSize.width);
    var min = double.maxFinite;
    var output;

    for (int i = 0; i < ads.length; i++) {
      var point = ads[i];
      var distance = Point(point.height, point.width).distanceTo(requestedSize);
      if (distance > min) continue;

      min = distance;
      output = point;
    }

    return output;
  }

  AdEventId _mapToAdEventId(AdmobAdEvent eventId) {
    switch (eventId) {
      case AdmobAdEvent.closed:
        return AdEventId.AdClosed;
      case AdmobAdEvent.loaded:
        return AdEventId.AdLoaded;
      case AdmobAdEvent.leftApplication:
        return AdEventId.AppClosed;
      case AdmobAdEvent.failedToLoad:
        return AdEventId.AdLoadFailed;
      case AdmobAdEvent.completed:
        return AdEventId.AdCompleted;
      case AdmobAdEvent.impression:
        return AdEventId.AdImpression;
      case AdmobAdEvent.clicked:
        return AdEventId.AdClicked;
      //case AdmobAdEvent.opened:
      //case AdmobAdEvent.rewarded:
      //case AdmobAdEvent.started:
      default:
        return throw Exception("Invalid event type: $eventId");
    }
  }

  Future<Ad> _showInterstitialAd(AdmobInterstitial interstitialAd) async =>
      await interstitialAd.isLoaded.then((value) {
        if (value!) {
          interstitialAd.show();
          return Ad(interstitialAd);
        }

        return throw Exception("Unable to load $interstitialAd");
      });

  Future<Ad> _showRewardAd(AdmobReward rewardAd) async =>
      await rewardAd.isLoaded.then((value) {
        if (value) {
          rewardAd.show();
          return Ad(rewardAd);
        }

        throw Exception("Unable to load $rewardAd");
      });
}
