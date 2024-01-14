import 'package:cloud_functions/cloud_functions.dart';

import '../models/places/address_entity.dart';

abstract class AddressRepository {
  Stream<List<AddressEntity>> search(String query);
}

class AddressRepositoryImpl implements AddressRepository {
  final FirebaseFunctions functions;

  AddressRepositoryImpl(this.functions);

  @override
  Stream<List<AddressEntity>> search(String query) async* {
    if (query.isEmpty) {
      yield [];
      return;
    }

    final callable = functions.httpsCallable('getAddresses');
    final response = await callable.call({
      'query': query,
    });

    if (response.data != null && response.data is Map) {
      final data = Map<String, dynamic>.from(response.data);
      final features = data['features'] as List<dynamic>;

      if (features.isEmpty) {
        yield [];
        return;
      }

      List<AddressEntity> addresses = features
          .map(
              (item) => AddressEntity.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      yield addresses;
    } else {
      throw Exception('Failed to load addresses');
    }
  }
}
