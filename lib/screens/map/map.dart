import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../models/map/route_request.dart';
import '../../repositories/repositories.dart';
import '../chat/conversation_list.dart';
import '../friends/friends.dart';
import '../nearby/bloc/nearest_cubit.dart';
import '../nearby/place_details.dart';
import '../settings/settings.dart';
import 'bloc/map_cubit.dart';
import '../search/search.dart';
import 'bloc/map_state.dart';
import '../nearby/nearest.dart';
import 'route_details.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map';

  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  bool locationServiceEnabled = false;
  bool hasPermission = false;

  late LocationPermission permission;

  @override
  void initState() {
    super.initState();

    MapBoxNavigation.instance.registerRouteEventListener(
      (e) => context.read<MapCubit>().handleRouteEvent(e),
    );

    Geolocator.isLocationServiceEnabled().then((isEnabled) {
      print('locationServiceEnabled $isEnabled');
      locationServiceEnabled = isEnabled;
    });

    Geolocator.checkPermission().then((permissions) {
      print('checkPermission $hasPermission');
      permission = permissions;
      hasPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (!hasPermission) {
        Geolocator.requestPermission().then((result) {
          print('requestPermission $result');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocListener<MapCubit, MapState>(
      listener: (context, state) {
        if (state is MapPlaceSelected) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceDetails(
                place: state.place,
              ),
            ),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            MapWidget(
              onMapCreated: (mapboxMap) async {
                context.read<MapCubit>().initializeMap(mapboxMap);
              },
              resourceOptions: ResourceOptions(
                accessToken: dotenv.env['MAPBOX_PUBLIC_TOKEN'] ?? '',
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 40,
                    left: isLandscape ? 0 : 10,
                    child: FloatingActionButton(
                      heroTag: 'person_add',
                      onPressed: () => Navigator.of(context).pushNamed(
                        FriendsScreen.routeName,
                      ),
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.people,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 110,
                    left: isLandscape ? 0 : 10,
                    child: FloatingActionButton(
                      heroTag: 'chat',
                      onPressed: () => Navigator.of(context).pushNamed(
                        ChatScreen.routeName,
                      ),
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.chat_bubble,
                      ),
                    ),
                  ),
                  // Positioned(
                  //   top: 180,
                  //   left: isLandscape ? 0 : 10,
                  //   child: FloatingActionButton(
                  //     heroTag: 'report',
                  //     onPressed: () => print('report'),
                  //     backgroundColor: Colors.white,
                  //     child: const Icon(Icons.warning_rounded),
                  //   ),
                  // ),
                  Positioned(
                    top: 180,
                    left: isLandscape ? 0 : 10,
                    child: FloatingActionButton(
                      heroTag: 'settings',
                      onPressed: () => Navigator.of(context).pushNamed(
                        SettingsScreen.routeName,
                      ),
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.settings),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 10,
                    child: FloatingActionButton(
                      heroTag: 'directions',
                      onPressed: () => _showSearch(context),
                      backgroundColor: Colors.blue,
                      child: const Icon(
                        Icons.directions,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 110,
                    right: 10,
                    child: FloatingActionButton(
                      heroTag: 'center',
                      onPressed: () => context.read<MapCubit>().centerCamera(),
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.gps_fixed),
                    ),
                  ),
                  BlocBuilder<MapCubit, MapState>(
                    builder: (context, state) {
                      if (state is MapRouteBuilt) {
                        return RouteDetailsPanel(
                          distance: state.distance,
                          duration: state.duration,
                          onRouteDetailsClose: () =>
                              context.read<MapCubit>().hideRoute(),
                          onNavigate: () =>
                              context.read<MapCubit>().startNavigation(),
                        );
                      } else if (state is RouteLoading) {
                        return _buildRouteLoadingPanel(context);
                      }
                      return BlocProvider(
                        create: (context) => NearestCubit(
                          GetIt.I.get<PlaceRepository>(),
                        ),
                        child: NearestPanel(
                          onShowPlaces:
                              context.read<MapCubit>().showNearbyPlaces,
                          onGetDirections: (routeOptions) {
                            context.read<MapCubit>().getRoute(
                                  RouteRequest(
                                    originLat: context
                                        .read<MapCubit>()
                                        .currentPosition!
                                        .latitude,
                                    originLng: context
                                        .read<MapCubit>()
                                        .currentPosition!
                                        .longitude,
                                    destinationLat: routeOptions['latitude'],
                                    destinationLng: routeOptions['longitude'],
                                    truckWeight:
                                        double.parse(routeOptions['weight']),
                                    truckHeight:
                                        double.parse(routeOptions['height']),
                                    truckWidth:
                                        double.parse(routeOptions['width']),
                                    truckAvoidFerries:
                                        routeOptions['avoidFerries'],
                                    truckAvoidTolls: routeOptions['avoidTolls'],
                                    truckAvoidHighways:
                                        routeOptions['avoidHighways'],
                                    isImperial: routeOptions['isImperial'],
                                  ),
                                );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    Navigator.of(context)
        .pushNamed(
      SearchScreen.routeName,
    )
        .then((result) {
      final routeRequest = result as RouteRequest?;
      if (routeRequest != null) {
        context.read<MapCubit>().getRoute(routeRequest);
      }
    });
  }

  Widget _buildRouteLoadingPanel(BuildContext context) {
    return Positioned(
      bottom: 35,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Calculating route...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
