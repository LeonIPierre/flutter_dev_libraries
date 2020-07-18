import 'package:bloc/bloc.dart';
import 'package:dev_libraries/bloc/app/app.dart';

import 'package:dev_libraries/bloc/blocobserver.dart';
import 'package:dev_libraries/services/logging/appspectorservice.dart';
import 'package:flat/flat.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class AppBloc extends Bloc<AppIntializedEvent, AppState> {
  Map<String, dynamic> configuration = Map<String, dynamic>();

  final String configFilePath;
  final String delimiter;
  DefaultBlocObserver _blocObserver;
  
  AppBloc(
      {this.configFilePath = "assets/config.json",
      this.delimiter = ":",
      DefaultBlocObserver blocManager}) : super(AppUnitializedState()) {
    _blocObserver = blocManager ??
        DefaultBlocObserver(
            loggingService: AppSpectorService(
                androidKey: configuration["appSpector:androidApiKey"]));
  }

  @override
  Stream<AppState> mapEventToState(AppIntializedEvent event) async* {
    yield AppLoadingState();

    yield await rootBundle.loadString(configFilePath).then((content) {
      configuration = flatten(json.decode(content), delimiter: delimiter);
      Bloc.observer = Bloc.observer ?? _blocObserver;
      
      return AppInitializedState();
    })
    .catchError((onError) => AppErrorState());
  }
}
