import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RouteDetailsPanel extends StatefulWidget {
  final String distance;
  final String duration;
  final Function() onRouteDetailsClose;
  final Function() onNavigate;

  const RouteDetailsPanel({
    super.key,
    required this.distance,
    required this.duration,
    required this.onRouteDetailsClose,
    required this.onNavigate,
  });

  @override
  RouteDetailsPanelState createState() => RouteDetailsPanelState();
}

class RouteDetailsPanelState extends State<RouteDetailsPanel> {
  late DateTime eta;
  Timer? updateTimer;

  @override
  void initState() {
    super.initState();

    final intDuration = int.parse(widget.duration.split(' ')[0]);
    eta = DateTime.now().add(Duration(minutes: intDuration));

    updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        eta = eta.add(const Duration(seconds: 1));
      });
    });
  }

  @override
  void dispose() {
    updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 35,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Route Details',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Arrive By: ${DateFormat('h:mm a').format(eta)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onRouteDetailsClose,
                ),
              ],
            ),
            Divider(
              height: 20,
              thickness: 1,
              color: Colors.grey[100],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailColumn('Distance', widget.distance),
                const VerticalDivider(thickness: 1),
                _buildDetailColumn('Duration', widget.duration),
              ],
            ),
            Divider(
              height: 20,
              thickness: 1,
              color: Colors.grey[100],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onNavigate,
                icon: const Icon(
                  Icons.navigation,
                  color: Colors.white,
                ),
                label: const Text(
                  'Start Navigation',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
