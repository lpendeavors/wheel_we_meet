import 'package:flutter/material.dart';

class PlacesScreen extends StatefulWidget {
  static const routeName = '/places';

  const PlacesScreen({super.key});

  @override
  PlacesScreenState createState() => PlacesScreenState();
}

class PlacesScreenState extends State<PlacesScreen> {
  // return basic scafold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Places'),
      ),
      body: const Center(
        child: Hero(
          tag: 'placesHero',
          child: Text('Places'),
        ),
      ),
    );
  }
}
