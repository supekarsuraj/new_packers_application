import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../lib/views/map_picker_screen.dart';
import '../models/ServiceEnquiryData.dart';
import 'ServiceSelectionScreen.dart';
import 'ThankYouScreen.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class SubCategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final int? customerId; // Added customerId

  const SubCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.customerId,
  });

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class SubCategory {
  final int categoryId;
  final int id;
  final int subCategoryService;
  final String subCategoryName;
  final String categoryName;

  SubCategory({
    required this.categoryId,
    required this.id,
    required this.subCategoryService,
    required this.subCategoryName,
    required this.categoryName,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      categoryId: json['category_id'] as int,
      id: json['id'] as int,
      subCategoryService: json['sub_category_service'] as int,
      subCategoryName: json['sub_categoryname'] as String,
      categoryName: json['category_name'] as String,
    );
  }
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  List<SubCategory> subCategories = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSubCategories();
  }

  Future<void> _fetchSubCategories() async {
    try {
      final String apiUrl =
          'https://54kidsstreet.org/api/subCategory/${widget.categoryId}';
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
          final List<dynamic> subCategoryData = jsonData['data'];
          setState(() {
            subCategories =
                subCategoryData.map((data) => SubCategory.fromJson(data)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonData['msg'] ?? 'Failed to load subcategories';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load subcategories: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching subcategories: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildSubCategoryButton(SubCategory subCategory) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: ElevatedButton(
          onPressed: () {
            if (subCategory.subCategoryService == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceSelectionScreen(
                    subCategoryId: subCategory.id,
                    subCategoryName: subCategory.subCategoryName,
                    customerId: widget.customerId, // Pass customerId
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceFormScreen(
                    subCategoryId: subCategory.id,
                    subCategoryName: subCategory.subCategoryName,
                    customerId: widget.customerId,
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: mediumBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            subCategory.subCategoryName,
            style: const TextStyle(
              color: whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.categoryName}',
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
      body: Container(
        color: whiteColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: darkBlue))
              : errorMessage != null
              ? Center(
            child: Text(
              errorMessage!,
              style: const TextStyle(color: darkBlue),
            ),
          )
              : subCategories.isEmpty
              ? const Center(
              child: Text('No subcategories available',
                  style: TextStyle(color: darkBlue)))
              : ListView.builder(
            itemCount: subCategories.length,
            itemBuilder: (context, index) {
              final subCategory = subCategories[index];
              return _buildSubCategoryButton(subCategory);
            },
          ),
        ),
      ),
    );
  }
}

class ServiceFormScreen extends StatefulWidget {
  final int subCategoryId;
  final String subCategoryName;
  final int? customerId; // Added customerId

  const ServiceFormScreen({
    super.key,
    required this.subCategoryId,
    required this.subCategoryName,
    this.customerId,
  });

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceDescriptionController = TextEditingController();
  final _serviceLocationController = TextEditingController();
  final _flatNumberController = TextEditingController();
  DateTime? _selectedDate;
  LatLng? _selectedLocation;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: darkBlue,
              onPrimary: whiteColor,
              surface: whiteColor,
            ),
            dialogBackgroundColor: whiteColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (result != null && result is Map) {
      setState(() {
        _serviceLocationController.text = result['address'] ?? 'Unknown location';
        _selectedLocation = result['coordinates'];
      });
      Fluttertoast.showToast(msg: "Location selected successfully");
    } else {
      Fluttertoast.showToast(msg: "No location selected");
    }
  }

  Future<ServiceEnquiryResponse?> _submitServiceEnquiry() async {
    try {
      const String apiUrl = 'https://54kidsstreet.org/api/enquiry/storeServiceEnquiry';

      // Prepare form data
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add form fields
      request.fields['customer_id'] = widget.customerId?.toString() ?? '0';
      request.fields['service_name'] = widget.subCategoryName;
      request.fields['service_description'] = _serviceDescriptionController.text.trim();
      request.fields['service_location'] = _serviceLocationController.text.trim();
      request.fields['flat_no'] = _flatNumberController.text.trim();
      request.fields['service_date'] = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : '';

      // Add coordinates if available
      if (_selectedLocation != null) {
        request.fields['latitude'] = _selectedLocation!.latitude.toString();
        request.fields['longitude'] = _selectedLocation!.longitude.toString();
      }

      // Set headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return ServiceEnquiryResponse.fromJson(jsonData);
      } else {
        print('Failed to submit enquiry: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error submitting enquiry: $e');
      return null;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        ServiceEnquiryResponse? response = await _submitServiceEnquiry();

        setState(() {
          _isSubmitting = false;
        });

        if (response != null && response.status) {
          // Navigate to Thank You screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ThankYouScreen(serviceResponse: response),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?.msg ?? 'Failed to submit service request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a service date')),
        );
      }
    }
  }

  @override
  void dispose() {
    _serviceDescriptionController.dispose();
    _serviceLocationController.dispose();
    _flatNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subCategoryName,
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
      body: Container(
        color: whiteColor,
        child: Column(
          children: [
            // Banner and Description Section
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Image
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: lightBlue,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/parcelwala4.jpg',
                        image: 'https://54kidsstreet.org/admin_assets/subcategories/914856cf99a820e3f21995180f0adbe8.jpg',
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/parcelwala4.jpg',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    'Professional ${widget.subCategoryName} service at your doorstep.\n'
                        'Experienced technicians with quality service guarantee.\n'
                        'Book your service now and get instant confirmation.',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Form Section - Scrollable
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Display Service Name as a read-only text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Service Name',
                            style: TextStyle(
                              color: darkBlue,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.subCategoryName,
                              style: const TextStyle(
                                color: darkBlue,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _serviceDescriptionController,
                        decoration: InputDecoration(
                          labelText: 'Service Description',
                          labelStyle: const TextStyle(color: darkBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: mediumBlue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the service description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _serviceLocationController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Service Location',
                          labelStyle: const TextStyle(color: darkBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: mediumBlue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.location_on, color: mediumBlue),
                            onPressed: _pickLocation,
                          ),
                        ),
                        onTap: _pickLocation,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a service location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _flatNumberController,
                        decoration: InputDecoration(
                          labelText: 'Flat Number',
                          labelStyle: const TextStyle(color: darkBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: mediumBlue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the flat number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Service Date',
                            labelStyle: const TextStyle(color: darkBlue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: mediumBlue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _selectedDate == null
                                ? 'Select a date'
                                : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                            style: const TextStyle(color: darkBlue),
                          ),
                        ),
                      ),
                      if (_selectedDate == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Please select a service date',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            // Submit Button - Fixed at bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mediumBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                    color: whiteColor,
                    strokeWidth: 2,
                  )
                      : const Text(
                    'Submit',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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