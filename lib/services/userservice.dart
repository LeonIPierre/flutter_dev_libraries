import 'dart:convert';

import 'package:dev_libraries/models/authentication/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String _apiUrl;

  UserService(this._apiUrl);

  Future<User> createUserAsync() => http.get(_apiUrl)
      .then((response) => User.fromJson(json.decode(response.body)));
}