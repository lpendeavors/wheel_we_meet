class NearestVM {
  String category;
  List<PlaceVM> places;

  NearestVM({
    required this.category,
    required this.places,
  });
}

class PlaceVM {
  String id;
  String name;
  String? address;
  double distance;
  List<String>? amenities;
  int showers;
  int parkingSpaces;
  bool scales;
  double latitude;
  double longitude;
  dynamic geometry;

  PlaceVM({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.amenities,
    required this.showers,
    required this.parkingSpaces,
    required this.scales,
    required this.latitude,
    required this.longitude,
    required this.geometry,
  });
}
