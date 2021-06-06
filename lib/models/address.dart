class Address {
  final String id;
  final String address;
  final String city;
  final String state;
  final String zip;
  final double? latitude;
  final double? longitude;

  const Address(this.id, this.address, this.city, this.state, this.zip, {this.latitude, this.longitude});

  Address clone({String? id, String? address, String? city, String? state, String? zip}) 
    => Address(id ?? this.id, address ?? this.address, city ?? this.city, state ?? this.state, zip ?? this.zip);

  Map<String, dynamic> toJson() => {
    'id': id,
    'address': address,
    'city': city,
    'state': state,
    'zip': zip,
    'latitude': latitude,
    'longitude': longitude
  };

  @override
  String toString() => '$address, $city $state, $zip';
}