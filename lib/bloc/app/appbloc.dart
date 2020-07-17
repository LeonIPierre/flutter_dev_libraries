import 'package:bloc/bloc.dart';
import 'package:dev_libraries/bloc/app/events.dart';
import 'package:dev_libraries/bloc/app/states.dart';

import 'package:dev_libraries/bloc/blocmanager.dart';
import 'package:dev_libraries/services/logging/appspectorservice.dart';
import 'package:flat/flat.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class AppBloc extends Bloc<AppIntializedEvent, AppState> {
  Map<String, dynamic> configuration = Map<String, dynamic>();

  final String configFilePath;
  final String delimiter;
  BlocDelegate _blocManager;

  AppBloc(
      {this.configFilePath = "assets/config.json",
      this.delimiter = ":",
      BlocDelegate blocManager}) {
    _blocManager = blocManager ??
        DefaultBlocManager(
            loggingService: AppSpectorService(
                androidKey: configuration["appSpector:androidApiKey"]));
  }

  @override
  get initialState => AppUnitializedState();

  @override
  Stream<AppState> mapEventToState(AppIntializedEvent event) async* {
    yield AppLoadingState();

    yield await rootBundle.loadString(configFilePath).then((content) {
      configuration = flatten(json.decode(content), delimiter: delimiter);
      BlocSupervisor.delegate = _blocManager;
      
      return AppInitializedState();
    }).catchError((onError) => AppErrorState());
  }
}
