// lib/views/EnquiryThankYouScreen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/EnquiryResponse.dart';
import 'HomeServiceView.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class EnquiryThankYouScreen extends StatelessWidget {
  final EnquiryResponse enquiryResponse;

  const EnquiryThankYouScreen({super.key, required this.enquiryResponse});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 80,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                enquiryResponse.msg,
                style: const TextStyle(
                  fontSize: 18,
                  color: darkBlue,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enquiry Details:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildDetailRow('Customer ID:', enquiryResponse.data?.customerId ?? 'N/A'),
                    _buildDetailRow('Order Number:', '#${enquiryResponse.data?.orderNo ?? 'N/A'}'),
                    _buildDetailRow('Pickup Location:', enquiryResponse.data?.pickupLocation ?? 'N/A'),
                    _buildDetailRow('Drop Location:', enquiryResponse.data?.dropLocation ?? 'N/A'),
                    _buildDetailRow('Flat/Shop No:', enquiryResponse.data?.flatShopNo ?? 'N/A'),
                    _buildDetailRow('Shipping Date:', enquiryResponse.data?.shippingDateTime ?? 'N/A'),
                    _buildDetailRow('Floor Number:', enquiryResponse.data?.floorNumber ?? 'N/A'),
                    _buildDetailRow('Pickup Service Lift:', enquiryResponse.data?.pickupServicesLift ?? 'N/A'),
                    _buildDetailRow('Drop Service Lift:', enquiryResponse.data?.dropServicesLift ?? 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (enquiryResponse.data?.productsItem != null && enquiryResponse.data!.productsItem.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Products:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 15),
                      ..._parseAndDisplayProducts(enquiryResponse.data!.productsItem),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: lightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Our team will contact you soon to confirm your shifting request. Thank you for choosing Mumbai Metro Packers and Movers!',
                  style: TextStyle(
                    fontSize: 16,
                    color: darkBlue,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeServiceView()),
                          (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mediumBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: whiteColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _parseAndDisplayProducts(String productsJson) {
    try {
      // First decode outer JSON string
      final decoded = json.decode(productsJson);

      // If still string, decode again (handle double encoding)
      List<dynamic> products =
      decoded is String ? json.decode(decoded) : decoded;

      return products.map((product) {
        String productName = product['product_name'] ?? 'Unknown Product';
        String quantity = product['quantity'] ?? '0';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon for product
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: mediumBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chair_alt, color: mediumBlue),
                ),
                const SizedBox(width: 12),

                // Product name
                Expanded(
                  child: Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: darkBlue,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),

                // Quantity badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: mediumBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Qty: $quantity',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList();
    } catch (e) {
      return [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "Error parsing products: ${e.toString()}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.red,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ];
    }
  }


  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkBlue,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: darkBlue,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}