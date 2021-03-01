import 'package:dev_libraries/contracts/configurationrepository.dart';
enum ConfigurationEventIds {
  LoadAllConfigurations,
  SaveConfiguration,
}

abstract class ConfigurationEvent {
  final ConfigurationEventIds id;

  ConfigurationEvent(this.id);
}

class ConfigurationIntializedEvent extends ConfigurationEvent {
  final List<String> keys;
  ConfigurationIntializedEvent({ this.keys }) : super(ConfigurationEventIds.LoadAllConfigurations);
}

class ConfigurationChangedEvent extends ConfigurationEvent {
  final Type repository;
  final String key;
  final dynamic value;
  ConfigurationChangedEvent(this.repository, this.key, this.value) 
    : assert(repository is ConfigurationRepository),
    super(ConfigurationEventIds.SaveConfiguration);
}