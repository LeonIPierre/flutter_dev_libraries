import 'package:dev_libraries/bloc/adbloc.dart';
import 'package:dev_libraries/bloc/events.dart';
import 'package:dev_libraries/models/ad.dart';
import 'package:dev_libraries/models/adconfiguration.dart';
import 'package:dev_libraries/models/adservice.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mockadservice.dart';

void main() {
  
  group('AdBloc', () {
    AdBloc adBloc;
    AdService mockAdService = MockAdMobService();
    AdConfiguration configuration;
    
    setUp(() {
      configuration = AdConfiguration(AdType.Banner, "");
      adBloc = AdBloc("", adService: mockAdService);
      when(mockAdService.loadAd(configuration)).thenAnswer((_) => Future.value(configuration));
      when(mockAdService.requestAd(configuration)).thenAnswer((_) => Future.value(Ad(null)));
    });

    test('run ad algorithm',
    () {
      expectLater(adBloc.ads.stream, <Matcher>[
        predicate((Ad ad) => ad != null)
        //predicate((Ad ad) => ad == Ad(null)),
        //emitsDone
      ]);

      adBloc.add(AdEvent(AdEventId.StartAdStream, adConfiguration: configuration));
    });

    tearDown(()
    {
      adBloc.close();
    });
  });
  
}