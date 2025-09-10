import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../views/SelectedProduct.dart';

class ShiftData {
  final int serviceId;
  final String serviceName;
  final String selectedDate;
  final String selectedTime;
  final List<SelectedProduct> selectedProducts;
  LatLng? sourceCoordinates;
  LatLng? destinationCoordinates;
  int floorSource;
  int floorDestination;
  bool normalLiftSource;
  bool serviceLiftSource;
  bool normalLiftDestination;
  bool serviceLiftDestination;

  ShiftData({
    required this.serviceId,
    required this.serviceName,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedProducts,
    this.sourceCoordinates,
    this.destinationCoordinates,
    this.floorSource = 0,
    this.floorDestination = 0,
    this.normalLiftSource = false,
    this.serviceLiftSource = false,
    this.normalLiftDestination = false,
    this.serviceLiftDestination = false,
  });// Method to get total product count
  int getTotalProductCount() {
    return selectedProducts.fold(0, (sum, product) => sum + product.count);
  }
}