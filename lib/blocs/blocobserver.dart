import 'package:bloc/bloc.dart';
import 'package:dev_libraries/contracts/analytics/analyticsservice.dart';
import 'package:dev_libraries/contracts/logging/logservice.dart';
import 'package:dev_libraries/models/logging/logging.dart';

class DefaultBlocObserver extends BlocObserver {
  final AnalyticsService? _analyticsService;
  final LogService? _loggingService;

  DefaultBlocObserver(
      {AnalyticsService? analyticsService, LogService? loggingService})
      : _analyticsService = analyticsService,
        _loggingService = loggingService;

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    if (transition.nextState is! LoggableState || transition.event is! LoggableEvent) return;

    //need a uniqiue id to map to a "user session"
    //convert the state logs to a generic log to pass to service
    var event = transition.event as LoggableEvent;
    var state = transition.nextState as LoggableState;
    var parameters = event.toLogState()..addAll(state.toLogState());
    
    _analyticsService?.send(event.name, parameters);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);

    _loggingService?.log(LogLevel.Error, Exception(error), error.toString());
  }
}
