import 'package:equatable/equatable.dart';

class PlaceEntity extends Equatable {
  final String id;
  final String name;
  final String? address;
  final List<String>? categories;
  final List<String>? amenities;
  final int showers;
  final int parkingSpaces;
  final double distance;
  final bool scales;
  final LocationEntity location;

  const PlaceEntity({
    required this.id,
    required this.name,
    required this.distance,
    required this.location,
    this.address,
    this.categories,
    this.amenities,
    this.showers = 0,
    this.parkingSpaces = 0,
    this.scales = false,
  });

  factory PlaceEntity.fromJson(Map<String, dynamic> json) {
    return PlaceEntity(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      categories: json['categories']?.cast<String>(),
      amenities: json['amenities']?.cast<String>(),
      distance: json['distance'],
      showers: json['showers'] ?? 0,
      parkingSpaces: json['parkingSpaces'] ?? 0,
      scales: json['scales'] ?? false,
      location: LocationEntity.fromJson(json['location']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        categories,
        amenities,
        distance,
        showers,
        parkingSpaces,
        scales,
      ];
}

class LocationEntity extends Equatable {
  final String type;
  final List<double> coordinates;

  const LocationEntity({
    required this.type,
    required this.coordinates,
  });

  factory LocationEntity.fromJson(Map<String, dynamic> json) {
    var rawCoordinates = json['coordinates'] as List;
    var coordinates = rawCoordinates.map<double>((e) => e.toDouble()).toList();

    return LocationEntity(
      type: json['type'],
      coordinates: coordinates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  @override
  List<Object?> get props => [
        type,
        coordinates,
      ];
}
