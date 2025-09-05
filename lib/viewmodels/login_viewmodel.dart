import 'package:flutter/material.dart';
import '../models/login_model.dart';

class LoginViewModel with ChangeNotifier {
  final LoginModel _model;
  String _mobileNumber = '';
  String _errorMessage = '';
  bool _isLoading = false;

  LoginViewModel() : _model = LoginModel(mobileNumber: '');

  String get mobileNumber => _mobileNumber;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  void setMobileNumber(String value) {
    _mobileNumber = value;
    _model.mobileNumber = value;
    notifyListeners();
  }

  // Method to manually set loading state (used by LoginView)
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> requestOTP() async {
    if (_mobileNumber.isEmpty || _mobileNumber.length != 10) {
      _errorMessage = 'Please enter a valid 10-digit mobile number';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      bool success = await _model.requestOTP();
      if (success) {
        _errorMessage = 'OTP sent successfully!';
      } else {
        _errorMessage = 'Failed to send OTP. Try again.';
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> makeCall(String phoneNumber) async {
    try {
      await _model.makeCall(phoneNumber);
    } catch (e) {
      _errorMessage = 'Failed to make call. Please try again.';
      notifyListeners();
    }
  }

  void clearErrorMessage() {
    _errorMessage = '';
    notifyListeners();
  }

  void clearMobileNumber() {
    _mobileNumber = '';
    _model.mobileNumber = '';
    notifyListeners();
  }
}