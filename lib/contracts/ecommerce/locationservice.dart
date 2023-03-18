import 'package:dev_libraries/models/address.dart';

abstract class LocationService {
  Future<Iterable<Address>> search(String query);
}