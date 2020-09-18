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
  final String key;
  final dynamic value;
  ConfigurationChangedEvent(this.key, this.value) : super(ConfigurationEventIds.SaveConfiguration);
}