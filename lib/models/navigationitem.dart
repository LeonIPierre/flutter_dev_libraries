enum NavigationItem { HOME }


class NavigationItemModel {
  static NavigationItemModel home = NavigationItemModel(0, NavigationItem.HOME);
  
  int _index;
  int get index => _index;

  NavigationItem _item;
  NavigationItem get item => _item;

  NavigationItemModel(this._index, this._item);
}