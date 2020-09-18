enum AppEventIds {
  LoadAllConfigurations,
  SaveConfiguration,
}

abstract class AppEvent {
  final AppEventIds id;

  AppEvent(this.id);
}

class AppIntializedEvent extends AppEvent {
  final List<String> keys;
  AppIntializedEvent({ this.keys }) : super(AppEventIds.LoadAllConfigurations);
}

class AppConfigurationChangedEvent extends AppEvent {
  final String key;
  final dynamic value;
  AppConfigurationChangedEvent(this.key, this.value) : super(AppEventIds.SaveConfiguration);
}