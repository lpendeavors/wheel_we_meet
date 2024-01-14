import 'package:equatable/equatable.dart';

class MapMatchResponse extends Equatable {
  final List<Matching> matchings;
  final List<Tracepoint> tracepoints;
  final String code;
  final String uuid;

  const MapMatchResponse({
    required this.matchings,
    required this.tracepoints,
    required this.code,
    required this.uuid,
  });

  factory MapMatchResponse.fromJson(Map<String, dynamic> json) =>
      MapMatchResponse(
        matchings: List<Matching>.from(
          json["matchings"].map(
            (x) => Matching.fromJson(
              Map<String, dynamic>.from(x as Map),
            ),
          ),
        ),
        tracepoints: List<Tracepoint>.from(
          json["tracepoints"].map(
            (x) => Tracepoint.fromJson(
              Map<String, dynamic>.from(x as Map),
            ),
          ),
        ),
        code: json["code"],
        uuid: json["uuid"],
      );

  @override
  List<Object?> get props => [
        matchings,
        tracepoints,
        code,
        uuid,
      ];
}

class Matching extends Equatable {
  final double confidence;
  final String weightName;
  final double weight;
  final double duration;
  final double distance;
  final List<Leg> legs;
  final String geometry;

  const Matching({
    required this.confidence,
    required this.weightName,
    required this.weight,
    required this.duration,
    required this.distance,
    required this.legs,
    required this.geometry,
  });

  factory Matching.fromJson(Map<String, dynamic> json) => Matching(
        confidence: json["confidence"].toDouble(),
        weightName: json["weight_name"],
        weight: json["weight"].toDouble(),
        duration: json["duration"].toDouble(),
        distance: json["distance"].toDouble(),
        legs: List<Leg>.from(
          json["legs"].map(
            (x) => Leg.fromJson(
              Map<String, dynamic>.from(x as Map),
            ),
          ),
        ),
        geometry: json["geometry"],
      );

  @override
  List<Object?> get props => [
        confidence,
        weightName,
        weight,
        duration,
        distance,
        legs,
        geometry,
      ];
}

class Leg extends Equatable {
  final List<dynamic> viaWaypoints;
  final List<Admin> admins;
  final double weight;
  final double duration;
  final List<dynamic>
      steps; // Steps are not defined in the provided JSON, so I have kept them dynamic
  final double distance;
  final String summary;

  const Leg({
    required this.viaWaypoints,
    required this.admins,
    required this.weight,
    required this.duration,
    required this.steps,
    required this.distance,
    required this.summary,
  });

  factory Leg.fromJson(Map<String, dynamic> json) => Leg(
        viaWaypoints: json["via_waypoints"],
        admins: List<Admin>.from(
          json["admins"].map(
            (x) => Admin.fromJson(
              Map<String, dynamic>.from(x as Map),
            ),
          ),
        ),
        weight: json["weight"].toDouble(),
        duration: json["duration"].toDouble(),
        steps: json["steps"],
        distance: json["distance"].toDouble(),
        summary: json["summary"],
      );

  @override
  List<Object?> get props => [
        viaWaypoints,
        admins,
        weight,
        duration,
        steps,
        distance,
        summary,
      ];
}

class Admin extends Equatable {
  final String iso31661Alpha3;
  final String iso31661;

  const Admin({
    required this.iso31661Alpha3,
    required this.iso31661,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
        iso31661Alpha3: json["iso_3166_1_alpha3"],
        iso31661: json["iso_3166_1"],
      );

  @override
  List<Object?> get props => [
        iso31661Alpha3,
        iso31661,
      ];
}

class Tracepoint extends Equatable {
  final int matchingsIndex;
  final int waypointIndex;
  final int alternativesCount;
  final double distance;
  final String name;
  final List<double> location;

  const Tracepoint({
    required this.matchingsIndex,
    required this.waypointIndex,
    required this.alternativesCount,
    required this.distance,
    required this.name,
    required this.location,
  });

  factory Tracepoint.fromJson(Map<String, dynamic> json) => Tracepoint(
        matchingsIndex: json["matchings_index"],
        waypointIndex: json["waypoint_index"],
        alternativesCount: json["alternatives_count"],
        distance: json["distance"].toDouble(),
        name: json["name"],
        location: List<double>.from(
          json["location"].map(
            (x) => x.toDouble(),
          ),
        ),
      );

  @override
  List<Object?> get props => [
        matchingsIndex,
        waypointIndex,
        alternativesCount,
        distance,
        name,
        location,
      ];
}
