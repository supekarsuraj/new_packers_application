// models/ShiftData.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../views/SelectedProduct.dart';

class ShiftData {
  final int serviceId;
  final String serviceName;
  final String selectedDate;
  final String selectedTime;
  final List<SelectedProduct> selectedProducts;

  // Customer ID field
  int? customerId;

  // Location data
  String? sourceAddress;
  String? destinationAddress;
  LatLng? sourceCoordinates;
  LatLng? destinationCoordinates;

  // Floor and lift data
  int floorSource = 0;
  int floorDestination = 0;
  bool normalLiftSource = false;
  bool serviceLiftSource = false;
  bool normalLiftDestination = false;
  bool serviceLiftDestination = false;

  ShiftData({
    required this.serviceId,
    required this.serviceName,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedProducts,
    this.customerId,
    this.sourceAddress,
    this.destinationAddress,
    this.sourceCoordinates,
    this.destinationCoordinates,
    this.floorSource = 0,
    this.floorDestination = 0,
    this.normalLiftSource = false,
    this.serviceLiftSource = false,
    this.normalLiftDestination = false,
    this.serviceLiftDestination = false,
  });

  int getTotalProductCount() {
    return selectedProducts.fold(0, (sum, product) => sum + product.count);
  }
}