import 'package:equatable/equatable.dart';

import 'map_match_response.dart';
import 'route_response.dart';

class RouteDetails extends Equatable {
  final RouteResponse routeResponse;
  final MapMatchResponse mapMatchResponse;

  const RouteDetails(
    this.routeResponse,
    this.mapMatchResponse,
  );

  factory RouteDetails.fromJson(Map<String, dynamic> json) {
    return RouteDetails(
      RouteResponse.fromJson(
        Map<String, dynamic>.from(json['routeResponse'] as Map),
      ),
      MapMatchResponse.fromJson(
        Map<String, dynamic>.from(json['mapMatchResponse'] as Map),
      ),
    );
  }

  @override
  List<Object?> get props => [
        routeResponse,
        mapMatchResponse,
      ];

  @override
  bool get stringify => true;
}
