import 'dart:async';

import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AuthStep { form, otp }

class AuthController extends GetxController {
  // Text editing controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // State variables
  bool _isLogin = true;
  AuthStep _currentStep = AuthStep.form;

  // Timer variables
  Timer? _timer;
  int _remainingTime = 45;

  // Getters
  bool get isLogin => _isLogin;
  bool get isSignUp => !_isLogin;
  AuthStep get currentStep => _currentStep;
  bool get isFormStep => _currentStep == AuthStep.form;
  bool get isOtpStep => _currentStep == AuthStep.otp;
  int get remainingTime => _remainingTime;
  bool get canResend => _remainingTime == 0;

  // Content getters based on current mode and step
  String get title {
    if (_currentStep == AuthStep.otp) {
      return 'Verify Your Mobile Number';
    }
    return _isLogin ? 'Let\'s Get You Started!' : 'Create Your Account!';
  }

  String get subtitle {
    if (_currentStep == AuthStep.otp) {
      return 'We\'ve sent a 6-digit OTP to $maskedPhoneNumber. Please enter it below.';
    }
    return _isLogin
        ? 'Login to explore delicious meals and exclusive offers.'
        : 'Join us and start exploring delicious food now!';
  }

  String get buttonText {
    if (_currentStep == AuthStep.otp) {
      return 'Verify OTP';
    }
    return _isLogin ? 'Login' : 'Sign Up';
  }

  String get switchText {
    if (_currentStep == AuthStep.otp) {
      return 'Didn\'t receive the code?';
    }
    return _isLogin ? 'Don\'t have an account?' : 'Already have an account?';
  }

  String get switchActionText {
    if (_currentStep == AuthStep.otp) {
      return canResend ? ' Resend OTP' : ' Resend in ${_formatTime(_remainingTime)}';
    }
    return _isLogin ? ' Sign Up' : ' Login';
  }

  String get maskedPhoneNumber {
    if (phoneController.text.length == 10) {
      return '+91 ${phoneController.text.substring(0, 2)}XXX XXX${phoneController.text.substring(7)}';
    }
    return '+91 XXXXX XXXXX';
  }

  // Methods
  void toggleAuthMode() {
    if (_currentStep == AuthStep.otp) {
      if (canResend) {
        resendOtp();
      }
      return;
    }

    _isLogin = !_isLogin;
    _currentStep = AuthStep.form;
    clearFields();
    update(['auth_screen']);
  }

  void clearFields() {
    phoneController.clear();
    nameController.clear();
    otpController.clear();
  }

  void goToOtpStep() {
    _currentStep = AuthStep.otp;
    startTimer();
    update(['auth_screen']);
  }

  void goBackToForm() {
    _currentStep = AuthStep.form;
    otpController.clear();
    _stopTimer();
    update(['auth_screen']);
  }

  void startTimer() {
    _remainingTime = 45;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        update(['auth_screen']);
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void resendOtp() {
    if (!canResend) return;

    // Add your resend OTP logic here
    print('Resending OTP to ${phoneController.text}');
    Get.snackbar('Success', 'OTP sent successfully!');

    startTimer();
    update(['auth_screen']);
  }

  void handleAuthAction() {
    if (_currentStep == AuthStep.otp) {
      handleOtpVerification();
    } else if (_isLogin) {
      handleLogin();
    } else {
      handleSignUp();
    }
  }

  void handleLogin() {
    // Validate phone number
    if (phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your mobile number', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (phoneController.text.length != 10) {
      Get.snackbar(
        'Error',
        'Please enter a valid 10-digit mobile number',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Add your login logic here (send OTP)
    print('Sending OTP for login to: ${phoneController.text}');
    Get.snackbar('Success', 'OTP sent successfully!');
    goToOtpStep();
  }

  void handleSignUp() {
    // Validate name
    if (nameController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your full name', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (nameController.text.trim().length < 2) {
      Get.snackbar('Error', 'Please enter a valid full name', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Validate phone number
    if (phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your mobile number', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (phoneController.text.length != 10) {
      Get.snackbar(
        'Error',
        'Please enter a valid 10-digit mobile number',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Add your signup logic here (send OTP)
    print('Sending OTP for signup to: ${phoneController.text}');
    Get.snackbar('Success', 'OTP sent successfully!');
    goToOtpStep();
  }

  void handleOtpVerification() {
    // Validate OTP
    if (otpController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter the OTP', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (otpController.text.length != 6) {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Add your OTP verification logic here
    print('Verifying OTP: ${otpController.text}');

    // Simulate OTP verification
    if (otpController.text == '123456') {
      Get.snackbar('Success', '${_isLogin ? 'Login' : 'Sign up'} successful!');
      Store.userToken = 'sample_token'; // Store the user token
      Get.offAllNamed(Routes.bottomNav);
    } else {
      Get.snackbar('Error', 'Invalid OTP. Please try again.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    nameController.dispose();
    otpController.dispose();
    _stopTimer();
    super.onClose();
  }
}
