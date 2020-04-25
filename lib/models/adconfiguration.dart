import 'package:dev_libraries/models/adservice.dart';

class AdConfiguration {
  final AdType adType;
  final String adUnitId;
  final List<String> keywords;

  AdConfiguration(this.adType, this.adUnitId, { this.keywords });
}