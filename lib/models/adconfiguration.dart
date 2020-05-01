import 'package:dev_libraries/models/adservice.dart';

class AdConfiguration {
  final AdType adType;
  final String adUnitId;
  final List<String> keywords;

  AdConfiguration(this.adType, this.adUnitId, { this.keywords });
}

class AdStreamConfiguration extends AdConfiguration {
  final Map<String, dynamic> adUnitIds;
  AdStreamConfiguration(AdType firstAdType, this.adUnitIds, { List<String> keywords }) : super(firstAdType, "", keywords: keywords);
}