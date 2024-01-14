import 'package:flutter/material.dart';

import '../../widgets/truck_details.dart';
import 'bloc/nearest_vm.dart';

class PlaceDetails extends StatelessWidget {
  final PlaceVM place;

  const PlaceDetails({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (place.address != null)
                    _DetailItem(
                      icon: Icons.location_on,
                      title: "Address",
                      content: place.address!,
                    ),
                  _DetailItem(
                    icon: Icons.linear_scale,
                    title: "Distance",
                    content: "${place.distance} miles",
                  ),
                  if (place.showers > 0)
                    _DetailItem(
                      icon: Icons.bathtub,
                      title: "Showers",
                      content: "${place.showers}",
                    ),
                  if (place.parkingSpaces > 0)
                    _DetailItem(
                      icon: Icons.local_parking,
                      title: "Parking Spaces",
                      content: "${place.parkingSpaces}",
                    ),
                  if (place.scales)
                    _DetailItem(
                      icon: Icons.balance,
                      title: "Scales",
                      content: place.scales ? 'Yes' : 'No',
                    ),
                  if (place.amenities != null && place.amenities!.isNotEmpty)
                    _AmenitiesList(amenities: place.amenities!),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const TruckDetailsFormDialog(),
                        ).then((truckDetails) {
                          if (truckDetails != null) {
                            Navigator.of(context).pop(
                              {
                                ...truckDetails,
                                'latitude': place.latitude,
                                'longitude': place.longitude,
                              },
                            );
                          }
                        });
                      },
                      icon: const Icon(
                        Icons.directions,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Get Directions',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _DetailItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenitiesList extends StatelessWidget {
  final List<String> amenities;

  const _AmenitiesList({
    Key? key,
    required this.amenities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Amenities",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: amenities
                .map((amenity) => Chip(
                      label: Text(amenity),
                      labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1?.color,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
