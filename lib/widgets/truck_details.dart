import 'package:flutter/material.dart';

class TruckDetailsFormDialog extends StatefulWidget {
  const TruckDetailsFormDialog({super.key});

  @override
  TruckDetailsFormDialogState createState() => TruckDetailsFormDialogState();
}

class TruckDetailsFormDialogState extends State<TruckDetailsFormDialog> {
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  bool isImperial = true;
  bool truckAvoidTolls = false;
  bool truckAvoidHighways = false;
  bool truckAvoidFerries = false;

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Truck Details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text(isImperial
                  ? 'Imperial System (lbs, in)'
                  : 'Metric System (kg, cm)'),
              value: isImperial,
              onChanged: (value) => setState(() => isImperial = value),
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            ),
            _buildInputField(
                'Width', isImperial ? 'in' : 'cm', _widthController),
            const SizedBox(height: 8),
            _buildInputField(
                'Height', isImperial ? 'in' : 'cm', _heightController),
            const SizedBox(height: 8),
            _buildInputField(
                'Weight', isImperial ? 'lbs' : 'kg', _weightController),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Avoid Tolls'),
              value: truckAvoidTolls,
              onChanged: (value) => setState(() => truckAvoidTolls = value),
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            ),
            SwitchListTile(
              title: const Text('Avoid Highways'),
              value: truckAvoidHighways,
              onChanged: (value) => setState(() => truckAvoidHighways = value),
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            ),
            SwitchListTile(
              title: const Text('Avoid Ferries'),
              value: truckAvoidFerries,
              onChanged: (value) => setState(() => truckAvoidFerries = value),
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitForm,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Widget _buildInputField(
      String label, String unit, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: "$label ($unit)",
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  void _submitForm() {
    final width = _widthController.text;
    final height = _heightController.text;
    final weight = _weightController.text;

    if (width.isNotEmpty && height.isNotEmpty && weight.isNotEmpty) {
      Navigator.of(context).pop({
        'width': width,
        'height': height,
        'weight': weight,
        'avoidTolls': truckAvoidTolls,
        'avoidHighways': truckAvoidHighways,
        'avoidFerries': truckAvoidFerries,
        'isImperial': isImperial,
      });
    }
  }
}
