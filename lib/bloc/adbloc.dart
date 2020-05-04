import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:dev_libraries/bloc/states.dart';
import 'package:dev_libraries/models/ad.dart';
import 'package:dev_libraries/models/adconfiguration.dart';
import 'package:dev_libraries/models/adservice.dart';
import 'package:dev_libraries/services/ads/admobservice.dart';
import 'package:rxdart/rxdart.dart';

import 'events.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  final int adIntervalSeconds;
  final double _adMinimumThreshold = 10;

  BehaviorSubject<Ad> ads = BehaviorSubject<Ad>();

  Stream<double> _timerStream;
  BehaviorSubject<AdEvent> _adHistoryStream = BehaviorSubject<AdEvent>();
  BehaviorSubject<double> _usageStream = BehaviorSubject<double>();
  BehaviorSubject<double> _appActivityStream = BehaviorSubject<double>();

  AdService _adService;
  Set<AdType> _visibleAds = Set<AdType>();

  AdBloc(String appId, {AdService adService, this.adIntervalSeconds = 15}) {
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
        event = event.copy(configuration: await _adService
            .loadAd(event.adConfiguration, eventListener: (event) => _adEventCallback(event)));
            
        //creates a stream of ads based on the following streams
        //streams: timer, clicks, app usage, device
        //weight system. weight every interaction, once it reaches a certain
        //threshold reset and start over
        
        //TODO figure out a way to ad the history of the ad stream into the calculation
        ads.addStream(CombineLatestStream.combine4<double, double, double, double, double>(
            _timerStream,
            _usageStream.startWith(0),
            _adHistoryStream.map(_mapEventToValue).startWith(0.0),
            _appActivityStream.startWith(0),
            (timer, usage, history, system) => timer + usage - system
          )
          .where((value) {
            print("Ad threshold value met at $value");
            return value >= _adMinimumThreshold;
          })
          .asyncMap((value) async {
            AdEvent adEvent = _adHistoryStream.value ?? event;
            print("Creating ad event $adEvent");
            return _createAdEvent(adEvent, value);
          })
          .where((adRequest) => adRequest != null)
          .asyncMap((adRequest) async {
            print("Requesting ad $adRequest");
            return _requestAd(adRequest);
          }));
        
        yield AdStreamingState();
        break;
      case AdEventId.UpdateUserActivity:
        var ev = event as UserActivityEvent;
        _usageStream.add(ev.value);
        break;
      case AdEventId.UpdateSystemActivity:
        var ev = event as UserActivityEvent;
        _appActivityStream.add(ev.value);
        break;
      case AdEventId.AdClosed:
        _visibleAds.remove(event.adConfiguration.adType);
        break;
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
    if(_adHistoryStream.value == null)
      return previousEvent;

    double difference = _adMinimumThreshold - value;
    AdType requestedAd = previousEvent.adConfiguration.adType;

    //request a specific ad
    if(difference < .5)
    {
      requestedAd = AdType.Banner;
    }
    else if (difference > .5 && difference < .75)
    {
      requestedAd = difference % 2 != 1 ?  AdType.Interstitial : AdType.InterstitialVideo;
    }
    else if (difference > .75 && difference < .85)
    {
      //requestedAd = difference % 2 != 1 ? AdType.Native : AdType.NativeVideo;
    }
    else if (difference > .85 && difference < .9)
    {
      requestedAd = AdType.Reward;
    }
    else if (difference > .9 && difference < 1)
    {
      //requestedAd = AdType.Internal;
    }

    AdEvent newAdEvent = AdEvent(AdEventId.StreamAd, 
      adConfiguration: previousEvent.adConfiguration.copy(adType: requestedAd));

    if(requestedAd == AdType.Banner && previousEvent == newAdEvent)
    {
      print("New event ignored for being a duplicate $newAdEvent");
      return null;
    }

    return newAdEvent;

    //move up a level
    //use nodes to create a hierarchy
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
    return _adService.requestAd(event.adConfiguration)
              .then((ad) {
                _visibleAds.add(event.adConfiguration.adType);
                _adHistoryStream.add(event);
                return ad;
              });
  }

  void _adEventCallback(AdEventId event) {
    switch(event)
    {
      case AdEventId.AdClosed:
        add(AdEvent(AdEventId.AdClosed));
        break;
      default:
        break;
    }
  }

  void _resetStreams() {
    _timerStream = Stream.periodic(Duration(seconds: adIntervalSeconds)).map((seconds)
    {
      return _adMinimumThreshold;
    });
  }
}