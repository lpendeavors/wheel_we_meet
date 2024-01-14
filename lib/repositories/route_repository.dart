import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/map/route_request.dart';

abstract class RouteRepository {
  Future<dynamic> getRoute(
    RouteRequest request,
    double currentLng,
    double currentLat,
  );

  Future<void> saveActiveRoute(
    dynamic route,
  );

  Future<void> clearActiveRoute(
    String routeId,
  );
}

class RouteRepositoryImpl extends RouteRepository {
  final FirebaseFunctions functions;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  RouteRepositoryImpl(this.functions, this.firestore, this.auth);

  @override
  Future<dynamic> getRoute(
    RouteRequest request,
    double currentLng,
    double currentLat,
  ) async {
    try {
      final callable = functions.httpsCallable('generateRoute');
      final response = await callable.call({
        ...request.toJson(),
        'originLat': currentLat,
        'originLng': currentLng,
      });

      if (response.data != null && response.data is Map) {
        return response.data;
      } else {
        print('No route data received');
        return null;
      }
    } catch (e) {
      print('Error getting route: $e');
      return null;
    }
  }

  @override
  Future<void> clearActiveRoute(String routeId) {
    // TODO: implement clearActiveRoute
    throw UnimplementedError();
  }

  @override
  Future<void> saveActiveRoute(dynamic route) {
    // TODO: implement saveActiveRoute
    throw UnimplementedError();
  }
}
