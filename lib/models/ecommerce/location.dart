import 'package:dev_libraries/models/authentication/user.dart';

import '../address.dart';

class Location {
  final User user;

  final Address address;

  Location(this.address, {this.user});

  Map<String, dynamic> toJson() => {'user': user, 'address': address.toJson()};

  @override
  String toString() => 'Location {user:$user, address:$address }';
}
