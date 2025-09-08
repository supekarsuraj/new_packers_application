import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'HomeServiceView.dart';

class OTPScreen extends StatefulWidget {
  final String mobileNumber;

  const OTPScreen({super.key, required this.mobileNumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  static const Color darkBlue = Color(0xFF03669d);
  static const Color mediumBlue = Color(0xFF37b3e7);
  static const Color lightBlue = Color(0xFF7ed2f7);

  List<TextEditingController> otpControllers =
  List.generate(6, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  bool isLoading = false;
  bool isResendLoading = false;
  int resendTimer = 30; // 30 seconds
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
    final otp = otpControllers.map((controller) => controller.text).join().trim();
    developer.log('[OTPScreen] 📥 OTP constructed: "$otp" (length: ${otp.length})',
        name: 'flutter', level: 800);
    return otp;
  }

  Future<bool> verifyOTP(String otp) async {
    try {
      developer.log('[OTPScreen] 🔍 Verifying OTP: "$otp" for mobile: ${widget.mobileNumber}',
          name: 'flutter', level: 800);

      String baseUrl = 'http://54kidsstreet.org'; // For production
      // String baseUrl = 'http://127.0.0.1:8000'; // Uncomment for local testing
      // String baseUrl = 'http://10.0.2.2:8000'; // Uncomment for Android emulator
      // String baseUrl = 'http://<your-machine-ip>:8000'; // Uncomment for physical device local testing

      final url = '$baseUrl/api/customers/${widget.mobileNumber}/otpverify?otp=$otp';
      developer.log('[OTPScreen] 🌐 API URL: $url', name: 'flutter', level: 800);

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      developer.log('[OTPScreen] 📊 Response Status Code: ${response.statusCode}',
          name: 'flutter', level: 800);
      developer.log('[OTPScreen] 📄 Response Headers: ${response.headers}',
          name: 'flutter', level: 800);
      developer.log('[OTPScreen] 📝 Raw Response Body: ${response.body}',
          name: 'flutter', level: 800);

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final responseData = json.decode(response.body);
            developer.log('[OTPScreen] ✅ Parsed Response: $responseData',
                name: 'flutter', level: 800);

            if (responseData is Map &&
                (responseData.containsKey('status') && responseData['status'] == true ||
                    responseData.containsKey('success') && responseData['success'] == true ||
                    responseData.containsKey('message') && responseData['message'].toString().toLowerCase().contains('success') ||
                    responseData.containsKey('verified') && responseData['verified'] == true ||
                    responseData.containsKey('result') && responseData['result'].toString().toLowerCase() == 'verified')) {
              developer.log('[OTPScreen] ✅ OTP verification successful',
                  name: 'flutter', level: 800);
              return true;
            } else {
              developer.log('[OTPScreen] ❌ Response does not indicate success: $responseData',
                  name: 'flutter', level: 800);
              return false;
            }
          } catch (e) {
            developer.log('[OTPScreen] ⚠️ JSON parsing error: $e',
                name: 'flutter', level: 800);
            developer.log('[OTPScreen] ✅ Assuming success due to status 200',
                name: 'flutter', level: 800);
            return true; // Assume success for 200 if JSON parsing fails
          }
        } else {
          developer.log('[OTPScreen] ✅ Empty response body, assuming success for status 200',
              name: 'flutter', level: 800);
          return true;
        }
      } else {
        developer.log('[OTPScreen] ❌ OTP verification failed with status: ${response.statusCode} - ${response.body}',
            name: 'flutter', level: 800);
        return false;
      }
    } catch (e) {
      developer.log('[OTPScreen] 💥 Error verifying OTP: $e',
          name: 'flutter', level: 800);
      return false;
    }
  }

  Future<bool> resendOTP() async {
    try {
      developer.log('[OTPScreen] 📤 Resending OTP for mobile: ${widget.mobileNumber}',
          name: 'flutter', level: 800);

      String baseUrl = 'http://54kidsstreet.org';
      final url = '$baseUrl/api/customers/${widget.mobileNumber}/otp';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      developer.log('[OTPScreen] 📊 Resend Response Status: ${response.statusCode}',
          name: 'flutter', level: 800);
      developer.log('[OTPScreen] 📝 Resend Response Body: ${response.body}',
          name: 'flutter', level: 800);

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('[OTPScreen] ✅ OTP resend successful',
            name: 'flutter', level: 800);
        return true;
      } else {
        developer.log('[OTPScreen] ❌ Failed to resend OTP: ${response.statusCode} - ${response.body}',
            name: 'flutter', level: 800);
        return false;
      }
    } catch (e) {
      developer.log('[OTPScreen] 💥 Error resending OTP: $e',
          name: 'flutter', level: 800);
      return false;
    }
  }

  void onOTPChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  void submitOTP() async {
    String otp = getOTP();
    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      developer.log('[OTPScreen] ❌ OTP length invalid or contains non-digits: "$otp"',
          name: 'flutter', level: 800);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
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
      developer.log('[OTPScreen] ✅ Navigating to HomeServiceView',
          name: 'flutter', level: 800);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeServiceView(),
        ),
      );
    } else {
      developer.log('[OTPScreen] ❌ Showing invalid OTP message',
          name: 'flutter', level: 800);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );

      for (var controller in otpControllers) {
        controller.clear();
      }
      focusNodes[0].requestFocus();
    }
  }

  void handleResendOTP() async {
    developer.log('[OTPScreen] 🔄 handleResendOTP called, resendTimer: $resendTimer, isResendLoading: $isResendLoading',
        name: 'flutter', level: 800);
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
        resendTimer = 30;
      });
      startResendTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: Colors.green,
        ),
      );

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
              const Text(
                'OTP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
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
                            resendTimer >= 60
                                ? '${(resendTimer ~/ 60).toString().padLeft(2, '0')}:${(resendTimer % 60).toString().padLeft(2, '0')}'
                                : '$resendTimer',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submitOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
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
                      'Submit',
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