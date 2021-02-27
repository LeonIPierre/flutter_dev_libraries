import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:dev_libraries/contracts/ads/adservice.dart';
import 'package:dev_libraries/models/ads/ads.dart';
import 'package:dev_libraries/models/node.dart';
import 'package:dev_libraries/services/ads/admobservice.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

part 'states.dart';
part 'events.dart';

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

  /// application activities like sleep, exiting etc
  BehaviorSubject<AdDataPointEvent> _appActivityStream = BehaviorSubject<AdDataPointEvent>();

  StreamSubscription _algorithmSubscription;

  AdService _adService;

  Set<AdType> _visibleAds = Set<AdType>();

  Node<AdType> _currentAdNode;

  double _minValue = 0;

  double _maxValue = 0;

  AdBloc(String appId, {AdService adService, Map<String, dynamic> configuration, this.adIntervalSeconds = 30}) : super(AdLoadingState()) {
    Map<String, dynamic> adUnitIds = Map.from(configuration)..removeWhere((k, v) => !k.contains("AdUnitId"));
    this._adService = adService ?? AdMobService(appId, adUnitIds); 
  }

  @override
  Stream<AdState> mapEventToState(AdEvent event) async* {  
    switch(event.id)
    {
      case AdEventId.LoadAd:
        yield await _adService.loadAdAsync(event.adConfiguration, 
          eventListener: (event, config) => _mapAdEventCallback(event, config))
          .then((configuration) => _requestAd(event.copy(configuration: configuration)))
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
          
          //print("[USER] [output] $output = [value] $value - [timer] $timer - [system] $system");
          return output;
        })
        .where((value) => value != 0 && _meetsMinimumThreshold(value))
        .asBroadcastStream();

        var means = usage
          .scan((double accumulated, value, index) {
            return index == 0 ? value : accumulated + (value - accumulated) / index;
          })
          .asBroadcastStream();

        var samples = usage
          //sample 
          .zipWith(means.pairwise(), (value, means) {
             return (value - means[0]) * (value - means[1]);
          })
          .scan((double accumulated, value, index) {
            return accumulated + value;
          }, 0.0);

        var variance = samples
          .scan((accumulated, value, index) {
            return index > 1 ? value / (index -1) : 0.0;
          });
        
        var standardDeviation = variance
        .map((value) => sqrt(value))
        .where((value) => !value.isNaN && !value.isInfinite && value != 0);

        //TODO: show ads based on desired revenue?? (working backwords)
        _algorithmSubscription = CombineLatestStream
        .combine4(
          usage,
          means, variance, standardDeviation,
        (double value, double mean, double variance, double standardDeviation) {
          //var zscore = (mean - value) / standardDeviation;
          //print("(ANALYSIS [zscore] = ([mean] - [usage]) / [standard deviation]) | $zscore = ($mean - $value) / $standardDeviation");

          _minValue = value < _minValue ? value : _minValue;
          _maxValue = value > _maxValue ? value : _maxValue;

          //min-max normalization
          var normalizedOutput = (AdType.values.length + AdType.values.length) 
            * ((value - _minValue) / (_maxValue - _minValue)) -AdType.values.length;

          print("[normalizedOutput] $normalizedOutput | [mean] $mean | [variance] $variance | [standardDeviation] $standardDeviation");
          //print("(ANALYSIS [normalizedOutput] = (b - a) * (value - _minValue / (_maxValue - _minValue) + a))"
          //+ "| $normalizedOutput = (($b - $a) * $value - $_minValue)) / ($_maxValue - $_minValue) + $a");

          return normalizedOutput;
        })
        .distinct()
        .throttle((event) => TimerStream(true, Duration(milliseconds: 300)), trailing: true)
        .asyncMap((value) async => await _createAdEvent(_adHistoryStream.values.last ?? event, value.round()))
        .where((adRequest) => _isAdRequestValid(adRequest))
        .listen((event) { add(event); });
        
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
    _algorithmSubscription.cancel();
    return super.close();
  }

  /// Creates a new AdEvent based on a previous one based on the difference in "ad value".
  /// Ads operate in a hierachy and either move a level up or down. 
  /// Cheap ads are shown often, expensive ones very little
  /// TODO: create adaptive ad profiling based on the user activities
  Future<AdEvent> _createAdEvent(AdEvent previousEvent, int value) async {
    //or AdType.values[value]?
    _currentAdNode = _currentAdNode.move(value);

    return _adService.loadAdAsync(
      previousEvent.adConfiguration.copy(adType: _currentAdNode.value), 
      eventListener: (event, configuration) => _mapAdEventCallback(event, configuration))
      .then((configuration) {
        AdEvent newAdEvent = previousEvent.copy(id: AdEventId.AdRequest, configuration: configuration);
        print("CREATED: $newAdEvent");
        return newAdEvent;
      });
  }

  bool _isAdRequestValid(AdEvent ad) {
    if(_visibleAds.contains(ad.adConfiguration.adType))
    {
      print("SHOWING: $ad");
      return false;
    }

    var prevAdRequest = _adHistoryStream.values
      .lastWhere((event) {
         return event.adConfiguration.adType == ad.adConfiguration.adType;
      }, orElse: () => null);

    if(prevAdRequest == null)
    {
      print("Request validated: $ad");
      return true;
    }

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

  AdDataPointEvent _mapUsageEventToRate(AdDataPointEvent prev, AdDataPointEvent current, [double optimal = 4.0, double min = -10.0, double max = 10.0]) {
    if(prev == null)
      return current;
    
    var timeDifference = (current.timestamp.millisecondsSinceEpoch - prev.timestamp.millisecondsSinceEpoch) / 1000;

    var rate = timeDifference / optimal;
    /// inverse relationship with ads. high, fast paced usage (low time difference) = low ad show rate
    var value = (current.value * rate).abs();

    if(value < min)
     value = min;

    if(value > max)
      value = max;
    
    return AdDataPointEvent(value, timestamp: DateTime.now());
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

  void _mapAdEventCallback(AdEventId event, AdConfiguration configuration) {
    switch(event)
    {
      case AdEventId.AdClosed:
        add(AdEvent(AdEventId.AdClosed, adConfiguration: configuration));
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