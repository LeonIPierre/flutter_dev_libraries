import 'package:dev_libraries/blocs/configuration/configurationbloc.dart';
import 'package:dev_libraries/blocs/configuration/states.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfigurationView
    extends BlocBuilder<ConfigurationBloc, ConfigurationState> {
  //final Map<ConfigurationState, Widget> _stateWidgetMapping;

  ConfigurationView(Map<ConfigurationState, Widget> _stateWidgetMapping)
      : super(builder: (BuildContext context, ConfigurationState state) {
        return _stateWidgetMapping[state];
      });
}
