import 'dart:collection';

import 'package:dev_libraries/models/authentication/user.dart';
import 'package:dev_libraries/models/ecommerce/purchase.dart';

abstract class UserService {
  Future<User> create({User user});

  Future<User> get(String id);

  Future<UnmodifiableListView<Purchase>> getPurchases(User user, { UnmodifiableListView<PurhaseState> states });
}