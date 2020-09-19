import 'package:bloc/bloc.dart';
import 'package:dev_libraries/blocs/configuration/events.dart';
import 'package:dev_libraries/blocs/configuration/states.dart';
import 'package:dev_libraries/dev_libraries.dart';
import 'package:dev_libraries/repositories/assetbundlerepository.dart';
import 'package:dev_libraries/repositories/sharedpreferencesrepository.dart';
import 'package:flutter/services.dart' show rootBundle;

class ConfigurationBloc extends Bloc<ConfigurationEvent, ConfigurationState> {
  Map<String, dynamic> _configuration = Map<String, dynamic>();
  DefaultBlocObserver _blocObserver;
  AssetBundleRepository _bundleRepository;
  SharedPreferencesRepository _preferencesRepository;
  
  ConfigurationBloc(
      { DefaultBlocObserver blocObserver,
      AssetBundleRepository bundleRepository, String configFilePath, String delimiter,
      SharedPreferencesRepository preferencesRepository })
      : _blocObserver = blocObserver,
        _bundleRepository = bundleRepository ?? AssetBundleRepository(bundle: rootBundle, configFilePath: configFilePath, delimiter: delimiter),
        _preferencesRepository = preferencesRepository ?? SharedPreferencesRepository(),
        super(ConfigurationUnitializedState());

  @override
  Stream<ConfigurationState> mapEventToState(ConfigurationEvent event) async* {
    switch (event.id) {
      case ConfigurationEventIds.LoadAllConfigurations:
        yield ConfigurationLoadingState();

        List<String> keys = (event as ConfigurationIntializedEvent).keys;

        yield await Future.wait([_bundleRepository.getAll(keys: keys), _preferencesRepository.getAll(keys: keys)])
            .then((values) {
              values.map((value) => _configuration.addAll(value));

              _blocObserver = _blocObserver ??
                  DefaultBlocObserver(
                      loggingService: AppSpectorService(
                          androidKey: _configuration["appSpector:androidApiKey"]));
              Bloc.observer = Bloc.observer ?? _blocObserver;

              return ConfigurationInitializedState(_configuration);
            })
            .catchError((onError) => ConfigurationErrorState());
        break;
      case ConfigurationEventIds.SaveConfiguration:
        var ev = (event as ConfigurationChangedEvent);
        
        yield await _preferencesRepository.save(ev.key, ev.value)
          .then((success) {
            if(success) {
              _configuration.update(ev.key, (value) => ev.value);
              return ConfigurationInitializedState(_configuration);
            }
          })
          .catchError((onError) => ConfigurationErrorState());
        break;
    }
  }
}
