import 'package:bloc/bloc.dart';
import 'package:dev_libraries/blocs/configuration/events.dart';
import 'package:dev_libraries/blocs/configuration/states.dart';
import 'package:dev_libraries/contracts/infastructure/configurationrepository.dart';

class ConfigurationBloc extends Bloc<ConfigurationEvent, ConfigurationState> {
  Map<String, dynamic> _configuration = Map<String, dynamic>();
  List<ConfigurationRepository>? _repositories = [];

  ConfigurationBloc({List<ConfigurationRepository>? repositories})
      : _repositories = repositories,
        super(ConfigurationUnitializedState()) {
    on<ConfigurationIntializedEvent>((event, emit) async {
      emit(ConfigurationLoadingState());

      emit(await Future.wait(
              _repositories!.map((e) => e.getAll(keys: event.keys)))
          .then<ConfigurationState>(
              (values) => _mapToLoadConfigurationState(values))
          .catchError((onError) =>
              ConfigurationErrorState(message: onError.toString())));
    });

    on<ConfigurationChangedEvent>((event, emit) async {
      emit(await _repositories!
          .firstWhere(
              (element) => element.runtimeType == event.repository.runtimeType)
          .save(event.key, event.value)
          .then<ConfigurationState>((success) {
        if (!success)
          return ConfigurationErrorState(
              message: 'Failed to update ${event.key} to ${event.value}');
              
        return _mapToSaveConfigurationState(event, _configuration);
      }).catchError((onError) =>
              ConfigurationErrorState(message: onError.toString())));
    });
  }

  Future<ConfigurationState> _mapToLoadConfigurationState(
          List<Map<String, dynamic>> configurations) async =>
      Future(() {
        
        configurations.forEach((element) {
          _configuration.addAll(element);
        });

        return ConfigurationInitializedState(_configuration);
      });

  ConfigurationState _mapToSaveConfigurationState(
      ConfigurationChangedEvent event, Map<String, dynamic> configuration) {
    configuration.update(event.key, (value) => event.value);

    return ConfigurationInitializedState(configuration);
  }
}
