import 'package:dev_libraries/models/address.dart';
import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final List<Address>? addresses;

  const UserProfile({this.addresses});

  @override
  List<Object?> get props => [addresses];

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      UserProfile(addresses: json['addresses']);
}
