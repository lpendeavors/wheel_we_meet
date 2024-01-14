import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class GeoRepository {
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  });
}

class GeoRepositoryImpl implements GeoRepository {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;
  final FirebaseAuth auth;

  GeoRepositoryImpl(
    this.firestore,
    this.functions,
    this.auth,
  );

  @override
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final userId = auth.currentUser!.uid;

    final userDoc = await firestore.collection('users').doc(userId).get();
    final locationId = userDoc.data()!['locationId'];

    final friends = userDoc.data()!['friends'] as List<dynamic>;
    final locationIds = <String>[];

    for (var friend in friends) {
      final friendDoc = await firestore.collection('users').doc(friend).get();
      final friendLocationId = friendDoc.data()!['locationId'];
      locationIds.add(friendLocationId);
    }

    var url = Uri.parse(
      '${dotenv.get('GEO_SERVICE')}/geo/update-location',
    );

    final token = await auth.currentUser!.getIdToken();
    var response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
      body: <String, dynamic>{
        'locationId': locationId,
        'latitude': jsonEncode(latitude),
        'longitude': jsonEncode(longitude),
        'locationIds': jsonEncode(locationIds),
      },
    );

    if (response.statusCode == 200) {
      print('close friends: ${response.body}');

      final closeLocationIds = (jsonDecode(response.body) as List)
          .map((e) => e.toString())
          .toList()
          .cast<String>();

      if (closeLocationIds.isNotEmpty) {
        final userIds = <String>[];

        for (var locationId in closeLocationIds) {
          final userDoc = await firestore
              .collection('users')
              .where('locationId', isEqualTo: locationId)
              .get();

          if (userDoc.docs.isNotEmpty) {
            final userId = userDoc.docs.first.id;
            userIds.add(userId);
          }
        }

        await firestore.runTransaction((transaction) async {
          transaction.update(
            firestore.collection('users').doc(userId),
            {'friendsNearby': userIds},
          );

          transaction.set(
            firestore.collection('notifications').doc(),
            {
              'type': 'proximity',
              'title': 'You have a friend nearby',
              'body': 'Open the app to see who is nearby',
              'userIds': [...userIds, userId],
              'createdAt': FieldValue.serverTimestamp(),
              'readStatus': {userId: false},
              'createdBy': userId,
            },
          );
        });
      }
    } else {
      print(response.statusCode);
      throw Exception('Failed to update location');
    }
  }
}
