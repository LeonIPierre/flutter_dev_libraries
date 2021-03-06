import 'dart:convert';

import 'package:dev_libraries/contracts/authentication/userservice.dart';
import 'package:dev_libraries/models/authentication/user.dart';
import 'package:http/http.dart' as http;

class ApiUserService extends UserService{
  final String _apiUrl;

  ApiUserService(this._apiUrl);

  Future<User> createUserAsync() => http.get(_apiUrl)
      .then((response) => User.fromJson(json.decode(response.body)));

  Future<User> get(String id) => http.get("_apiUrl/$id")
      .then((response) => User.fromJson(json.decode(response.body)));

  @override
  Future<User> create({User user}) {
    // TODO: implement create
    throw UnimplementedError();
  }
}