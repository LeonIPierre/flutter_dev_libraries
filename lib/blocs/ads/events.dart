part of 'adbloc.dart';

enum AdEventId {
  //load
  LoadAd,
  AdLoaded,
  AdRequest,

  StartAdStream,
  EndAdStream,

  /// user interaction events
  AdClosed,
  AdImpression,
  AdClicked,
  AdCompleted,
  
  /// events for usage activity
  UpdateUserActivity,

  UpdateSystemActivity,
  
  /// events for system activity
  AppClosed,

  //error
  AdLoadFailed
}

class AdEvent extends Equatable {
  final AdEventId id;
  final AdConfiguration? adConfiguration;
  final DateTime? timestamp;

  AdEvent(this.id, { this.adConfiguration, DateTime? timestamp }) : timestamp = timestamp ?? DateTime.now();

  AdEvent copy({AdEventId? id, AdConfiguration? configuration}) =>
    AdEvent(id ?? this.id, adConfiguration: configuration ?? this.adConfiguration);

  @override
  List<Object?> get props => [id, adConfiguration];

  @override
  String toString() => 'AdEvent { timestamp: $timestamp, id: $id, configuration: $adConfiguration }';
}

class AdDataPointEvent extends AdEvent {
  final String? name;
  final double value;
  
  AdDataPointEvent(this.value, { this.name, AdConfiguration? adConfiguration, DateTime? timestamp }) 
    : super(AdEventId.UpdateUserActivity, adConfiguration: adConfiguration, timestamp: timestamp);

  @override
  String toString() => 'AdDataPointEvent { timestamp: $timestamp, id: $id, value: $value, configuration: $adConfiguration }';

  @override
  AdDataPointEvent copy({AdEventId? id, AdConfiguration? configuration, double? value}) =>
    AdDataPointEvent(value ?? this.value, adConfiguration: configuration ?? this.adConfiguration);
}