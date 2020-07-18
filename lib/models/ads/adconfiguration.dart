import 'package:equatable/equatable.dart';
import 'ad.dart';
import 'adsize.dart';

class AdConfiguration extends Equatable {
  final AdType adType;
  final AdSize adSize;
  final List<String> keywords;

  AdConfiguration(this.adType, { this.adSize, this.keywords });

  AdConfiguration copy({AdType adType, String adUnitId, List<String> keywords }) 
    => AdConfiguration(adType ?? this.adType, keywords: keywords ?? this.keywords);

  @override
  List<Object> get props => [adType, keywords];

  @override
  String toString() => 'AdConfiguration { adType: $adType, keywords: $keywords }';
}