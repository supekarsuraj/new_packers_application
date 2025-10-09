import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/ShiftData.dart';
import '../../views/YourFinalScreen.dart';
import 'map_picker_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

const Color whiteColor = Color(0xFFf7f7f7);
const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);

class LocationSelectionScreen extends StatefulWidget {
  final ShiftData shiftData;

  const LocationSelectionScreen({super.key, required this.shiftData});

  @override
  _LocationSelectionScreenState createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _sourceLocalityController =
  TextEditingController();
  final TextEditingController _destinationLocalityController =
  TextEditingController();
  bool _normalLiftSource = false;
  bool _serviceLiftSource = false;
  int _floorSource = 0;
  bool _normalLiftDestination = false;
  bool _serviceLiftDestination = false;
  int _floorDestination = 0;

  // Date and Time variables
  String selectedDate = '';
  String selectedTime = '';
  final List<String> timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM'
  ];

  @override
  void initState() {
    super.initState();
    _normalLiftSource = widget.shiftData.normalLiftSource;
    _serviceLiftSource = widget.shiftData.serviceLiftSource;
    _floorSource = widget.shiftData.floorSource;
    _normalLiftDestination = widget.shiftData.normalLiftDestination;
    _serviceLiftDestination = widget.shiftData.serviceLiftDestination;
    _floorDestination = widget.shiftData.floorDestination;
    // Initialize text controllers with existing addresses if available
    _sourceLocalityController.text = widget.shiftData.sourceAddress ?? '';
    _destinationLocalityController.text =
        widget.shiftData.destinationAddress ?? '';
    // Initialize date and time from shiftData if available
    selectedDate = widget.shiftData.selectedDate;
    selectedTime = widget.shiftData.selectedTime;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: mediumBlue,
              onPrimary: whiteColor,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = '${picked.day}/${picked.month}/${picked.year}';
        widget.shiftData.selectedDate = selectedDate;
      });
    }
  }

  Future<void> _pickLocation(bool isSource) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (result != null && result is Map) {
      setState(() {
        if (isSource) {
          _sourceLocalityController.text =
              result['address'] ?? 'Unknown location';
          widget.shiftData.sourceCoordinates = result['coordinates'];
          widget.shiftData.sourceAddress = result['address'];
        } else {
          _destinationLocalityController.text =
              result['address'] ?? 'Unknown location';
          widget.shiftData.destinationCoordinates = result['coordinates'];
          widget.shiftData.destinationAddress = result['address'];
        }
      });
      Fluttertoast.showToast(msg: "Location selected successfully");
    } else {
      Fluttertoast.showToast(msg: "No location selected");
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
                  // Date and Time Selection Section
                  const Text(
                    'When to shift?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectDate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mediumBlue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            selectedDate.isEmpty ? 'Select date' : selectedDate,
                            style: const TextStyle(
                              color: whiteColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText: 'Select time',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          value: selectedTime.isEmpty ? null : selectedTime,
                          items: timeSlots.map((String time) {
                            return DropdownMenuItem<String>(
                              value: time,
                              child: Text(time, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedTime = newValue;
                                widget.shiftData.selectedTime = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Source Section
                  const Text('Source',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      suffixIcon:
                      const Icon(Icons.location_on, color: mediumBlue),
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
                      const Text('Floor',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: mediumBlue),
                            onPressed: _floorSource > 0
                                ? () => setState(() => _floorSource--)
                                : null,
                          ),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              _floorSource.toString(),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: mediumBlue),
                            onPressed: () => setState(() => _floorSource++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Destination Section
                  const Text('Destination',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      suffixIcon:
                      const Icon(Icons.location_on, color: mediumBlue),
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
                      const Text('Floor',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: mediumBlue),
                            onPressed: _floorDestination > 0
                                ? () => setState(() => _floorDestination--)
                                : null,
                          ),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              _floorDestination.toString(),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: mediumBlue),
                            onPressed: () =>
                                setState(() => _floorDestination++),
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

          // Next Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Validate date and time
                  if (selectedDate.isEmpty || selectedTime.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select date and time'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Validate locations
                  if (_sourceLocalityController.text.isEmpty ||
                      _destinationLocalityController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please select both source and destination locations'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Update shiftData with all values
                  widget.shiftData.floorSource = _floorSource;
                  widget.shiftData.floorDestination = _floorDestination;
                  widget.shiftData.selectedDate = selectedDate;
                  widget.shiftData.selectedTime = selectedTime;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          YourFinalScreen(shiftData: widget.shiftData),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}