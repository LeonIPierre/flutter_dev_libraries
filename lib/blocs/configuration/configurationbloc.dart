import 'package:bloc/bloc.dart';
import 'package:dev_libraries/blocs/configuration/events.dart';
import 'package:dev_libraries/blocs/configuration/states.dart';
import 'package:dev_libraries/contracts/infastructure/configurationrepository.dart';

class ConfigurationBloc extends Bloc<ConfigurationEvent, ConfigurationState> {
  Map<String, dynamic> _configuration = Map<String, dynamic>();
  List<ConfigurationRepository>? _repositories = [];

  ConfigurationBloc({List<ConfigurationRepository>? repositories})
      : _repositories = repositories,
        super(ConfigurationUnitializedState());

  @override
  Stream<ConfigurationState> mapEventToState(ConfigurationEvent event) async* {
    switch (event.id) {
      case ConfigurationEventIds.LoadAllConfigurations:
        yield ConfigurationLoadingState();

        List<String>? keys = (event as ConfigurationIntializedEvent).keys;

        yield await Future.wait(_repositories!.map((e) => e.getAll(keys: keys)))
            .then<ConfigurationState>((values) => mapToLoadConfigurationState(values))
            .catchError((onError) =>
                ConfigurationErrorState(message: onError.toString()));
        break;
      case ConfigurationEventIds.SaveConfiguration:
        var ev = (event as ConfigurationChangedEvent);

        yield await _repositories!
            .firstWhere(
                (element) => element.runtimeType == ev.repository.runtimeType)
            .save(ev.key, ev.value)
            .then<ConfigurationState>((success) {
          if (!success)
            return ConfigurationErrorState(
                message: 'Failed to update ${ev.key} to ${ev.value}');

          return mapToSaveConfigurationState(ev, _configuration);
        }).catchError((onError) =>
                ConfigurationErrorState(message: onError.toString()));
        break;
    }
  }

  Future<ConfigurationState> mapToLoadConfigurationState(
      List<Map<String, dynamic>> configuration) async => Future(() {
      Map<String, dynamic> config = Map<String, dynamic>();

      configuration.forEach((element) {
        config.addAll(element);
      });

      return ConfigurationInitializedState(config);
    });

  ConfigurationState mapToSaveConfigurationState(
      ConfigurationChangedEvent event, Map<String, dynamic> configuration) {
    configuration.update(event.key, (value) => event.value);

    return ConfigurationInitializedState(configuration);
  }
}
