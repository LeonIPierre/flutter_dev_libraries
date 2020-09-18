import 'package:bloc/bloc.dart';
import 'package:dev_libraries/models/logging/logging.dart';
import 'package:dev_libraries/services/analytics/analyticsservice.dart';
import 'package:dev_libraries/services/logging/logservice.dart';

class DefaultBlocObserver extends BlocObserver {
  final AnalyticsService _analyticsService;
  final LogService _loggingService;

  DefaultBlocObserver({AnalyticsService analyticsService, LogService loggingService})
    : _analyticsService = analyticsService, _loggingService = loggingService;

  // @override
  // void onEvent(Bloc bloc, Object event) {
  //   super.onEvent(bloc, event);

  //   if(!(event is LoggableEvent)) return;

  //   var loggedEvent = event as LoggableEvent;

  //   var parameters = Map<String, dynamic>();
  //   //need a uniqiue id to map to a "user session"
  //   parameters.putIfAbsent("event", () => loggedEvent.toString());

  //   //convert the state logs to a generic log to pass to service
  //   parameters.addAll(loggedEvent.toLogState());

  //   _analyticsService?.send(event.toString(), parameters);
  // }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    
    if(!(transition.nextState is LoggableState) && !(transition.event is LoggableEvent)) return;

    var event = transition.event as LoggableEvent;
    var parameters = Map<String, dynamic>();
    //need a uniqiue id to map to a "user session"
    parameters.putIfAbsent("event", () => transition.event.toString());

    //convert the state logs to a generic log to pass to service
    parameters.addAll(event.toLogState());

    _analyticsService?.send(transition.event.toString(), parameters);
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    super.onError(cubit, error, stackTrace);

    _loggingService?.log(LogLevel.Error, error, error.toString());
  }
}