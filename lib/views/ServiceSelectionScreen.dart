import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../lib/views/location_selection_screen.dart';
import '../models/ShiftData.dart';
import 'ProductSelectionScreen.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class ServiceSelectionScreen extends StatefulWidget {
  final int subCategoryId;
  final String subCategoryName;

  const ServiceSelectionScreen({
    super.key,
    required this.subCategoryId,
    required this.subCategoryName,
  });

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class Service {
  final int id;
  final int subCategoryId;
  final String serviceName;

  Service({
    required this.id,
    required this.subCategoryId,
    required this.serviceName,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      subCategoryId: json['subCategory_id'] as int,
      serviceName: json['service_name'] as String,
    );
  }
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  List<Service> services = [];
  bool isLoading = true;
  String? errorMessage;
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
  Map<int, int> serviceProductCounts = {}; // Track product counts per service ID

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final String apiUrl =
          'https://54kidsstreet.org/api/Services/${widget.subCategoryId}';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          final List<dynamic> serviceData = jsonData['data'];
          setState(() {
            services =
                serviceData.map((data) => Service.fromJson(data)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonData['msg'] ?? 'Failed to load services';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load services: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching services: $e';
        isLoading = false;
      });
    }
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
      });
    }
  }

  void _updateServiceCount(int serviceId, int count) {
    setState(() {
      serviceProductCounts[serviceId] = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subCategoryName} Services',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 20,
          ),
        ),
        backgroundColor: darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'When to shift?',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
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
                      style: const TextStyle(color: whiteColor),
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
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24), // ✅ fixed
            const Text(
              'Select Services',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16), // ✅ fixed
            Expanded(
              child: isLoading
                  ? const Center(
                  child: CircularProgressIndicator(color: darkBlue))
                  : errorMessage != null
                  ? Center(
                  child: Text(errorMessage!,
                      style: const TextStyle(color: darkBlue)))
                  : services.isEmpty
                  ? const Center(
                  child: Text('No services available',
                      style: TextStyle(color: darkBlue)))
                  : ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  final count =
                      serviceProductCounts[service.id] ?? 0;
                  return Padding(
                    padding:
                    const EdgeInsets.only(bottom: 12.0),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (selectedDate.isEmpty || selectedTime.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select date and time first'),
                                  ),
                                );
                                return;
                              }
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductSelectionScreen(
                                    serviceId: service.id,
                                    serviceName: service.serviceName,
                                    selectedDate: selectedDate,
                                    selectedTime: selectedTime,
                                  ),
                                ),
                              );
                              if (result is int && result > 0) {
                                _updateServiceCount(service.id, result);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mediumBlue,
                              minimumSize: const Size(double.infinity, 55), // full width + height
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), // rounded look
                              ),
                            ),
                            child: Text(
                              service.serviceName,
                              style: const TextStyle(
                                color: whiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            right: 12,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                  );
                },
              ),
            ),
            const SizedBox(height: 16), // ✅ fixed
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (serviceProductCounts.values
                      .every((count) => count == 0)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please select products for at least one service'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  // Proceed to next screen (e.g., LocationSelectionScreen)
                  final shiftData = ShiftData(
                    serviceId: 0,
                    serviceName: 'Multiple Services',
                    selectedDate: selectedDate,
                    selectedTime: selectedTime,
                    selectedProducts: [],
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LocationSelectionScreen(shiftData: shiftData),
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
          ],
        ),
      ),
    );
  }
}
