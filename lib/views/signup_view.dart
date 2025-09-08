import 'package:flutter/material.dart';

import 'HomeServiceView.dart';

class SignupView extends StatelessWidget {
  final String mobileNumber;

  const SignupView({super.key, required this.mobileNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Signup'),
        backgroundColor: const Color(0xFF03669d),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Mobile Number: $mobileNumber'),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Submit signup details to API and navigate to HomeServiceView or OTPSuccessView
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeServiceView()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03669d),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Complete Signup',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}