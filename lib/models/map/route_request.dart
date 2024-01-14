import 'package:equatable/equatable.dart';

class RouteRequest extends Equatable {
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final double truckWeight;
  final double truckHeight;
  final double truckWidth;
  final bool truckAvoidFerries;
  final bool truckAvoidTolls;
  final bool truckAvoidHighways;
  final bool isImperial;

  const RouteRequest({
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.truckWeight,
    required this.truckHeight,
    required this.truckWidth,
    required this.truckAvoidFerries,
    required this.truckAvoidTolls,
    required this.truckAvoidHighways,
    required this.isImperial,
  });

  @override
  List<Object?> get props => [
        originLat,
        originLng,
        destinationLat,
        destinationLng,
        truckWeight,
        truckHeight,
        truckWidth,
        truckAvoidFerries,
        truckAvoidTolls,
        truckAvoidHighways,
        isImperial,
      ];

  Map<String, dynamic> toJson() {
    return {
      'originLat': originLat,
      'originLng': originLng,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'truckWeight': truckWeight,
      'truckHeight': truckHeight,
      'truckWidth': truckWidth,
      'truckAvoidFerries': truckAvoidFerries,
      'truckAvoidTolls': truckAvoidTolls,
      'truckAvoidHighways': truckAvoidHighways,
      'isImperial': isImperial,
    };
  }
}
