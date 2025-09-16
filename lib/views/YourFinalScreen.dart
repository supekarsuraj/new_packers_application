import 'package:flutter/material.dart';
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
        child: ListView(
          children: [
            _buildInfoCard("Service", shiftData.serviceName),
            _buildInfoCard("Date", shiftData.selectedDate),
            _buildInfoCard("Time", shiftData.selectedTime),
            _buildInfoCard("Total Products",
                shiftData.getTotalProductCount().toString()),
            const SizedBox(height: 16),
            const Text("Selected Products:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ...shiftData.selectedProducts
                .map((p) => Text("${p.productName}: ${p.count}")),
            const SizedBox(height: 16),
            _buildInfoCard("Source",
                shiftData.sourceAddress ?? "${shiftData.sourceCoordinates}"),
            _buildInfoCard("Destination",
                shiftData.destinationAddress ?? "${shiftData.destinationCoordinates}"),
            _buildInfoCard("Source Floor", shiftData.floorSource.toString()),
            _buildInfoCard("Destination Floor",
                shiftData.floorDestination.toString()),
            _buildInfoCard("Normal Lift Source",
                shiftData.normalLiftSource ? "Yes" : "No"),
            _buildInfoCard("Service Lift Source",
                shiftData.serviceLiftSource ? "Yes" : "No"),
            _buildInfoCard("Normal Lift Destination",
                shiftData.normalLiftDestination ? "Yes" : "No"),
            _buildInfoCard("Service Lift Destination",
                shiftData.serviceLiftDestination ? "Yes" : "No"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order submitted!')),
                );
                Navigator.pop(context);
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
