import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/ShiftData.dart';
import '../../views/YourFinalScreen.dart';
import '../../views/next_button.dart';
import 'map_picker_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

const Color whiteColor = Color(0xFFf7f7f7);
const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);

class LocationSelectionScreen extends StatefulWidget {
  final ShiftData shiftData;

  const LocationSelectionScreen({
    super.key,
    required this.shiftData,
  });

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

  @override
  void initState() {
    super.initState();
    // Initialize state with ShiftData values
    _normalLiftSource = widget.shiftData.normalLiftSource;
    _serviceLiftSource = widget.shiftData.serviceLiftSource;
    _floorSource = widget.shiftData.floorSource;
    _normalLiftDestination = widget.shiftData.normalLiftDestination;
    _serviceLiftDestination = widget.shiftData.serviceLiftDestination;
    _floorDestination = widget.shiftData.floorDestination;
  }

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
          localeIdentifier: "en_IN",
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String address = _buildAddressString(place);

          setState(() {
            if (isSource) {
              _sourceLocalityController.text = address;
              widget.shiftData.sourceCoordinates = selectedLocation;
            } else {
              _destinationLocalityController.text = address;
              widget.shiftData.destinationCoordinates = selectedLocation;
            }
          });

          Fluttertoast.showToast(
            msg: "Location selected successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          Fluttertoast.showToast(
            msg: "No address found for this location",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error getting address: ${e.toString()}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  String _buildAddressString(Placemark place) {
    List<String> addressComponents = [];
    if (place.name != null && place.name!.isNotEmpty) addressComponents.add(place.name!);
    if (place.subLocality != null && place.subLocality!.isNotEmpty) addressComponents.add(place.subLocality!);
    if (place.locality != null && place.locality!.isNotEmpty) addressComponents.add(place.locality!);
    if (place.postalCode != null && place.postalCode!.isNotEmpty) addressComponents.add(place.postalCode!);
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) addressComponents.add(place.administrativeArea!);
    return addressComponents.isNotEmpty ? addressComponents.join(", ") : "Unknown location";
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
                  Text(
                    'Total Products: ${widget.shiftData.getTotalProductCount()}',
                    style: const TextStyle(fontSize: 16, color: darkBlue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selected Date: ${widget.shiftData.selectedDate}',
                    style: const TextStyle(fontSize: 16, color: darkBlue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selected Time: ${widget.shiftData.selectedTime}',
                    style: const TextStyle(fontSize: 16, color: darkBlue),
                  ),
                  const SizedBox(height: 16),
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
                      hintText: 'Tap to select source location',
                      suffixIcon: const Icon(Icons.location_on, color: mediumBlue),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Normal Lift Available'),
                    value: _normalLiftSource,
                    onChanged: (value) {
                      setState(() {
                        _normalLiftSource = value!;
                        widget.shiftData.normalLiftSource = value;
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
                        widget.shiftData.serviceLiftSource = value;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Floor', style: TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: mediumBlue),
                            onPressed: _floorSource > 0 ? () => setState(() => _floorSource--) : null,
                          ),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              _floorSource.toString(),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: mediumBlue),
                            onPressed: () => setState(() => _floorSource++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
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
                      hintText: 'Tap to select destination location',
                      suffixIcon: const Icon(Icons.location_on, color: mediumBlue),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Normal Lift Available'),
                    value: _normalLiftDestination,
                    onChanged: (value) {
                      setState(() {
                        _normalLiftDestination = value!;
                        widget.shiftData.normalLiftDestination = value;
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
                        widget.shiftData.serviceLiftDestination = value;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Floor', style: TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: mediumBlue),
                            onPressed: _floorDestination > 0 ? () => setState(() => _floorDestination--) : null,
                          ),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              _floorDestination.toString(),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: mediumBlue),
                            onPressed: () => setState(() => _floorDestination++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          NextButton(
            totalProducts: widget.shiftData.getTotalProductCount(),
            selectedDate: widget.shiftData.selectedDate,
            selectedTime: widget.shiftData.selectedTime,
            onPressed: () {
              if (widget.shiftData.sourceCoordinates == null || widget.shiftData.destinationCoordinates == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select both source and destination locations'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              // Update floor and lift data before navigating
              widget.shiftData.floorSource = _floorSource;
              widget.shiftData.floorDestination = _floorDestination;
              // Navigate to the final screen with all data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => YourFinalScreen(shiftData: widget.shiftData), // Replace with your final screen
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}