import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/ShiftData.dart';

class YourFinalScreen extends StatelessWidget {
  final ShiftData shiftData;

  const YourFinalScreen({super.key, required this.shiftData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${shiftData.serviceName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Date: ${shiftData.selectedDate}'),
            Text('Time: ${shiftData.selectedTime}'),
            Text('Total Products: ${shiftData.getTotalProductCount()}'),
            const SizedBox(height: 16),
            const Text('Selected Products:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ...shiftData.selectedProducts.map((product) => Text('${product.productName}: ${product.count}')).toList(),
            const SizedBox(height: 16),
            const Text('Source Location:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Coordinates: ${shiftData.sourceCoordinates?.latitude}, ${shiftData.sourceCoordinates?.longitude}'),
            Text('Floor: ${shiftData.floorSource}'),
            Text('Normal Lift: ${shiftData.normalLiftSource}'),
            Text('Service Lift: ${shiftData.serviceLiftSource}'),
            const SizedBox(height: 16),
            const Text('Destination Location:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Coordinates: ${shiftData.destinationCoordinates?.latitude}, ${shiftData.destinationCoordinates?.longitude}'),
            Text('Floor: ${shiftData.floorDestination}'),
            Text('Normal Lift: ${shiftData.normalLiftDestination}'),
            Text('Service Lift: ${shiftData.serviceLiftDestination}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add submission logic here (e.g., API call)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order submitted!')),
                );
                Navigator.pop(context); // Return to previous screen
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}