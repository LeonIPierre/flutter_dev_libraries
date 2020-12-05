import 'package:bloc/bloc.dart';
import 'package:dev_libraries/blocs/configuration/events.dart';
import 'package:dev_libraries/blocs/configuration/states.dart';
import 'package:dev_libraries/dev_libraries.dart';
import 'package:dev_libraries/repositories/configurationrepository.dart';

class ConfigurationBloc extends Bloc<ConfigurationEvent, ConfigurationState> {
  Map<String, dynamic> _configuration = Map<String, dynamic>();
  DefaultBlocObserver _blocObserver;
  List<ConfigurationRepository> _repositories = [];

  ConfigurationBloc({ DefaultBlocObserver blocObserver, List<ConfigurationRepository> repositories })
      : _blocObserver = blocObserver, 
        _repositories = repositories,
        super(ConfigurationUnitializedState());

  @override
  Stream<ConfigurationState> mapEventToState(ConfigurationEvent event) async* {
    switch (event.id) {
      case ConfigurationEventIds.LoadAllConfigurations:
        yield ConfigurationLoadingState();

        List<String> keys = (event as ConfigurationIntializedEvent).keys;
        
        yield await Future.wait(_repositories.map((e) => e.getAll(keys: keys)))
            .then<ConfigurationState>((values) {
              values.forEach((element) {
                _configuration.addAll(element);
              });

              var loggingService;
              
              if(_configuration["appSpector:androidApiKey"] != null)
                loggingService = AppSpectorService(androidKey: _configuration["appSpector:androidApiKey"]);

              _blocObserver = _blocObserver ?? DefaultBlocObserver(
                loggingService: loggingService);
              Bloc.observer = Bloc.observer ?? _blocObserver;
 
              return ConfigurationInitializedState(_configuration);
            })
            .catchError((onError) => ConfigurationErrorState(message: onError.toString()));
        break;
      case ConfigurationEventIds.SaveConfiguration:
        var ev = (event as ConfigurationChangedEvent);

        yield await _repositories.firstWhere((element) => element.runtimeType == ev.repository.runtimeType)
        .save(ev.key, ev.value)
        .then<ConfigurationState>((success) {
            if(success) {
              _configuration.update(ev.key, (value) => ev.value);
              return ConfigurationInitializedState(_configuration);
            }

            return ConfigurationErrorState(message: 'Failed to update ${ev.key} to ${ev.value}');
          })
        .catchError((onError) => ConfigurationErrorState(message: onError.toString()));
        break;
    }
  }
}
