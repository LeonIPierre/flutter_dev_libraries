import 'dart:convert';

import 'package:dev_libraries/contracts/ecommerce/shippingservice.dart';
import 'package:dev_libraries/models/address.dart';
import 'package:dev_libraries/models/products/product.dart';
import 'package:dev_libraries/models/ecommerce/location.dart';
import 'package:http/http.dart' as http;

import 'deliverystatus.dart';
import 'responseerror.dart';

class UnknownLocationException implements Exception {}

class AddressUndeliverableException implements Exception {}

class PostmatesService extends ShippingService {
  final String _apiKey;
  final String _customerId;
  final String baseUrl = "https://cors-anywhere.herokuapp.com/https://api.postmates.com";

  PostmatesService(this._customerId, this._apiKey);

  @override
  Future<void> deliver(List<Product> items, Location from, Location to) {
    // TODO: implement deliver
    throw UnimplementedError();
  }

  @override
  Future<double> getEstimate(Address from, Address to) {
    // TODO: implement getEstimate
    throw UnimplementedError();
  }

  Future<PostmatesDeliveryStatus> getDeliveryQuote(Address from, Address to) async{
    var url = "$baseUrl/v1/customers/$_customerId/delivery_quotes";
    var body = Map<String, dynamic>();
    body['dropoff_address'] = "${from.address}, ${from.city}, ${from.state}, ${from.zip}";
    body['pickup_address'] = "${to.address}, ${to.city}, ${to.state}, ${to.zip}";
    
    var headers = Map<String, String>();
    headers.putIfAbsent('Accept', () => "application/json");
    headers.putIfAbsent('Content-Type', () => "application/x-www-form-urlencoded");
    //headers.putIfAbsent('Authorization', () => "Basic N2QyMzc1M2QtZWFlYy00YTM0LTkxNjctNjUwZjY2OTM5NWZlOg==");
    headers.putIfAbsent('Authorization', () => "Basic ${base64Url.encode(utf8.encode(_apiKey))}");

    return await http.post(url, headers: headers, body: body, encoding: Encoding.getByName('utf-8'))
      .then((response) {
        switch(response.statusCode)
        {
          case 200:
            return PostmatesDeliveryStatus.fromJson(json.decode(response.body));
          //TODO: https://postmates.com/developer/docs/#introduction__responses__error-codes
          case 400:
            var error = PostmatesResponseError.fromJson(json.decode(response.body));
            switch(error.code)
            {
              case "address_undeliverable":
                break;
            }
            break;
          default:
            throw Exception('Failed to get delivery status ${response.body.toString()}');
        }
      })
      .catchError((error) {
        print(error); 
      });
  }
}

class UserAgentClient extends http.BaseClient {
  final String _apiKey;
  final http.Client _inner = http.Client();

  UserAgentClient(this._apiKey);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = "application/json";
    request.headers['Content-Type'] = "application/x-www-form-urlencoded";
    request.headers['Authentication'] = "Basic ${base64Url.encode(utf8.encode(_apiKey))}";
    return _inner.send(request);
  }

  Future<http.Response> post(dynamic url, {Map<String, String> headers, dynamic body, Encoding encoding}) {
    headers.putIfAbsent('Accept', () => "application/json");
    headers.putIfAbsent('Content-Type', () => "application/x-www-form-urlencoded");
    headers.putIfAbsent('Authorization', () => "Basic ${base64Url.encode(utf8.encode(_apiKey))}");
    return _inner.post(url, headers: headers, body: body, encoding: encoding);
  }
}