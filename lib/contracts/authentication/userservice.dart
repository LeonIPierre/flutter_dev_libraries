import 'dart:collection';

import 'package:dev_libraries/models/authentication/user.dart';
import 'package:dev_libraries/models/ecommerce/purchase.dart';
import 'package:dev_libraries/models/payment.dart';

abstract class UserService {
  Future<User> create({User user});

  Future<User> get(String id);

  Future<UnmodifiableListView<PaymentResult>> getPurchases(User user, { UnmodifiableListView<PurhaseState> states });
}