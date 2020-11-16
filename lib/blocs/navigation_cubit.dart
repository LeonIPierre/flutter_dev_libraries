import 'package:bloc/bloc.dart';
import 'package:dev_libraries/models/navigationitem.dart';
import 'package:rxdart/rxdart.dart';

class NavigationCubit extends Cubit<NavigationItemModel> {
  final BehaviorSubject<NavigationItemModel> _navigation = BehaviorSubject<NavigationItemModel>();
  final List<NavigationItemModel> _pages;

  Stream<NavigationItemModel> get history => _navigation.stream;

  NavigationCubit(this._pages) : super(_pages[0]) {
    _navigation.sink.add(_pages[0]);
  }

  void toPage(int index) {
    var page = _pages[index];
    _navigation.sink.add(page);
    emit(page);
  }

  void dispose() {
    _navigation?.close();
  }
} 