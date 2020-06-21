import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:dev_libraries/bloc/states.dart';
import 'package:dev_libraries/models/ad.dart';
import 'package:dev_libraries/models/adconfiguration.dart';
import 'package:dev_libraries/models/adservice.dart';
import 'package:dev_libraries/models/adstats.dart';
import 'package:dev_libraries/models/node.dart';
import 'package:dev_libraries/services/ads/admobservice.dart';
import 'package:queries/collections.dart';
import 'package:rxdart/rxdart.dart';

import 'events.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  final int adIntervalSeconds;
  final double _adMinimumThreshold = 10;

  BehaviorSubject<Ad> ads = BehaviorSubject<Ad>();

  /// timer of how often ads should show. Defaults to ${adIntervalSeconds}
  Stream<double> _timerStream;

  /// history of ads events requested and shown
  ReplaySubject<AdEvent> _adHistoryStream = ReplaySubject<AdEvent>();

  /// user application usage
  BehaviorSubject<AdDataPointEvent> _usageStream = BehaviorSubject<AdDataPointEvent>();

  /// application activities like going to sleep, exiting etc
  BehaviorSubject<AdDataPointEvent> _appActivityStream = BehaviorSubject<AdDataPointEvent>();

  AdService _adService;

  Set<AdType> _visibleAds = Set<AdType>();

  Node<AdType> _currentAdNode;

  AdBloc(String appId, {AdService adService, this.adIntervalSeconds = 30}) {
    this._adService = adService ?? AdMobService(appId); 
  }

  @override
  AdState get initialState => AdLoadingState();

  @override
  Stream<AdState> mapEventToState(AdEvent event) async* {  
    switch(event.id)
    {
      case AdEventId.LoadAd:
        event = event.copy(configuration: await _adService
            .loadAd(event.adConfiguration, eventListener: (event) => _mapAdEventCallback(event)));

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
            .loadAd(event.adConfiguration, eventListener: (event) => _mapAdEventCallback(event)));
        _currentAdNode = AdTypeNode.init();
            
        //creates a stream of ads based on the following streams
        //streams: timer, clicks, app usage, device
        //weight system. weight every interaction, once it reaches a certain
        //threshold reset and start over
        //for every usage event create a "rate of usage"
        //take the timestamp and value
        var usage = Rx.combineLatest([
          _timerStream.startWith(0.0),
          
          _usageStream /// usage rate
            .scan((prev, curr, i) => AdDataPointEvent(_mapUsageEventToRate(prev, curr).value))
            .map((event) => event.value)
            .startWith(0.0),
            
          _appActivityStream.map(_mapAppActivity).startWith(0.0),
        ], (List<double> streams) {
          double timer = streams[0];
          double value = streams[1];
          double system = streams[2];

          double output = value - timer - system;
          
          print("[USER] [output] $output = [value] $value - [timer] $timer - [system] $system");
          return output;
        })
        .where((value) => value != 0 && _meetsMinimumThreshold(value))
        .asBroadcastStream();

        var mean = usage
          .scan((double accumulated, value, index) {
            return index == 0 ? value : accumulated + (value - accumulated) / index;
          })
          .asBroadcastStream();

        var sample = usage
          //sample 
          .zipWith(mean.pairwise(), (value, means) {
             return (value - means[0]) * (value - means[1]);
          })
          .scan((double accumulated, value, index) {
            return accumulated + value;
          }, 0.0);

        var variance = sample
          .scan((accumulated, value, index) {
            return index > 1 ? value / (index -1) : 0.0;
          });
        
        var standardDeviation = variance.map((value) => sqrt(value))
          .where((value) => value != 0);

        //show ads based on desired revenue?? (work backwords)
        var adStream = CombineLatestStream
        .combine4(usage, mean, variance, standardDeviation, (double a, double b, double c, double d) {
          //based on variance generate a new random
          //how far is the value outside of the standard deviation
          int value = ((b - a) / d).round();
          print("(ANALYSIS [value] = ([mean] - [usage]) / [standard deviation]) | $value = ($b - $a) / $d");
          return value;
        })
        .distinct()
        .map((value) => _createAdEvent(_adHistoryStream.values.last ?? event, value))
        .where((adRequest) => _isAdRequestValid(adRequest))
        .asyncMap((adRequest) async => await _requestAd(adRequest));
        
        ads.addStream(adStream);
        
        yield AdStreamingState();
        break;
      case AdEventId.UpdateUserActivity:
        _usageStream.add(event);
        break;
      case AdEventId.UpdateSystemActivity:
        _appActivityStream.add(event);
        break;
      case AdEventId.AdClosed:
        _visibleAds.remove(event.adConfiguration.adType);
        break;
      case AdEventId.EndAdStream:
        _visibleAds.clear();
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

  /// Creates a new AdEvent based on a previous one based on the difference in "ad value".
  /// Ads operate in a hierachy and either move a level up or down. 
  /// Cheap ads are shown often, expensive ones very little
  /// TODO: create adaptive ad profiling based on the user activitys
  AdEvent _createAdEvent(AdEvent previousEvent, int value) {
    _currentAdNode = _currentAdNode.move(value);

    AdEvent newAdEvent = previousEvent.copy(id: AdEventId.AdRequest, 
      configuration: previousEvent.adConfiguration.copy(adType: _currentAdNode.value));
    
    return newAdEvent;
  }

  bool _isAdRequestValid(AdEvent ad) {
    if(_visibleAds.contains(ad.adConfiguration.adType))
    {
      print("ALREADY SHOWING: $ad");
      return false;
    }

    //ad must also not have been shown recently
     var prevAdRequest = _adHistoryStream.values
      .lastWhere((event) => event.adConfiguration.adType == ad.adConfiguration.adType, orElse: null);

    if(prevAdRequest == ad)
    {
      print("DUPLICATE: $ad");
      return false;
    }

    if(prevAdRequest.timestamp.difference(DateTime.now()) < Duration(seconds: 15))
    {
      print("WITHIN_THRESHOLD: $prevAdRequest");
      return false;
    }

    print("Request validated: $ad");
    return true;
  }

  /// check that the user data meets a minimum threshold
  bool _meetsMinimumThreshold(double value) {
    return true;
  }

  double _mapEventToValue(AdEvent event) {
    return 0;
  }

  AdDataPointEvent _mapUsageEventToRate(AdDataPointEvent prev, AdDataPointEvent current) {
    if(prev == null)
      return current;
    
    var optimal = 6.0;
    var timeDifference = (current.timestamp.millisecondsSinceEpoch - prev.timestamp.millisecondsSinceEpoch) / 1000;
    //TODO change 6.0 to configuration variable
    var rate = timeDifference / optimal;
    /// inverse relationship with ads. high, fast paced usage (low time difference) = low ad show rate
    var value = (current.value * rate).abs() -1.0;
    
    return AdDataPointEvent(value, timestamp: current.timestamp);
  }
  
  double _mapAppActivity(AdDataPointEvent event) {
    return 0;
  }

  Future<Ad> _requestAd(AdEvent event) async {
    return _adService.requestAd(event.adConfiguration)
              .then((ad) {
                print("Requesting ad $event");
                _visibleAds.add(event.adConfiguration.adType);
                _adHistoryStream.add(event);
                return ad;
              });
  }

  void _mapAdEventCallback(AdEventId event) {
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