import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/places/place_entity.dart';

abstract class PlaceRepository {
  Future<List<PlaceEntity>> getPlaces(
    double latitude,
    double longitude,
  );
}

class PlaceRepositoryImpl extends PlaceRepository {
  final FirebaseAuth auth;

  PlaceRepositoryImpl(this.auth);

  @override
  Future<List<PlaceEntity>> getPlaces(
    double latitude,
    double longitude,
  ) async {
    var url = Uri.parse(
      '${dotenv.get('GEO_SERVICE')}/places/nearby?latitude=$latitude&longitude=$longitude',
    );

    final token = await auth.currentUser!.getIdToken();
    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => PlaceEntity.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load places');
    }
  }
}
