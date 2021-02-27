import 'package:dev_libraries/models/products/product.dart';

class Subscription extends Product {
  Subscription(String id, String name, String description, double price, String currencyCode) 
    : super(id, name, description, price, currencyCode: currencyCode);
}