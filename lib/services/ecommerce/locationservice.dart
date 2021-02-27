import 'package:dev_libraries/models/address.dart';

abstract class LocationService {
  Future<List<Address>> search(String query);
}