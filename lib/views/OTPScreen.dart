import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'HomeServiceView.dart';

class OTPScreen extends StatefulWidget {
  final String mobileNumber;

  const OTPScreen({super.key, required this.mobileNumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  static const Color darkBlue = Color(0xFF03669d); // Same as login view
  static const Color mediumBlue = Color(0xFF37b3e7);
  static const Color lightBlue = Color(0xFF7ed2f7);

  List<TextEditingController> otpControllers =
  List.generate(6, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  bool isLoading = false;
  bool isResendLoading = false;
  int resendTimer = 25;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  void startResendTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer > 0) {
        setState(() {
          resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String getOTP() {
    return otpControllers.map((controller) => controller.text).join();
  }

  Future<bool> verifyOTP(String otp) async {
    try {
      print('🔍 Verifying OTP: $otp for mobile: ${widget.mobileNumber}');

      // Change this URL based on your API location
      String baseUrl = 'http://54kidsstreet.org'; // For domain
      // String baseUrl = 'http://127.0.0.1:8000'; // For localhost - uncomment if needed

      final url = '$baseUrl/api/customers/${widget.mobileNumber}/otpverify?otp=$otp';
      print('🌐 API URL: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📊 Response Status Code: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');
      print('📝 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Check if response contains success indicator
        if (response.body.isNotEmpty) {
          try {
            final responseData = json.decode(response.body);
            print('✅ Parsed Response: $responseData');

            // Check for various success indicators in response
            if (responseData.containsKey('success') && responseData['success'] == true) {
              return true;
            } else if (responseData.containsKey('status') && responseData['status'] == 'success') {
              return true;
            } else if (responseData.containsKey('message') &&
                responseData['message'].toString().toLowerCase().contains('success')) {
              return true;
            } else if (responseData.containsKey('verified') && responseData['verified'] == true) {
              return true;
            } else {
              print('❌ Response does not indicate success: $responseData');
              return false;
            }
          } catch (e) {
            print('⚠️ JSON parsing failed, assuming success based on status code: $e');
            return true;
          }
        } else {
          print('✅ Empty response body, assuming success based on status code 200');
          return true;
        }
      } else if (response.statusCode == 404) {
        print('❌ API endpoint not found (404)');
        return false;
      } else if (response.statusCode == 400) {
        print('❌ Bad request (400) - Invalid OTP format or expired');
        return false;
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized (401) - Wrong OTP');
        return false;
      } else {
        print('❌ OTP verification failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Error verifying OTP: $e');
      return false;
    }
  }

  Future<bool> resendOTP() async {
    try {
      print('📤 Resending OTP for mobile: ${widget.mobileNumber}');

      // Change this URL based on your API location
      String baseUrl = 'http://54kidsstreet.org'; // For domain
      // String baseUrl = 'http://127.0.0.1:8000'; // For localhost - uncomment if needed

      final url = '$baseUrl/api/customers/${widget.mobileNumber}/otp';
      print('🌐 Resend API URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📊 Resend Response Status: ${response.statusCode}');
      print('📝 Resend Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('❌ Failed to resend OTP: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Error resending OTP: $e');
      return false;
    }
  }

  void onOTPChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    // Auto-submit when all 6 digits are entered
    if (index == 5 && value.isNotEmpty) {
      String fullOtp = getOTP();
      if (fullOtp.length == 6) {
        submitOTP();
      }
    }
  }

  void submitOTP() async {
    String otp = getOTP();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    bool isVerified = await verifyOTP(otp);

    setState(() {
      isLoading = false;
    });

    if (isVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeServiceView(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );

      // Clear OTP fields
      for (var controller in otpControllers) {
        controller.clear();
      }
      focusNodes[0].requestFocus();
    }
  }

  void handleResendOTP() async {
    if (resendTimer > 0 || isResendLoading) return;

    setState(() {
      isResendLoading = true;
    });

    bool otpSent = await resendOTP();

    setState(() {
      isResendLoading = false;
    });

    if (otpSent) {
      setState(() {
        resendTimer = 25;
      });
      startResendTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear existing OTP
      for (var controller in otpControllers) {
        controller.clear();
      }
      focusNodes[0].requestFocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to resend OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 120,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Logo
              Container(
                height: 150,
                width: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/applogo.jpeg'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // OTP Title
              const Text(
                'OTP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 30),

              // OTP + Resend Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: resendTimer == 0 && !isResendLoading ? handleResendOTP : null,
                          child: Text(
                            'Resend OTP',
                            style: TextStyle(
                              fontSize: 14,
                              color: resendTimer > 0 ? Colors.grey : darkBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (resendTimer > 0)
                          Text(
                            '$resendTimer',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else if (isResendLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(darkBlue),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: handleResendOTP,
                            child: const Icon(
                              Icons.refresh,
                              color: darkBlue,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // OTP Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 40,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      controller: otpControllers[index],
                      focusNode: focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => onOTPChanged(value, index),
                      onTap: () {
                        otpControllers[index].selection =
                            TextSelection.fromPosition(
                              TextPosition(offset: otpControllers[index].text.length),
                            );
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 40),

              // Login Button - Same style as LoginView
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submitOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue, // Same color as login view
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                        : const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}