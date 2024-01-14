import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RouteEntity extends Equatable {
  final String id;
  final String userId;
  final List<Waypoint> waypoints;
  final DateTime startTime;
  final DateTime endTime;

  const RouteEntity({
    required this.id,
    required this.userId,
    required this.waypoints,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        waypoints,
        startTime,
        endTime,
      ];

  factory RouteEntity.fromJson(Map<String, dynamic> json) {
    return RouteEntity(
      id: json['id'],
      userId: json['userId'],
      waypoints: json['waypoints'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}

class Waypoint extends Equatable {
  final GeoPoint location;
  final DateTime estimatedTime;

  const Waypoint({
    required this.location,
    required this.estimatedTime,
  });

  @override
  List<Object?> get props => [
        location,
        estimatedTime,
      ];

  factory Waypoint.fromJson(Map<String, dynamic> json) {
    return Waypoint(
      location: json['location'],
      estimatedTime: json['estimatedTime'],
    );
  }
}
