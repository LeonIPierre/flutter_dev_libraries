import 'dart:convert';

import 'package:dev_libraries/contracts/authentication/userservice.dart';
import 'package:dev_libraries/models/authentication/user.dart';
import 'package:dev_libraries/models/ecommerce/purchase.dart';
import 'package:dev_libraries/models/payment.dart';
import 'package:http/http.dart' as http;

class ApiUserService extends UserService {
  final String _apiUrl;

  ApiUserService(this._apiUrl);

  Future<User> createUserAsync() => http.get(Uri(path: _apiUrl))
      .then((response) => User.fromJson(json.decode(response.body)));

  Future<User> get(String id) => http.get(Uri(path: "$_apiUrl/$id"))
      .then((response) => User.fromJson(json.decode(response.body)));

  @override
  Future<User> create({User? user}) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<Iterable<PaymentResult>> getPurchases(User user, { Iterable<PurhaseState>? states }) {
    // TODO: implement getPurchases
    throw UnimplementedError();
  }
}