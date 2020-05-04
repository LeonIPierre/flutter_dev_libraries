import 'package:dev_libraries/dev_libraries.dart';
import 'package:dev_libraries/models/adconfiguration.dart';
import 'package:equatable/equatable.dart';

enum AdEventId {
  //load
  LoadAd,
  AdLoaded,

  StartAdStream,
  StreamAd,
  EndAdStream,

  //user interaction events
  AdClosed,
  AdImpression,
  AdClicked,
  
  //events for usage activity
  UpdateUserActivity,

  UpdateSystemActivity,
  
  //events for system activity
  AppClosed,

  //error
  AdLoadFailed
}

class AdEvent extends Equatable {
  final AdEventId id;
  final AdConfiguration adConfiguration;

  AdEvent(this.id, { this.adConfiguration });

  AdEvent copy({AdEventId id, AdConfiguration configuration}) =>
    AdEvent(id ?? this.id, adConfiguration: configuration ?? this.adConfiguration);

  @override
  List<Object> get props => [id, adConfiguration];

  @override
  String toString() => 'AdEvent { id: $id, configuration: $adConfiguration }';
}

class UserActivityEvent extends AdEvent{
  final double value;
  UserActivityEvent(AdEventId id, this.value) : super(AdEventId.UpdateUserActivity);
}

class SystemActivityEvent extends AdEvent{
  final double value;
  SystemActivityEvent(AdEventId id, this.value) : super(AdEventId.UpdateSystemActivity);
}