import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum UserType {
  Anonymous,
  Free,
  Paid
}

/// {@template user}
/// User model
///
/// [User.empty] represents an unauthenticated user.
/// {@endtemplate}
class User extends Equatable {
  /// {@macro user}
  const User({
    @required this.email,
    @required this.id,
    @required this.name,
    @required this.type,
    this.accesToken
  })  : assert(email != null),
        assert(id != null);

  /// The current user's email address.
  final String email;

  /// The current user's id.
  final String id;

  /// The current user's name (display name).
  final String name;

  /// The users account type (free, paid etc.)
  final UserType type;

  final String accesToken;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(email: '', id: '', name: null, type: UserType.Anonymous);

  @override
  List<Object> get props => [email, id, name, type];

  factory User.fromJson(Map<String, dynamic> json) => User(id: json['id'], 
    email: json['email'], name: json['name'], type: UserType.values[json['type']]);
}