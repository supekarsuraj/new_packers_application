import 'package:flutter/material.dart';
import '/views/PendingScreen.dart';

class MyRequestScreen extends StatelessWidget {
  const MyRequestScreen({super.key});
  static const Color darkBlue = Color(0xFF03669d); // Logo background
  static const Color mediumBlue = Color(0xFF37b3e7); // Header / borders
  static const Color lightBlue = Color(0xFF7ed2f7); // Highlights
  static const Color whiteColor = Color(0xFFf7f7f7);

  void _navigateToPending(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PendingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Request',
          style: TextStyle(color: darkBlue, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Request 30810',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () => _navigateToPending(context), // Added navigation here
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: darkBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.domain,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Moving type: Commercial, Office',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'From: Parel, Mumbai, Maharashtra, India',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'To: 280, Panvel, Akurli, Navi Mumbai, ...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),

    );
  }
}