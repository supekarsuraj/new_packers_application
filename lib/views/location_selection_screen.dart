import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_picker_screen.dart';
import 'next_button.dart';

const Color whiteColor = Color(0xFFf7f7f7);
const Color darkBlue = Color(0xFF03669d);

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  _LocationSelectionScreenState createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _sourceLocalityController = TextEditingController();
  final TextEditingController _destinationLocalityController = TextEditingController();
  bool _normalLiftSource = false;
  bool _serviceLiftSource = false;
  int _floorSource = 0;
  bool _normalLiftDestination = false;
  bool _serviceLiftDestination = false;
  int _floorDestination = 0;

  Future<void> _pickLocation(bool isSource) async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (selectedLocation != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          selectedLocation.latitude,
          selectedLocation.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String address = '${place.name ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}';
          setState(() {
            if (isSource) {
              _sourceLocalityController.text = address;
            } else {
              _destinationLocalityController.text = address;
            }
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error getting address: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'Shift My House',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Source',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Locality'),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _sourceLocalityController,
                    readOnly: true,
                    onTap: () => _pickLocation(true),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text('Normal Lift Available'),
                    value: _normalLiftSource,
                    onChanged: (value) {
                      setState(() {
                        _normalLiftSource = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  CheckboxListTile(
                    title: const Text('Service Lift Available'),
                    value: _serviceLiftSource,
                    onChanged: (value) {
                      setState(() {
                        _serviceLiftSource = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Floor'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: _floorSource > 0 ? () => setState(() => _floorSource--) : null,
                          ),
                          Text(_floorSource.toString()),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.red),
                            onPressed: () => setState(() => _floorSource++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Destination',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Locality'),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _destinationLocalityController,
                    readOnly: true,
                    onTap: () => _pickLocation(false),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text('Normal Lift Available'),
                    value: _normalLiftDestination,
                    onChanged: (value) {
                      setState(() {
                        _normalLiftDestination = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  CheckboxListTile(
                    title: const Text('Service Lift Available'),
                    value: _serviceLiftDestination,
                    onChanged: (value) {
                      setState(() {
                        _serviceLiftDestination = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Floor'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: _floorDestination > 0 ? () => setState(() => _floorDestination--) : null,
                          ),
                          Text(_floorDestination.toString()),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.red),
                            onPressed: () => setState(() => _floorDestination++),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const NextButton(),
        ],
      ),
    );
  }
}