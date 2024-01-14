import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/nearest_vm.dart';
import 'place_details.dart';
import 'bloc/nearest_cubit.dart';
import 'bloc/nearest_state.dart';

class NearestPanel extends StatefulWidget {
  final Function(Map<dynamic, dynamic> coords) onGetDirections;
  final Function(List<PlaceVM> places) onShowPlaces;

  const NearestPanel({
    super.key,
    required this.onGetDirections,
    required this.onShowPlaces,
  });

  @override
  NearestPanelState createState() => NearestPanelState();
}

class NearestPanelState extends State<NearestPanel> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    context.read<NearestCubit>().fetchNearestPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NearestCubit, NearestState>(
      listener: (context, state) {
        if (state is NearestSuccess && state.selected != null) {
          setState(() {
            _isExpanded = true;
          });
        } else {
          setState(() {
            _isExpanded = false;
          });
        }
      },
      child: Positioned(
        bottom: 35,
        left: 10,
        right: 10,
        child: AnimatedContainer(
          padding: const EdgeInsets.all(16),
          duration: const Duration(milliseconds: 300),
          height: _isExpanded ? 400 : 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: BlocBuilder<NearestCubit, NearestState>(
            builder: (context, state) {
              if (state is NearestSuccess) {
                widget.onShowPlaces(
                  state.places.map((p) => p.places).expand((p) => p).toList(),
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Places Nearby',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_isExpanded)
                          GestureDetector(
                            onTap: () => context
                                .read<NearestCubit>()
                                .selectCategory(state.selected!),
                            child: const Text(
                              'Collapse',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 60,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var place in state.places)
                              GestureDetector(
                                onTap: () => context
                                    .read<NearestCubit>()
                                    .selectCategory(place),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: state.selected == place
                                        ? Colors.blue[200]
                                        : Colors.blue[50],
                                  ),
                                  child: Center(
                                    child: Text(
                                      place.category,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (state.selected != null)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 600,
                                child: ListView.builder(
                                  itemCount: state.selected!.places.length,
                                  itemBuilder: (context, index) {
                                    final place = state.selected!.places[index];
                                    return ListTile(
                                      title: Text(
                                        place.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(place.address ?? ''),
                                      trailing: Text(
                                        '${place.distance} mi',
                                      ),
                                      onTap: () async {
                                        final options = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PlaceDetails(
                                              place:
                                                  state.selected!.places[index],
                                            ),
                                          ),
                                        );
                                        if (options != null) {
                                          widget.onGetDirections(options);
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              }

              if (state is NearestLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is NearestError) {
                return Center(
                  child: Text(state.message),
                );
              }

              return Container();
            },
          ),
        ),
      ),
    );
  }
}
