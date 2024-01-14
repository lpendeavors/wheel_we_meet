import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../models/places/place_entity.dart';
import '../../../repositories/repositories.dart';
import 'nearest_state.dart';
import 'nearest_vm.dart';

class NearestCubit extends Cubit<NearestState> {
  final PlaceRepository placeRepository;

  NearestVM? selected;

  NearestCubit(this.placeRepository) : super(NearestInitial());

  Future<void> fetchNearestPlaces() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      emit(NearestLoading());
      final places = await placeRepository.getPlaces(
        position.latitude,
        position.longitude,
      );
      emit(NearestSuccess(_placesToVM(places), null));
    } catch (e) {
      emit(NearestError(e.toString()));
    }
  }

  void selectCategory(NearestVM vm) {
    final currentState = state as NearestSuccess;
    if (vm == selected) {
      selected = null;
    } else {
      selected = vm;
    }
    emit(NearestSuccess(currentState.places, selected));
  }

  _placesToVM(List<PlaceEntity> places) {
    Map<String, List<PlaceVM>> categoryMap = {};

    for (var place in places) {
      List<String>? sortedAmenities = place.amenities;
      if (sortedAmenities != null) {
        sortedAmenities.sort((a, b) => a.compareTo(b));
      }

      final distance = place.distance / 1609;
      final roundedDistance = double.parse(
        distance.toStringAsFixed(1),
      );

      for (var category in place.categories!) {
        categoryMap.putIfAbsent(category, () => []);
        categoryMap[category]!.add(
          PlaceVM(
            id: place.id,
            name: place.name,
            address: place.address,
            distance: roundedDistance,
            amenities: sortedAmenities,
            showers: place.showers,
            parkingSpaces: place.parkingSpaces,
            scales: place.scales,
            latitude: place.location.coordinates[1],
            longitude: place.location.coordinates[0],
            geometry: place.location.toJson(),
          ),
        );
      }
    }

    return categoryMap.entries
        .map(
          (entry) => NearestVM(
            category: entry.key,
            places: entry.value,
          ),
        )
        .toList();
  }
}
