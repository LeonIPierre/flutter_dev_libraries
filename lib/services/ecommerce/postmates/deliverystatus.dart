class PostmatesDeliveryStatus {
  final String id;
  final DateTime dateCreated;
  final DateTime dateExpires;
  final double fee;
  final String currencyCode;
  final DateTime dropoffEta;
  final double duration;
  final double pickupDuration;

  PostmatesDeliveryStatus(this.id, this.dateCreated, this.dateExpires, this.fee, this.currencyCode, this.dropoffEta, this.duration, this.pickupDuration);

  factory PostmatesDeliveryStatus.fromJson(Map<String, dynamic> json) {
    return PostmatesDeliveryStatus(json['id'].toString(), DateTime.parse(json['created'].toString()),
      DateTime.parse(json['expires'].toString()),
      json['fee'], json['currency'], DateTime.parse(json['dropoff_eta'].toString()),
      json['duration'], json['pickup_duration']);
  }

  @override
  String toString() => '{ id: $id, created: $dateCreated, expirationDate: $dateExpires, fee: $fee, '
  + 'currencyCode: $currencyCode, dropOffEta: $dropoffEta, duration: $duration, pickupDuration: $pickupDuration }';
}