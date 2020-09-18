
abstract class ConfigurationState {}

class ConfigurationUnitializedState extends ConfigurationState {}

class ConfigurationLoadingState extends ConfigurationState {}

class ConfigurationErrorState extends ConfigurationState {}

class ConfigurationInitializedState extends ConfigurationState {
  final Map<String, dynamic> configuration;

  ConfigurationInitializedState(this.configuration);
}