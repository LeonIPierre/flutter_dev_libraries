import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dev_libraries/bloc/states.dart';
import 'package:dev_libraries/models/ad.dart';
import 'package:dev_libraries/models/adconfiguration.dart';
import 'package:dev_libraries/models/adservice.dart';
import 'package:dev_libraries/services/ads/admobservice.dart';
import 'package:rxdart/rxdart.dart';

import 'events.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  final int _adIntervalSeconds = 15;
  final double _adMinimumThreshold = 10;

  BehaviorSubject<Ad> ads = BehaviorSubject<Ad>();

  Stream<double> _timerStream;
  BehaviorSubject<AdEvent> _adHistoryStream = BehaviorSubject<AdEvent>();
  BehaviorSubject<double> _usageStream = BehaviorSubject<double>();
  BehaviorSubject<double> _appActivityStream = BehaviorSubject<double>();

  AdService _adService;
  Set<AdType> _visibleAds = Set<AdType>();

  AdBloc(String appId, {AdService adService}) {
    this._adService = adService ?? AdMobService(appId); 
  }

  @override
  AdState get initialState => AdLoadingState();

  @override
  Stream<AdState> mapEventToState(AdEvent event) async* {  
    switch(event.id)
    {
      case AdEventId.LoadAd:
        yield await _requestAd(event)
                .then((ad) {
                  ads.add(ad);
                  return AdIdealState(ad);
                })
                .catchError((error) {
                  return AdFailedState();
                });
        break;
      case AdEventId.StartAdStream:
        _resetStreams();
        //creates a stream of ads based on the following streams
        //streams: timer, clicks, app usage, device
        //weight system. weight every interaction, once it reaches a certain
        //threshold reset and start over

        ads.addStream(CombineLatestStream.combine4<double, double, double, double, double>(
            _timerStream.startWith(_adMinimumThreshold),
            _usageStream.startWith(0),
            _adHistoryStream.map(_mapEventToValue).startWith(0),
            _appActivityStream.startWith(0),
            (timer, usage, adHistory, system) => timer + usage + adHistory - system
          )
          .where((value) => value >= _adMinimumThreshold)
          .asyncMap((value) async => _createAdEvent(await _adHistoryStream.last, value))
          .where((adRequest) => adRequest != null)
          .asyncMap((adRequest) async => _requestAd(adRequest)));
        
        yield AdStreamingState();
        break;
      case AdEventId.UpdateAdImpressions:
        break;
      case AdEventId.CloseAd:
      case AdEventId.EndAdStream:
        _visibleAds.remove(event.adConfiguration.adType);
        close();
        break;
      default:
        break;
    }
  }

  @override
  Future<void> close() {
    ads.close();
    _adService.dispose();
    return super.close();
  }

  /// Creates a new AdEvent based on a previous ad event
  /// based on the difference in ad value
  /// either move a level up or down to create a new ad
  /// ads operate in a hierachy
  /// cheap ads are shown often, expensive ones very little
  /// create adaptive ad profiling
  Future<AdEvent> _createAdEvent(AdEvent previousEvent, double value) async {
    AdStreamConfiguration configuration;
    var difference = _adMinimumThreshold - value;

    //request a specific ad
    if(difference < .5)
    {
      var adUnitId = configuration.adUnitIds["googleAdMob:bannerAdUnitId"];
      configuration = AdStreamConfiguration(AdType.Banner, adUnitId, keywords: previousEvent.adConfiguration.keywords);
    }
    else if (difference > .5 && difference < .75)
    {
      var adUnitId = configuration.adUnitIds["googleAdMob:intersitialAdUnitId"];
      configuration = AdStreamConfiguration(AdType.Interstitial, adUnitId, keywords: previousEvent.adConfiguration.keywords);
    }
    else if (difference > .75 && difference < .85)
    {
      var adUnitId = configuration.adUnitIds["googleAdMob:nativeAdUnitId"];
      configuration = AdStreamConfiguration(AdType.Native, adUnitId, keywords: previousEvent.adConfiguration.keywords);
    }
    else if (difference > .85 && difference < .9)
    {
      var adUnitId = configuration.adUnitIds["googleAdMob:rewardAdUnitId"];
      configuration = AdStreamConfiguration(AdType.Reward, adUnitId, keywords: previousEvent.adConfiguration.keywords);
    }
    else if (difference > .9 && difference < 1)
    {
      var adUnitId = configuration.adUnitIds["googleAdMob:internalAdUnitId"];
      configuration = AdStreamConfiguration(AdType.Internal, adUnitId, keywords: previousEvent.adConfiguration.keywords);
    }

    return AdEvent(AdEventId.StreamAd, adConfiguration: configuration); 

    //AdType nextAd = previousEvent.adConfiguration.adType;
    //move up a level
    // if(previousEvent.adConfiguration.adType == AdType.Banner)
    //   configuration = AdConfiguration(AdType.Interstitial, "", keywords: previousEvent.adConfiguration.keywords);
    // else if(previousEvent.adConfiguration.adType == AdType.Interstitial)
    //   configuration = AdConfiguration(AdType.Native, "", keywords: previousEvent.adConfiguration.keywords);
    // else if(previousEvent.adConfiguration.adType == AdType.Native)
    //   configuration = AdConfiguration(AdType.Internal, "", keywords: previousEvent.adConfiguration.keywords);

    //for banner ads do not issue a new request because they handle their own issues
    // switch(nextAd)
    // {
    //   case AdType.Interstitial:
    //     return AdEvent(AdEventId.StreamAd, adConfiguration: AdConfiguration(AdType.Interstitial, 
    //       "", keywords: previousEvent.adConfiguration.keywords));
    //     break;
    //   case AdType.Banner: //banner ads issue new requests themselves or is this just admob?
    //     if(await _adHistoryStream.length == 0) {
    //       return previousEvent;
    //     }
    //     return null;
    //   default:
    //     return null;
    // }
  }

  double _mapEventToValue(AdEvent event) {
    return 0;
  }

  Future<Ad> _requestAd(AdEvent event) async {
    return _adService
              .loadAd(event.adConfiguration)
              .requestAd(event.adConfiguration)
              .then((ad) {
                _visibleAds.add(event.adConfiguration.adType);
                _adHistoryStream.add(event);
                return ad;
              });
  }

  void _resetStreams() {
    //_appActivityStream?.close();

    //_usageStream?.close();

    _timerStream = Stream.periodic(Duration(seconds: _adIntervalSeconds)).map((seconds)
    {
      return -_adMinimumThreshold;
    });
  }
}