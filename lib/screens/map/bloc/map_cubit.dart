import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../models/map/route_request.dart';
import '../../../repositories/repositories.dart';
import '../../nearby/bloc/nearest_vm.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final RouteRepository routeRepository;
  final UserRepository userRepository;
  final GeoRepository geoRepository;

  MapCubit({
    required this.routeRepository,
    required this.userRepository,
    required this.geoRepository,
  }) : super(MapInitial());

  bool routeBuilt = false;
  bool isNavigating = false;
  bool isMultipleStop = false;
  MapboxMap? mapboxMap;

  List<PlaceVM> places = [];
  bool placesLoaded = false;

  RouteRequest? routeRequest;
  dynamic routeResponse;

  var navigationOption = MapBoxOptions(
    mode: MapBoxNavigationMode.drivingWithTraffic,
    simulateRoute: true,
    language: 'en',
    units: VoiceUnits.imperial,
    zoom: 17.0,
    animateBuildRoute: true,
    longPressDestinationEnabled: true,
    enableRefresh: true,
    isOptimized: true,
  );

  geo.Position? currentPosition;

  void initializeMap(MapboxMap mapController) async {
    mapboxMap = mapController;

    await mapboxMap!.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        showAccuracyRing: true,
        puckBearingEnabled: true,
      ),
    );

    _locationSaves();

    await centerCamera();
    emit(MapLoaded());
  }

  Future<void> centerCamera() async {
    try {
      currentPosition ??= await geo.Geolocator.getCurrentPosition();
      if (mapboxMap != null) {
        await mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(
                currentPosition!.longitude,
                currentPosition!.latitude,
              ),
            ).toJson(),
            anchor: ScreenCoordinate(x: 1, y: 1),
            zoom: 10,
            padding: MbxEdgeInsets(
              bottom: 0,
              left: 0,
              right: 0,
              top: 0,
            ),
          ),
          MapAnimationOptions(
            duration: 1000,
            startDelay: 100,
          ),
        );
      } else {
        print('MapboxMap is not initialized');
      }
    } catch (e) {
      print('Failed to get current position: $e');
    }
  }

  void getRoute(RouteRequest routeRequest) {
    this.routeRequest = routeRequest;
    routeBuilt = false;

    hideRoute();

    emit(RouteLoading());
    routeRepository
        .getRoute(
      routeRequest,
      currentPosition!.longitude,
      currentPosition!.latitude,
    )
        .then((route) {
      if (route != null) {
        routeResponse = route;
        _showRouteDetails(
          route,
          routeRequest.isImperial,
        );
      } else {
        emit(MapRouteError('Failed to get route'));
      }
    }).catchError((e) {
      emit(MapRouteError(e.toString()));
    });
  }

  void showNearbyPlaces(List<PlaceVM> places) {
    this.places = places;

    if (!placesLoaded) {
      for (var place in places) {
        mapboxMap!.style.addSource(
          GeoJsonSource(
            id: place.id,
            data: jsonEncode(place.geometry),
          ),
        );
        mapboxMap!.style.addLayer(
          CircleLayer(
            id: place.id,
            sourceId: place.id,
            circleRadius: 8,
            circleColor: Colors.blue.value,
          ),
        );
      }
      placesLoaded = true;

      mapboxMap!.setOnMapTapListener((coordinate) {
        _checkForPlaceMatch(
          {
            'latitude': coordinate.x,
            'longitude': coordinate.y,
          },
        );
      });
    }
  }

  void _checkForPlaceMatch(Map<String, dynamic> tapCoordinates) {
    const threshold = 0.75;

    for (final place in places) {
      double distance = _calculateDistance(
        tapCoordinates,
        {
          'latitude': place.latitude,
          'longitude': place.longitude,
        },
      );
      if (distance <= threshold) {
        emit(MapPlaceSelected(place: place));
        break;
      }
    }
  }

  double _calculateDistance(
    Map<String, dynamic> tapCoordinates,
    Map<String, dynamic> placeCoordinates,
  ) {
    final distance = geo.Geolocator.distanceBetween(
      tapCoordinates['latitude'],
      tapCoordinates['longitude'],
      placeCoordinates['latitude'],
      placeCoordinates['longitude'],
    );
    return distance / 1609;
  }

  Future<void> _showRouteDetails(dynamic routeDetails, bool isImperial) async {
    if (routeDetails['routes'] != null) {
      for (int i = 0; i < routeDetails['routes'].length; i++) {
        var route = routeDetails['routes'][i];
        var geometry = route['geometry'];
        var coordinates = geometry['coordinates'];

        String sourceId = 'route_$i';
        String layerId = 'routeLayer_$i';

        mapboxMap!.style.addSource(
          GeoJsonSource(
            id: sourceId,
            data: jsonEncode(geometry),
            buffer: 30,
          ),
        );

        mapboxMap!.style.addLayer(
          LineLayer(
            id: layerId,
            sourceId: sourceId,
            lineWidth: 6,
            lineColor: _getRouteColor(i).value,
            lineCap: LineCap.ROUND,
            lineJoin: LineJoin.ROUND,
          ),
        );

        print('layer $layerId');
        print('source $sourceId');

        if (i == 0) {
          final coordinatesList = coordinates
              .map((c) => Point(
                    coordinates: Position(c[0], c[1]),
                  ).toJson())
              .toList();

          final List<Map<String?, Object?>> mapCoordinatesList = [];

          for (var coordinate in coordinatesList) {
            if (coordinate is Map<String?, Object?>) {
              mapCoordinatesList.add(coordinate);
            }
          }

          final camera = await mapboxMap!.cameraForCoordinates(
            mapCoordinatesList,
            MbxEdgeInsets(
              top: 100,
              left: 80,
              bottom: 350,
              right: 80,
            ),
            null,
            null,
          );

          await mapboxMap!.flyTo(
            camera,
            null,
          );
        }

        int minutes = (route['duration'] / 60).floor();
        double convertedDistance = isImperial
            ? route['distance'] * 0.000621371
            : route['distance'] * 0.001;
        String metric = isImperial ? 'mi' : 'km';

        routeBuilt = true;

        emit(MapRouteBuilt(
          distance: '${convertedDistance.toStringAsFixed(2)} $metric',
          duration: '$minutes minutes',
        ));
      }
    }
  }

  void startNavigation() async {
    if (routeBuilt) {
      hideRoute();

      navigationOption.maxHeight = routeRequest!.isImperial
          ? routeRequest!.truckHeight / 12 * 0.3048
          : routeRequest!.truckHeight;
      navigationOption.maxWidth = routeRequest!.isImperial
          ? routeRequest!.truckWidth / 12 * 0.3048
          : routeRequest!.truckWidth;
      navigationOption.maxWeight = routeRequest!.isImperial
          ? (routeRequest!.truckWeight * 0.453592) / 1000
          : routeRequest!.truckWeight / 1000;

      navigationOption.excludeFerries = routeRequest!.truckAvoidFerries;
      navigationOption.excludeHighways = routeRequest!.truckAvoidHighways;
      navigationOption.excludeTolls = routeRequest!.truckAvoidTolls;

      navigationOption.mode = MapBoxNavigationMode.drivingWithTraffic;
      navigationOption.simulateRoute = true;

      await MapBoxNavigation.instance.startNavigation(
        wayPoints: [
          WayPoint(
            name: 'Start',
            latitude: currentPosition!.latitude,
            longitude: currentPosition!.longitude,
          ),
          WayPoint(
            name: 'End',
            latitude: routeRequest!.destinationLat,
            longitude: routeRequest!.destinationLng,
          ),
        ],
        options: navigationOption,
      );

      emit(MapNavigationRunning());
    }
  }

  Color _getRouteColor(int routeIndex) {
    List<Color> colors = [Colors.green];
    return colors[routeIndex % colors.length];
  }

  void hideRoute() {
    mapboxMap!.style.styleLayerExists('routeLayer_0').then((value) {
      if (value) {
        mapboxMap!.style.removeStyleLayer('routeLayer_0');
        mapboxMap!.style.removeStyleSource('route_0');
      }
    });
    centerCamera();
    emit(MapRouteHidden());
  }

  void handleRouteEvent(dynamic e) async {
    print(e.eventType);
    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        routeBuilt = true;
        emit(MapRouteUpdated());
        break;
      case MapBoxEvent.route_build_failed:
        routeBuilt = false;
        emit(MapRouteUpdated());
        break;
      case MapBoxEvent.navigation_running:
        isNavigating = true;
        emit(MapNavigationRunning());
        break;
      case MapBoxEvent.on_arrival:
        if (!isMultipleStop) {
          await Future.delayed(const Duration(seconds: 3));
        }
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        isNavigating = false;
        centerCamera();
        emit(MapNavigationEnded());
        break;
      default:
        break;
    }
  }

  void _locationSaves() {
    const tenMinutes = Duration(minutes: 10);
    Timer.periodic(tenMinutes, (Timer timer) async {
      await geoRepository.updateLocation(
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
      );
    });
  }
}
