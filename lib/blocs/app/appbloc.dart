import 'package:bloc/bloc.dart';
import 'package:dev_libraries/dev_libraries.dart';
import 'package:dev_libraries/repositories/assetbundlerepository.dart';
import 'package:dev_libraries/repositories/sharedpreferencesrepository.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppBloc extends Bloc<AppEvent, AppState> {
  Map<String, dynamic> _configuration = Map<String, dynamic>();
  DefaultBlocObserver _blocObserver;
  AssetBundleRepository _bundleRepository;
  SharedPreferencesRepository _preferencesRepository;
  
  AppBloc(
      {String configFilePath, String delimiter,
      DefaultBlocObserver blocObserver,
      AssetBundleRepository bundleRepository,
      SharedPreferencesRepository preferencesRepository})
      : _blocObserver = blocObserver,
        _bundleRepository = bundleRepository ?? AssetBundleRepository(bundle: rootBundle, configFilePath: configFilePath, delimiter: delimiter),
        _preferencesRepository = preferencesRepository ?? SharedPreferencesRepository(),
        super(AppUnitializedState());

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    switch (event.id) {
      case AppEventIds.LoadAllConfigurations:
        yield AppLoadingState();

        List<String> keys = (event as AppIntializedEvent).keys;

        yield await Future.wait([_bundleRepository.getAll(keys: keys), _preferencesRepository.getAll(keys: keys)])
            .then((values) {
              values.map((value) => _configuration.addAll(value));

              _blocObserver = _blocObserver ??
                  DefaultBlocObserver(
                      loggingService: AppSpectorService(
                          androidKey: _configuration["appSpector:androidApiKey"]));
              Bloc.observer = Bloc.observer ?? _blocObserver;
            })
            .catchError((onError) => AppErrorState())
            .whenComplete(() => AppInitializedState(_configuration));
        break;
      case AppEventIds.SaveConfiguration:
        break;
    }
  }
}
