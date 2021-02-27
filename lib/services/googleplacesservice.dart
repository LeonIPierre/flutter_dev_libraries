import 'package:dev_libraries/models/address.dart';
import 'package:dev_libraries/services/ecommerce/locationservice.dart';
import 'package:google_maps_webservice/geocoding.dart';

class GooglePlacesService extends LocationService{
  GoogleMapsGeocoding geocoding;

  GooglePlacesService(String apiKey) {
    geocoding = GoogleMapsGeocoding(apiKey: apiKey);
  }
  
  Future<List<Address>> search(String query) => 
    geocoding.searchByAddress(query).then((response) {
      return response.results.map((result) {
        var streetNumber = result.addressComponents.firstWhere((element) => element.types.contains('street_number')).longName;
        var route = result.addressComponents.firstWhere((element) => element.types.contains('route')).longName;
        var address = '$streetNumber $route';
        var city = result.addressComponents.firstWhere((element) => element.types.contains('locality')).longName;
        var state = result.addressComponents.firstWhere((element) => element.types.contains('administrative_area_level_1')).longName;
        var zip = result.addressComponents.firstWhere((element) => element.types.contains('postal_code')).longName;

        var lat =  result.geometry.location.lat;
        var long =  result.geometry.location.lng;

        return Address(result.placeId, address, city, state, zip, latitude: lat, longitude: long);
      }).toList();
    });
}