import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../lib/views/login_view.dart';
import '../viewmodels/login_viewmodel.dart';
import 'signup_view.dart';
import 'OTPSuccessView.dart';

class signupOtpView extends StatelessWidget {
  const signupOtpView({super.key});

  static const Color darkBlue = Color(0xFF03669d);
  static const Color mediumBlue = Color(0xFF37b3e7);
  static const Color lightBlue = Color(0xFF7ed2f7);
  static const Color whiteColor = Color(0xFFf7f7f7);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Signup'),
              backgroundColor: darkBlue,
              foregroundColor: Colors.white,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/applogo.jpeg',
                    height: 150,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      counterText: '',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '🇮🇳',
                              style: TextStyle(fontSize: 20), // Adjust flag size
                            ),
                            SizedBox(width: 6),
                            Text(
                              '+91',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      viewModel.setMobileNumber(value);
                    },
                  )
                  ,
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () {
                      viewModel.requestOTP();
                      if (viewModel.mobileNumber.length == 10) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const SignupView(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: viewModel.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Add Number',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                      );
                    },
                    child: const Text('Already have an account ? Login'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
