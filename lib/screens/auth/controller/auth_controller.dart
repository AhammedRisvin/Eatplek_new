import 'dart:async';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/service/notification_services.dart';

enum AuthStep { form, otp }

class AuthController extends GetxController {
  // ── Text editing controllers ───────────────────────────────────────────────
  late TextEditingController phoneController;
  late TextEditingController otpController;

  // ── State ──────────────────────────────────────────────────────────────────
  AuthStep _currentStep = AuthStep.form;
  bool _isLoading = false;

  // ── Timer ──────────────────────────────────────────────────────────────────
  Timer? _timer;
  int _remainingTime = 45;

  // ── Device info ────────────────────────────────────────────────────────────
  String _deviceOs = '';
  String _deviceName = '';

  // ── FCM token ──────────────────────────────────────────────────────────────
  String get _firebaseToken => NotificationService.instance.fcmToken ?? '';

  // ── API ────────────────────────────────────────────────────────────────────
  late FittorConnect _apiClient;

  // ── Getters ────────────────────────────────────────────────────────────────
  AuthStep get currentStep => _currentStep;
  bool get isFormStep => _currentStep == AuthStep.form;
  bool get isOtpStep => _currentStep == AuthStep.otp;
  bool get isLoading => _isLoading;

  int get remainingTime => _remainingTime;
  bool get canResend => _remainingTime == 0;

  String get title =>
      _currentStep == AuthStep.otp
          ? 'Verify Your Mobile Number'
          : 'Let\'s Get You Started!';

  String get subtitle =>
      _currentStep == AuthStep.otp
          ? 'We\'ve sent a 6-digit OTP to $maskedPhoneNumber. Please enter it below.'
          : 'Login to explore delicious meals and exclusive offers.';

  String get buttonText =>
      _currentStep == AuthStep.otp ? 'Verify OTP' : 'Send OTP';

  String get switchText =>
      _currentStep == AuthStep.otp ? 'Didn\'t receive the code?' : '';

  String get switchActionText {
    if (_currentStep == AuthStep.otp) {
      return canResend
          ? 'Resend OTP'
          : 'Resend in ${_formatTime(_remainingTime)}';
    }
    return '';
  }

  String get maskedPhoneNumber {
    if (phoneController.text.length == 10) {
      final phone = phoneController.text;
      return '+91 ${phone.substring(0, 2)}XXX XXX${phone.substring(7)}';
    }
    return '+91 XXXXX XXXXX';
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController();
    otpController = TextEditingController();
    _apiClient = FittorConnect();
    _initDeviceInfo();
  }

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    _stopTimer();
    super.onClose();
  }

  // ── Device Info ────────────────────────────────────────────────────────────
  Future<void> _initDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (GetPlatform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        _deviceOs = 'Android';
        _deviceName = '${info.manufacturer} ${info.model}';
      } else if (GetPlatform.isIOS) {
        final info = await deviceInfo.iosInfo;
        _deviceOs = 'iOS';
        _deviceName = info.model;
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
      _deviceOs = GetPlatform.isAndroid ? 'Android' : 'iOS';
      _deviceName = 'Unknown Device';
    }
  }

  // ── Timer ──────────────────────────────────────────────────────────────────
  void startTimer() {
    _remainingTime = 45;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ── Auth flow ──────────────────────────────────────────────────────────────
  void handleAuthAction() {
    if (_currentStep == AuthStep.otp) {
      handleOtpVerification();
    } else {
      handleLogin();
    }
  }

  void handleLogin() {
    if (phoneController.text.isEmpty) {
      _showErrorSnackbar('Error', 'Please enter your mobile number');
      return;
    }
    if (phoneController.text.length != 10) {
      _showErrorSnackbar(
        'Error',
        'Please enter a valid 10-digit mobile number',
      );
      return;
    }
    _sendOtp();
  }

  Future<void> _sendOtp() async {
    try {
      _setLoading(true);

      final response = await _apiClient.post<Map<String, dynamic>>(
        endpoint: Urls.login,
        data: {
          'dialCode': '+91',
          'phone': phoneController.text.trim(),
          'firebaseToken': _firebaseToken,
          'deviceOs': _deviceOs,
          'deviceName': _deviceName,
        },
      );

      if (response['success'] == true) {
        _currentStep = AuthStep.otp;
        otpController.clear();
        startTimer();
        update(['auth_screen']);
      } else {
        _showErrorSnackbar(
          'Error',
          response['message'] ?? 'Failed to send OTP',
        );
      }
    } catch (e) {
      _showErrorSnackbar('Error', e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendOtp() async {
    if (!canResend) return;

    try {
      _setLoading(true);

      await _apiClient.post<Map<String, dynamic>>(
        endpoint: Urls.login,
        data: {
          'dialCode': '+91',
          'phone': phoneController.text.trim(),
          'firebaseToken': _firebaseToken,
          'deviceOs': _deviceOs,
          'deviceName': _deviceName,
        },
      );

      Get.snackbar('Success', 'OTP sent successfully!');
      startTimer();
      update(['auth_screen']);
    } catch (e) {
      _showErrorSnackbar('Error', e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> handleOtpVerification() async {
    if (otpController.text.isEmpty) {
      _showErrorSnackbar('Error', 'Please enter the OTP');
      return;
    }
    if (otpController.text.length != 6) {
      _showErrorSnackbar('Error', 'Please enter a valid 6-digit OTP');
      return;
    }

    try {
      _setLoading(true);

      final response = await _apiClient.post<Map<String, dynamic>>(
        endpoint: Urls.verifyOtp,
        data: {
          'dialCode': '+91',
          'phone': phoneController.text.trim(),
          'otp': otpController.text.trim(),
          'deviceOs': _deviceOs,
          'deviceName': _deviceName,
          'firebaseToken': _firebaseToken,
        },
      );

      if (response['success'] == true) {
        final status = response['status'] as String?;

        if (status == 'pending') {
          // ── New user — store data and go to profile completion ──────────
          await _storeUserData(response);
          Get.put<AuthController>(this, permanent: true);
          Get.offAllNamed(Routes.profileCompletion);
        } else if (status == 'registered') {
          // ── Existing user — store data, identify in OneSignal, go home ──
          await _storeUserData(response);
          _identifyUserInOneSignal(response: response);
          Get.snackbar('Success', response['message'] ?? 'Login successful!');
          Get.offAllNamed(Routes.bottomNav);
        }
      } else {
        _showErrorSnackbar(
          'Error',
          response['message'] ?? 'OTP verification failed',
        );
      }
    } catch (e) {
      _showErrorSnackbar('Error', e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ── OneSignal — existing user login path ───────────────────────────────────
  void _identifyUserInOneSignal({required Map<String, dynamic> response}) {
    final data = response['data'] as Map<String, dynamic>?;
    final userId = data?['id'] as String? ?? '';

    if (userId.isEmpty) {
      log('⚠️ OneSignal setUser skipped — id missing from response');
      return;
    }

    final district = data?['district'] as String? ?? '';

    NotificationService.instance.setUser(userId);
    NotificationService.instance.setTags({
      'user_type': 'customer',
      'district': district.isNotEmpty ? district : 'unknown',
    });

    log('✅ OneSignal user identified: $userId | district: $district');
  }

  // ── Data storage ───────────────────────────────────────────────────────────
  //
  // Only used for the OTP verify response (both pending + registered).
  // Profile completion data is stored by ProfileCompletionController.
  //
  // Status rule: never downgrade — if Store is already "registered",
  // a "pending" response cannot overwrite it.
  Future<void> _storeUserData(Map<String, dynamic> response) async {
    try {
      final accessToken = response['accessToken'] as String? ?? '';
      final refreshToken = response['refreshToken'] as String? ?? '';

      if (accessToken.isNotEmpty) {
        await Store.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        _apiClient.setAuthToken();
        log('✅ Tokens saved and auth header updated');
      }

      // ── Never downgrade status ─────────────────────────────────────────
      final incomingStatus = response['status'] as String? ?? '';
      if (incomingStatus == 'registered') {
        Store.status = 'registered';
      } else if (Store.status != 'registered') {
        Store.status = incomingStatus;
      }

      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        Store.id = data['id'] as String? ?? '';
        Store.name = data['name'] as String? ?? '';
        Store.phone = data['phone'] as String? ?? '';
        Store.district = data['district'] as String? ?? '';
        Store.state = data['state'] as String? ?? '';
        Store.place = data['place'] as String? ?? '';
        Store.profileImage = data['profileImage'] as String? ?? '';
        Store.profileComplete = data['profileComplete'] as bool? ?? false;

        debugPrint(
          '💾 User stored — id: ${Store.id} | name: ${Store.name} | '
          'status: ${Store.status} | district: ${Store.district}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error storing user data: $e');
    }
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    update(['auth_screen']);
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
