import 'package:dev_libraries/blocs/ads/adbloc.dart';
import 'package:dev_libraries/models/ads/ad.dart';

import 'adconfiguration.dart';

abstract class AdService {
  void initialize(String appId);

  AdConfiguration loadAd(AdConfiguration configuration, { Function(AdEventId) eventListener });

  Future<AdConfiguration> loadAdAsync(AdConfiguration configuration, { Function(AdEventId, AdConfiguration) eventListener });

  Future<Ad> requestAd(AdConfiguration configuration);

  void dispose();
}