import 'package:dev_libraries/models/authentication/user.dart';

abstract class UserService {
  Future<User> create({User user});

  Future<User> get(String id);
}