import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/settings/settings_entity.dart';

abstract class SettingsRepository {
  Stream<SettingsEntity> loadSettings(String userId);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final FirebaseFirestore _firestore;

  SettingsRepositoryImpl(this._firestore);

  @override
  Stream<SettingsEntity> loadSettings(String userId) {
    return _firestore
        .collection('settings')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      return SettingsEntity.fromJson({
        ...snapshot.data()!,
        'userId': snapshot.id,
      });
    });
  }
}
