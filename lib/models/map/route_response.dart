import 'package:equatable/equatable.dart';

class RouteResponse extends Equatable {
  final List<Feature> features;
  final Properties properties;
  final String type;

  const RouteResponse({
    required this.features,
    required this.properties,
    required this.type,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) => RouteResponse(
        features: (json["features"] as List)
            .map(
              (x) => Feature.fromJson(Map<String, dynamic>.from(x as Map)),
            )
            .toList(),
        properties: Properties.fromJson(
          Map<String, dynamic>.from(json["properties"] as Map),
        ),
        type: json["type"] as String,
      );

  Map<String, dynamic> toJson() => {
        "features": List<dynamic>.from(features.map((x) => x.toJson())),
        "properties": properties.toJson(),
        "type": type,
      };

  @override
  List<Object?> get props => [
        features,
        properties,
        type,
      ];
}

class Feature extends Equatable {
  final String type;
  final Properties properties;
  final Geometry geometry;

  const Feature({
    required this.type,
    required this.properties,
    required this.geometry,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        type: json["type"],
        properties: Properties.fromJson(
          Map<String, dynamic>.from(json["properties"] as Map),
        ),
        geometry: Geometry.fromJson(
          Map<String, dynamic>.from(json["geometry"] as Map),
        ),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "properties": properties.toJson(),
        "geometry": geometry.toJson(),
      };

  @override
  List<Object?> get props => [
        type,
        properties,
        geometry,
      ];
}

class Geometry extends Equatable {
  final String type;
  final List<List<List<double>>> coordinates;

  const Geometry({
    required this.type,
    required this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        type: json["type"],
        coordinates: List<List<List<double>>>.from(
          json["coordinates"].map(
            (x) => List<List<double>>.from(
              x.map(
                (x) => List<double>.from(
                  x.map((x) => x.toDouble()),
                ),
              ),
            ),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": List<dynamic>.from(
          coordinates.map(
            (x) => List<dynamic>.from(
              x.map(
                (x) => List<dynamic>.from(
                  x.map((x) => x),
                ),
              ),
            ),
          ),
        ),
      };

  @override
  List<Object?> get props => [
        type,
        coordinates,
      ];
}

class Properties extends Equatable {
  final String mode;
  final List<Waypoint> waypoints;
  final String units;
  final List<String> details;
  final double? distance;
  final String? distanceUnits;
  final double? time;
  final List<Leg> legs;

  const Properties({
    required this.mode,
    required this.waypoints,
    required this.units,
    required this.details,
    required this.legs,
    this.time,
    this.distance,
    this.distanceUnits,
  });

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        mode: json["mode"],
        waypoints: List<Waypoint>.from(
          json["waypoints"].map(
            (x) => Waypoint.fromJson(
              Map<String, dynamic>.from(x as Map),
            ),
          ),
        ),
        units: json["units"],
        details: List<String>.from(
          json["details"].map((x) => x),
        ),
        distance: json["distance"]?.toDouble(),
        distanceUnits: json["distance_units"] as String?,
        time: json["time"]?.toDouble(),
        legs: (json["legs"] as List<dynamic>?)
                ?.map((x) => Leg.fromJson(Map<String, dynamic>.from(x as Map)))
                .toList() ??
            [], // Providing an empty list as a fallback
      );

  Map<String, dynamic> toJson() => {
        "mode": mode,
        "waypoints": List<dynamic>.from(waypoints.map((x) => x.toJson())),
        "units": units,
        "details": List<dynamic>.from(details.map((x) => x)),
        "distance": distance,
        "distance_units": distanceUnits,
        "time": time,
        "legs": List<dynamic>.from(legs.map((x) => x.toJson())),
      };

  @override
  List<Object?> get props => [
        mode,
        waypoints,
        units,
        details,
        distance,
        distanceUnits,
        time,
        legs,
      ];
}

class Leg extends Equatable {
  final double distance;
  final double time;
  final List<Step> steps;

  const Leg({
    required this.distance,
    required this.time,
    required this.steps,
  });

  factory Leg.fromJson(Map<String, dynamic> json) => Leg(
        distance: json["distance"].toDouble(),
        time: json["time"].toDouble(),
        steps: List<Step>.from(
          json["steps"].map(
            (x) => Step.fromJson(
              Map<String, dynamic>.from(x as Map),
            ),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        "distance": distance,
        "time": time,
        "steps": List<dynamic>.from(steps.map((x) => x.toJson())),
      };

  @override
  List<Object?> get props => [
        distance,
        time,
        steps,
      ];
}

class Step extends Equatable {
  final int fromIndex;
  final int toIndex;
  final double distance;
  final double time;
  final Instruction instruction;

  const Step({
    required this.fromIndex,
    required this.toIndex,
    required this.distance,
    required this.time,
    required this.instruction,
  });

  factory Step.fromJson(Map<String, dynamic> json) => Step(
        fromIndex: json["from_index"],
        toIndex: json["to_index"],
        distance: json["distance"].toDouble(),
        time: json["time"].toDouble(),
        instruction: Instruction.fromJson(
          Map<String, dynamic>.from(json["instruction"] as Map),
        ),
      );

  Map<String, dynamic> toJson() => {
        "from_index": fromIndex,
        "to_index": toIndex,
        "distance": distance,
        "time": time,
        "instruction": instruction.toJson(),
      };

  @override
  List<Object?> get props => [
        fromIndex,
        toIndex,
        distance,
        time,
        instruction,
      ];
}

class Instruction extends Equatable {
  final String text;
  final String type;
  final String transitionInstruction;
  final String? preTransitionInstruction;
  final String? postTransitionInstruction;
  final List<String>? streets;
  final bool? containsNextInstruction;

  const Instruction({
    required this.text,
    required this.type,
    required this.transitionInstruction,
    this.preTransitionInstruction,
    this.postTransitionInstruction,
    this.streets,
    this.containsNextInstruction,
  });

  factory Instruction.fromJson(Map<String, dynamic> json) => Instruction(
        text: json["text"] as String,
        type: json["type"] as String,
        transitionInstruction: json["transition_instruction"] as String,
        preTransitionInstruction: json["pre_transition_instruction"] == null
            ? null
            : json["pre_transition_instruction"] as String,
        postTransitionInstruction: json["post_transition_instruction"] == null
            ? null
            : json["post_transition_instruction"] as String,
        streets: json["streets"] == null
            ? null
            : List<String>.from(json["streets"].map((x) => x as String)),
        containsNextInstruction: json["contains_next_instruction"] as bool?,
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "type": type,
        "transition_instruction": transitionInstruction,
        "pre_transition_instruction": preTransitionInstruction,
        "post_transition_instruction": postTransitionInstruction,
        "streets": streets,
        "contains_next_instruction": containsNextInstruction,
      };

  @override
  List<Object?> get props => [
        text,
        type,
        transitionInstruction,
        preTransitionInstruction,
        postTransitionInstruction,
        streets,
        containsNextInstruction,
      ];
}

class Waypoint extends Equatable {
  final List<double> location;
  final int originalIndex;

  const Waypoint({
    required this.location,
    required this.originalIndex,
  });

  factory Waypoint.fromJson(Map<String, dynamic> json) {
    final locationJson = json["location"] as List<dynamic>?;
    final location = locationJson != null
        ? locationJson.map((x) => x.toDouble() as double).toList()
        : <double>[];

    return Waypoint(
      location: location,
      originalIndex: json["original_index"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "location": location,
        "original_index": originalIndex,
      };

  @override
  List<Object?> get props => [
        location,
        originalIndex,
      ];
}
