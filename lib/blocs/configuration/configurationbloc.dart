import 'package:bloc/bloc.dart';
import 'package:dev_libraries/blocs/configuration/events.dart';
import 'package:dev_libraries/blocs/configuration/states.dart';
import 'package:dev_libraries/contracts/configurationrepository.dart';

class ConfigurationBloc extends Bloc<ConfigurationEvent, ConfigurationState> {
  Map<String, dynamic> _configuration = Map<String, dynamic>();
  List<ConfigurationRepository>? _repositories = [];

  ConfigurationBloc({ List<ConfigurationRepository>? repositories })
      : _repositories = repositories,
        super(ConfigurationUnitializedState());

  @override
  Stream<ConfigurationState> mapEventToState(ConfigurationEvent event) async* {
    switch (event.id) {
      case ConfigurationEventIds.LoadAllConfigurations:
        yield ConfigurationLoadingState();

        List<String>? keys = (event as ConfigurationIntializedEvent).keys;
        
        yield await Future.wait(_repositories!.map((e) => e.getAll(keys: keys!)))
            .then<ConfigurationState>((values) {
              values.forEach((element) {
                _configuration.addAll(element);
              });
 
              return ConfigurationInitializedState(_configuration);
            })
            .catchError((onError) => ConfigurationErrorState(message: onError.toString()));
        break;
      case ConfigurationEventIds.SaveConfiguration:
        var ev = (event as ConfigurationChangedEvent);

      yield await _repositories!.firstWhere((element) => element.runtimeType == ev.repository.runtimeType)
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
