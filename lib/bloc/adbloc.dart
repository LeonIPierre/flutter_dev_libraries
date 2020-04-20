import 'package:bloc/bloc.dart';
import 'package:dev_libraries/bloc/states.dart';
import 'package:dev_libraries/services/ads/adservice.dart';
import 'package:rxdart/rxdart.dart';

import 'events.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  //BehaviorSubject<

  final AdService adService;

  AdBloc(this.adService);

  @override
  AdState get initialState => AdLoadingSate();

  @override
  Stream<AdState> mapEventToState(AdEvent event) async* {
    //create a stream of ads that updates based on time intervals and user
    //interactions
    //start stream
    //update ad
    //stop stream
    //update stream based on user interaction

    switch(event.id)
    {
      case AdEventId.LoadAd:
        var ev = event as AdLoadEvent;
        yield await adService.showAd(ev.adType, keywords: ev.keywords)
                .then((success) => AdIdealState())
                .catchError((error) => AdFailedState());
        break;
      default:
        break;
    }
  }

  void dispose() {
    adService.dispose();
  }
}