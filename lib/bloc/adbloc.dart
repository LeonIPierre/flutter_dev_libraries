import 'package:bloc/bloc.dart';
import 'package:dev_libraries/bloc/states.dart';
import 'package:dev_libraries/models/ad.dart';
import 'package:dev_libraries/models/adservice.dart';
import 'package:dev_libraries/services/ads/admobservice.dart';
import 'package:rxdart/rxdart.dart';

import 'events.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  BehaviorSubject<Ad> ads = BehaviorSubject<Ad>();

  AdService _adService;

  AdBloc(String appId, {AdService adService}) {
    this._adService = adService ?? AdMobService(appId); 
  }

  @override
  AdState get initialState => AdLoadingSate();

  @override
  Stream<AdState> mapEventToState(AdEvent event) async* {  
    switch(event.id)
    {
      case AdEventId.LoadAd:
        var ev = event as AdLoadEvent;
        yield await _adService.showAd(ev.adConfiguration)
                .then((ad) {
                  ads.add(ad);
                  return AdIdealState(ad);
                })
                .catchError((error) => AdFailedState());
        break;
      case AdEventId.StartAdStream:
        var ev = event as AdLoadEvent;
        ads = Stream.periodic(Duration(seconds: 10), (x) => x).asyncMap((seconds) async {
          return await _adService.showAd(ev.adConfiguration)
                .catchError((error) => {
                  //do something with the error
                });
        });
        break;
      case AdEventId.EndAdStream:
        ads.close();
        break;
      default:
        break;
    }
  }

  void startAds() {
    //create a stream of ads that updates based on time intervals and user interactions
    //start stream
    //update ad
    //stop stream
    //update stream based on user interaction
  }

  void dispose() {
    _adService.dispose();
    ads.close();
  }
}