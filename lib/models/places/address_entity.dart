import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String? id;
  final String? name;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? zip;
  final double? latitude;
  final double? longitude;

  const AddressEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.zip,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        latitude,
        longitude,
      ];

  factory AddressEntity.fromJson(Map<String, dynamic> json) {
    return AddressEntity(
      id: json['properties']['place_id'],
      name: json['properties']['formatted'],
      address: json['properties']['formatted'],
      city: json['properties']['city'],
      state: json['properties']['state_code'],
      country: json['properties']['country'],
      zip: json['properties']['postcode'],
      latitude: json['geometry']['coordinates'][1],
      longitude: json['geometry']['coordinates'][0],
    );
  }
}
