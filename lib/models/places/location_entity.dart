import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final String id;
  final String name;
  final String type;
  final GeoPoint coordinates;

  const LocationEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.coordinates,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        coordinates,
      ];

  factory LocationEntity.fromJson(Map<String, dynamic> json) {
    return LocationEntity(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      coordinates: json['coordinates'],
    );
  }
}
