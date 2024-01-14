import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/map/route_request.dart';
import '../../widgets/debouncer.dart';
import 'bloc/search_cubit.dart';
import 'bloc/search_state.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  bool isImperial = true;
  bool truckAvoidFerries = false;
  bool truckAvoidTolls = false;
  bool truckAvoidHighways = false;
  bool _isRouteOptionsExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Destination'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRouteOptions(),
                    const SizedBox(height: 20),
                    const Text(
                      'Destination',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDestinationSearchInput(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteOptions() {
    return ExpansionPanelList(
      elevation: 0,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _isRouteOptionsExpanded = !_isRouteOptionsExpanded;
        });
      },
      children: [
        ExpansionPanel(
          canTapOnHeader: true,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return const ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              title: Text(
                'Truck Measurements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
          body: _buildRouteOptionsContent(),
          isExpanded: _isRouteOptionsExpanded,
        ),
      ],
    );
  }

  Widget _buildRouteOptionsContent() {
    return Column(
      children: <Widget>[
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          title: Text(isImperial
              ? 'Imperial System (lbs, in)'
              : 'Metric System (kg, cm)'),
          value: isImperial,
          onChanged: (bool value) {
            setState(() {
              isImperial = value;
            });
          },
        ),
        _buildInputField(
          'Width',
          isImperial ? 'in' : 'cm',
          _widthController,
        ),
        const SizedBox(height: 8),
        _buildInputField(
          'Height',
          isImperial ? 'in' : 'cm',
          _heightController,
        ),
        const SizedBox(height: 8),
        _buildInputField(
          'Weight',
          isImperial ? 'lbs' : 'kg',
          _weightController,
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          title: const Text('Avoid Tolls'),
          value: truckAvoidTolls,
          onChanged: (bool value) {
            setState(() => truckAvoidTolls = value);
          },
        ),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          title: const Text('Avoid Highways'),
          value: truckAvoidHighways,
          onChanged: (bool value) {
            setState(() => truckAvoidHighways = value);
          },
        ),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          title: const Text('Avoid Ferries'),
          value: truckAvoidFerries,
          onChanged: (bool value) {
            setState(() => truckAvoidFerries = value);
          },
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    String unit,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        hintText: '$label ($unit)',
      ),
    );
  }

  Widget _buildDestinationSearchInput() {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Enter destination',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        Debouncer(milliseconds: 700).run(
          () => context.read<SearchCubit>().searchDestinations(value),
        );
      },
      onTap: () => setState(() => _isRouteOptionsExpanded = false),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder(
      bloc: context.read<SearchCubit>(),
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is SearchLoaded) {
          return Column(
            children: _buildSearchResultsList(state),
          );
        }
        if (state is SearchError) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        return const Center(
          child: Text('Start searching!'),
        );
      },
    );
  }

  List<ListTile> _buildSearchResultsList(SearchLoaded state) {
    return List.generate(
      state.searchResults.length,
      (index) {
        final result = state.searchResults[index];
        return ListTile(
          title: Text(result.name ?? ''),
          onTap: () {
            if (_weightController.text.isEmpty ||
                _widthController.text.isEmpty ||
                _heightController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter truck measurements'),
                ),
              );
              return;
            }

            Navigator.of(context).pop(RouteRequest(
              originLat: 0.0,
              originLng: 0.0,
              destinationLat: result.latitude!,
              destinationLng: result.longitude!,
              truckAvoidFerries: truckAvoidFerries,
              truckAvoidTolls: truckAvoidTolls,
              truckAvoidHighways: truckAvoidHighways,
              truckWeight: double.parse(_weightController.text),
              truckWidth: double.parse(_widthController.text),
              truckHeight: double.parse(_heightController.text),
              isImperial: isImperial,
            ));
          },
        );
      },
    );
  }
}
