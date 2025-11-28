import 'dart:async';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

enum AuthStep { form, otp }

class AuthController extends GetxController {
  // Text editing controllers
  late TextEditingController phoneController;
  late TextEditingController nameController;
  late TextEditingController otpController;

  // State variables
  AuthStep _currentStep = AuthStep.form;
  bool _isLoading = false;
  bool _isLocationLoading = false;
  bool _showProfileBottomSheet = false;
  bool _isLocationPermissionGranted = false;

  // Location variables
  double? _latitude;
  double? _longitude;
  String? _placeName;

  // Timer variables
  Timer? _timer;
  int _remainingTime = 45;

  // Device info
  late String _deviceOs = '';
  late String _deviceName = '';
  final String _firebaseToken = 'fcm_token_placeholder';

  // API
  late FittorConnect _apiClient;

  // Getters - Auth State
  AuthStep get currentStep => _currentStep;
  bool get isFormStep => _currentStep == AuthStep.form;
  bool get isOtpStep => _currentStep == AuthStep.otp;
  bool get isLoading => _isLoading;

  // Getters - Timer
  int get remainingTime => _remainingTime;
  bool get canResend => _remainingTime == 0;

  // Getters - Location
  bool get isLocationLoading => _isLocationLoading;
  bool get showProfileBottomSheet => _showProfileBottomSheet;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get placeName => _placeName;
  bool get isLocationPermissionGranted => _isLocationPermissionGranted;

  // Dynamic Content Getters
  String get title => _currentStep == AuthStep.otp ? 'Verify Your Mobile Number' : 'Let\'s Get You Started!';

  String get subtitle =>
      _currentStep == AuthStep.otp
          ? 'We\'ve sent a 6-digit OTP to $maskedPhoneNumber. Please enter it below.'
          : 'Login to explore delicious meals and exclusive offers.';

  String get buttonText => _currentStep == AuthStep.otp ? 'Verify OTP' : 'Send OTP';

  String get switchText => _currentStep == AuthStep.otp ? 'Didn\'t receive the code?' : '';

  String get switchActionText {
    if (_currentStep == AuthStep.otp) {
      return canResend ? 'Resend OTP' : 'Resend in ${_formatTime(_remainingTime)}';
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

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _apiClient = FittorConnect();
    _initializeDeviceInfo();
  }

  void _initializeControllers() {
    phoneController = TextEditingController();
    nameController = TextEditingController();
    otpController = TextEditingController();
  }

  @override
  void onClose() {
    phoneController.dispose();
    nameController.dispose();
    otpController.dispose();
    _stopTimer();
    _apiClient.dispose();
    super.onClose();
  }

  // ==================== Device Info ====================

  Future<void> _initializeDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (GetPlatform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceOs = 'Android';
        _deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (GetPlatform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceOs = 'iOS';
        _deviceName = iosInfo.model;
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
      _deviceOs = GetPlatform.isAndroid ? 'Android' : 'iOS';
      _deviceName = 'Unknown Device';
    }
  }

  // ==================== Form Navigation ====================

  void _reset() {
    phoneController.clear();
    nameController.clear();
    otpController.clear();
    _latitude = null;
    _longitude = null;
    _placeName = null;
  }

  void _goToOtpStep() {
    _currentStep = AuthStep.otp;
    otpController.clear();
    startTimer();
    update(['auth_screen']);
  }

  void _goToFormStep() {
    _currentStep = AuthStep.form;
    _stopTimer();
    update(['auth_screen']);
  }

  // ==================== Timer Management ====================

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
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ==================== OTP Handling ====================

  Future<void> resendOtp() async {
    if (!canResend) return;

    try {
      _setLoading(true);

      final body = {
        'dialCode': '+91',
        'phone': phoneController.text.trim(),
        'firebaseToken': _firebaseToken,
        'deviceOs': _deviceOs,
        'deviceName': _deviceName,
      };

      await _apiClient.post<Map<String, dynamic>>(endpoint: Urls.login, data: body);

      Get.snackbar('Success', 'OTP sent successfully!');
      startTimer();
      update(['auth_screen']);
    } catch (e) {
      _showErrorSnackbar('Error', e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==================== Authentication Flow ====================

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
      _showErrorSnackbar('Error', 'Please enter a valid 10-digit mobile number');
      return;
    }

    _sendOtp();
  }

  Future<void> _sendOtp() async {
    try {
      _setLoading(true);

      final body = {
        'dialCode': '+91',
        'phone': phoneController.text.trim(),
        'firebaseToken': _firebaseToken,
        'deviceOs': _deviceOs,
        'deviceName': _deviceName,
      };

      await _apiClient.post<Map<String, dynamic>>(endpoint: Urls.login, data: body);

      _goToOtpStep();
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

      final body = {
        'dialCode': '+91',
        'phone': phoneController.text.trim(),
        'otp': otpController.text.trim(),
        'deviceOs': _deviceOs,
        'deviceName': _deviceName,
        'firebaseToken': _firebaseToken,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(endpoint: Urls.verifyOtp, data: body);

      if (response['success'] == true) {
        final status = response['status'] as String?;
        debugPrint('OTP Verification Response: $response');

        if (status == 'pending') {
          // User needs to complete profile
          if (response.containsKey('token')) {
            Store.userToken = response['token'];
          }
          _showProfileBottomSheet = true;
          update(['auth_screen']);

          // Request location with delay
          Future.delayed(Duration(milliseconds: 500), () {
            _requestLocationPermission();
          });
        } else if (status == 'registered') {
          // Registered user - login immediately
          _storeUserData(response);
          Get.snackbar('Success', response['message'] ?? 'Login successful!');
          Get.offAllNamed(Routes.bottomNav);
        }
      } else {
        _showErrorSnackbar('Error', response['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      _showErrorSnackbar('Error', e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==================== Location Management ====================

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDialog();
        return;
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        _isLocationPermissionGranted = true;
        update(['auth_screen']);
        await _fetchCurrentLocation();
      }
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      _showErrorSnackbar('Error', 'Failed to request location permission');
    }
  }

  void _showPermissionDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs access to your location to complete your profile. '
            'Please enable location permission in settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Geolocator.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _requestLocationPermission();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      _setLocationLoading(true);

      debugPrint('🌍 Fetching location...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      debugPrint('✓ Location fetched: $_latitude, $_longitude');

      // Fetch place name asynchronously (don't wait if slow)
      _getPlaceNameFromCoordinates(position.latitude, position.longitude)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('⏱️ Place name fetch timed out, using fallback');
              _setFallbackPlaceName(position.latitude, position.longitude);
            },
          )
          .catchError((e) {
            debugPrint('Error in place name fetch: $e');
            _setFallbackPlaceName(position.latitude, position.longitude);
          });

      update(['auth_screen']);
    } catch (e) {
      debugPrint('❌ Error fetching location: $e');
      _showErrorSnackbar('Error', 'Failed to fetch location. Please try again.');
    } finally {
      _setLocationLoading(false);
    }
  }

  Future<void> _getPlaceNameFromCoordinates(double latitude, double longitude) async {
    try {
      debugPrint('Starting reverse geocoding for: $latitude, $longitude');

      // Add timeout to prevent hanging
      final placemarks = await placemarkFromCoordinates(latitude, longitude).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          debugPrint('Reverse geocoding timeout - using coordinates');
          throw TimeoutException('Reverse geocoding timed out');
        },
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _placeName = _buildPlaceNameString(place);
        debugPrint('✓ Place name resolved: $_placeName');
        update(['auth_screen']);
      } else {
        _setFallbackPlaceName(latitude, longitude);
      }
    } on TimeoutException catch (e) {
      debugPrint('⏱️ Timeout error: $e');
      _setFallbackPlaceName(latitude, longitude);
    } catch (e) {
      debugPrint('❌ Error getting place name: $e');
      _setFallbackPlaceName(latitude, longitude);
    }
  }

  /// Set fallback place name when reverse geocoding fails
  void _setFallbackPlaceName(double latitude, double longitude) {
    _placeName = 'Lat: ${latitude.toStringAsFixed(4)}, Long: ${longitude.toStringAsFixed(4)}';
    debugPrint('Using fallback place name: $_placeName');
    update(['auth_screen']);
  }

  /// Build a readable place name from Placemark
  String _buildPlaceNameString(Placemark placemark) {
    List<String> addressParts = [];

    // Add components in order of preference
    if (placemark.locality?.isNotEmpty == true) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      addressParts.add(placemark.administrativeArea!);
    }
    if (placemark.country?.isNotEmpty == true) {
      addressParts.add(placemark.country!);
    }

    return addressParts.isNotEmpty ? addressParts.join(', ') : 'Current Location';
  }

  // ==================== Profile Completion ====================

  Future<void> handleProfileCompletion() async {
    // Validate name
    if (nameController.text.trim().isEmpty) {
      _showErrorSnackbar('Error', 'Please enter your name');
      return;
    }

    if (nameController.text.trim().length < 2) {
      _showErrorSnackbar('Error', 'Name must be at least 2 characters');
      return;
    }

    // Validate location
    if (_latitude == null || _longitude == null) {
      _showErrorSnackbar('Error', 'Location is required. Please try again.');
      return;
    }

    try {
      _setLoading(true);

      final body = {
        'name': nameController.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'firebaseToken': _firebaseToken,
        'deviceOs': _deviceOs,
        'deviceName': _deviceName,
      };

      final response = await _apiClient.put<Map<String, dynamic>>(
        endpoint: Urls.addUserDetails,
        data: body,
        headers: {'Authorization': 'Bearer ${Store.userToken}'},
      );

      if (response['success'] == true) {
        _storeUserData(response);
        Get.snackbar('Success', response['message'] ?? 'Profile updated successfully!');

        // Navigate away
        _showProfileBottomSheet = false;
        _reset();
        Get.offAllNamed(Routes.bottomNav);
      } else {
        _showErrorSnackbar('Error', response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      _showErrorSnackbar('Error', e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==================== Data Storage ====================

  void _storeUserData(Map<String, dynamic> response) {
    try {
      // Store token
      if (response.containsKey('token')) {
        Store.userToken = response['token'];
        log('Token updated: ${Store.userToken}');
      }

      // Store status
      if (response.containsKey('status')) {
        Store.status = response['status'];
        log('Status updated: ${Store.status}');
      }

      // Store user details
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        Store.id = data['id'] ?? '';
        Store.name = data['name'] ?? '';
        Store.phone = data['phone'] ?? '';
        debugPrint('User data stored successfully');
      }
    } catch (e) {
      debugPrint('Error storing user data: $e');
    }
  }

  // ==================== UI State Management ====================

  void _setLoading(bool value) {
    _isLoading = value;
    update(['auth_screen']);
  }

  void _setLocationLoading(bool value) {
    _isLocationLoading = value;
    update(['auth_screen']);
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(title, message, backgroundColor: Colors.red, colorText: Colors.white);
  }
}
