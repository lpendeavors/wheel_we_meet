import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

import 'firebase_options.dart';
import 'app/app.dart';
import 'repositories/repositories.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;
  final functions = FirebaseFunctions.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  final conversationRepository = ConversationRepositoryImpl(
    auth,
    firestore,
    storage,
  );

  GetIt.I.registerSingleton<ConversationRepository>(
    conversationRepository,
  );

  final userRepository = UserRepositoryImpl(
    auth,
    firestore,
    storage,
  );

  GetIt.I.registerSingleton<UserRepository>(
    userRepository,
  );

  final addressRepisitory = AddressRepositoryImpl(
    functions,
  );

  GetIt.I.registerSingleton<AddressRepository>(
    addressRepisitory,
  );

  final routeRepository = RouteRepositoryImpl(
    functions,
    firestore,
    auth,
  );

  GetIt.I.registerSingleton<RouteRepository>(
    routeRepository,
  );

  final placeRepository = PlaceRepositoryImpl(
    auth,
  );

  GetIt.I.registerSingleton<PlaceRepository>(
    placeRepository,
  );

  final geoRepository = GeoRepositoryImpl(
    firestore,
    functions,
    auth,
  );

  GetIt.I.registerSingleton<GeoRepository>(
    geoRepository,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // runZonedGuarded(() {
  //   runApp(
  //     const MyApp(),
  //   );
  // }, (error, stackTrace) {
  //   FirebaseCrashlytics.instance.recordError(error, stackTrace);
  // });

  runApp(
    const MyApp(),
  );
}
