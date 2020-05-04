import 'package:dev_libraries/models/adservice.dart';
import 'package:equatable/equatable.dart';

class AdConfiguration extends Equatable {
  final AdType adType;
  final String adUnitId;
  final List<String> keywords;

  AdConfiguration(this.adType, this.adUnitId, { this.keywords });

  AdConfiguration copy({AdType adType, String adUnitId, List<String> keywords }) 
    => AdConfiguration(adType ?? this.adType, adUnitId ?? this.adUnitId, keywords: keywords ?? this.keywords);

  @override
  List<Object> get props => [adType, adUnitId, keywords];

  @override
  String toString() => 'AdConfiguration { adType: $adType, unitId: $adUnitId, keywords: $keywords }';
}

class AdStreamConfiguration extends AdConfiguration {
  final Map<String, dynamic> adUnitIds;
  AdStreamConfiguration(AdType firstAdType, this.adUnitIds, { List<String> keywords }) : super(firstAdType, "", keywords: keywords);

  @override
  List<Object> get props => [adType, adUnitIds, keywords];

  @override
  String toString() => 'AdStreamConfiguration { adType: $adType, unitIds: $adUnitIds, keywords: $keywords }';
}