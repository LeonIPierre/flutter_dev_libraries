
abstract class AppState {}

class AppUnitializedState extends AppState {}

class AppLoadingState extends AppState {}

class AppErrorState extends AppState {}

class AppInitializedState extends AppState {
  final Map<String, dynamic> configuration;

  AppInitializedState(this.configuration);
}