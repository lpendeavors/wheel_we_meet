abstract class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {}

class MapPlaceSelected extends MapState {
  final dynamic place;

  MapPlaceSelected({required this.place});
}

class MapRouteBuilt extends MapState {
  final String distance;
  final String duration;

  MapRouteBuilt({required this.distance, required this.duration});
}

class MapRouteHidden extends MapState {}

class MapRouteUpdated extends MapState {}

class MapNavigationRunning extends MapState {}

class MapNavigationEnded extends MapState {}

class MapRouteDetails extends MapState {
  final dynamic routeDetails;

  MapRouteDetails({required this.routeDetails});
}

class MapRouteError extends MapState {
  final String message;

  MapRouteError(this.message);
}

class MapError extends MapState {
  final String errorMessage;

  MapError(this.errorMessage);
}

class RouteLoading extends MapState {}
