import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:eatplek_app/core/network/api_client.dart';
import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/service/notification_services.dart';

class ProfileCompletionController extends GetxController {
  // ── Text controllers ───────────────────────────────────────────────────────
  late TextEditingController nameController;
  late TextEditingController referralCodeController;

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isLocationLoading = false;
  bool _isLocationPermissionGranted = false;

  // ── Referral server-side validation state ──────────────────────────────────
  /// True when the API explicitly rejected the referral code (400 response).
  /// Resets to false the moment the user edits the field.
  bool _referralRejectedByServer = false;

  // ── Location ───────────────────────────────────────────────────────────────
  double? _latitude;
  double? _longitude;
  String? _placeName;

  // ── Device info ────────────────────────────────────────────────────────────
  String _deviceOs = '';
  String _deviceName = '';

  // ── FCM ────────────────────────────────────────────────────────────────────
  String get _firebaseToken => NotificationService.instance.fcmToken ?? '';

  // ── API ────────────────────────────────────────────────────────────────────
  late FittorConnect _apiClient;

  // ── Getters ────────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  bool get isLocationLoading => _isLocationLoading;
  bool get isLocationPermissionGranted => _isLocationPermissionGranted;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get placeName => _placeName;

  /// True when the API rejected the code — drives the red state + clear button.
  bool get referralRejectedByServer => _referralRejectedByServer;

  /// Regex-only check: empty = valid (field is optional).
  bool get isReferralCodeValid {
    final code = referralCodeController.text.trim();
    if (code.isEmpty) return true;
    return RegExp(r'^EAT[A-Z0-9]{9}$', caseSensitive: false).hasMatch(code);
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    referralCodeController = TextEditingController();

    try {
      _apiClient = Get.find<FittorConnect>();
    } catch (_) {
      _apiClient = FittorConnect();
    }

    _initDeviceInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestLocationPermission();
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    referralCodeController.dispose();
    super.onClose();
  }

  // ── Referral field interaction ─────────────────────────────────────────────

  /// Called from the screen's onChanged — resets the server rejection flag
  /// so the field goes back to neutral/validating state while the user edits.
  void onReferralChanged() {
    if (_referralRejectedByServer) {
      _referralRejectedByServer = false;
      update(['profile_completion']);
    }
  }

  /// Clears the referral field and resets all referral state.
  void clearReferralCode() {
    referralCodeController.clear();
    _referralRejectedByServer = false;
    update(['profile_completion']);
  }

  // ── Device info ────────────────────────────────────────────────────────────

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
      _deviceOs = GetPlatform.isAndroid ? 'Android' : 'iOS';
      _deviceName = 'Unknown Device';
      debugPrint('⚠️ DeviceInfo error: $e');
    }
  }

  // ── Location ───────────────────────────────────────────────────────────────

  Future<void> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDialog();
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _isLocationPermissionGranted = true;
        update(['profile_completion']);
        await _fetchLocation();
      }
    } catch (e) {
      debugPrint('❌ Location permission error: $e');
      _showErrorSnackbar('Error', 'Failed to request location permission');
    }
  }

  Future<void> _fetchLocation() async {
    try {
      _isLocationLoading = true;
      update(['profile_completion']);

      debugPrint('🌍 Fetching location...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;
      debugPrint('✓ Location: $_latitude, $_longitude');

      _reverseGeocode(position.latitude, position.longitude)
          .timeout(
            const Duration(seconds: 10),
            onTimeout:
                () => _setFallbackPlaceName(
                  position.latitude,
                  position.longitude,
                ),
          )
          .catchError((e) {
            debugPrint('⚠️ Geocode error: $e');
            _setFallbackPlaceName(position.latitude, position.longitude);
          });

      update(['profile_completion']);
    } catch (e) {
      debugPrint('❌ Location fetch error: $e');
      _showErrorSnackbar(
        'Error',
        'Failed to fetch location. Please try again.',
      );
    } finally {
      _isLocationLoading = false;
      update(['profile_completion']);
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng).timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw TimeoutException('Geocoding timed out'),
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          if (p.locality?.isNotEmpty == true) p.locality!,
          if (p.administrativeArea?.isNotEmpty == true) p.administrativeArea!,
          if (p.country?.isNotEmpty == true) p.country!,
        ];
        _placeName = parts.isNotEmpty ? parts.join(', ') : 'Current Location';
        debugPrint('✓ Place: $_placeName');
        update(['profile_completion']);
      } else {
        _setFallbackPlaceName(lat, lng);
      }
    } catch (e) {
      _setFallbackPlaceName(lat, lng);
    }
  }

  void _setFallbackPlaceName(double lat, double lng) {
    _placeName =
        'Lat: ${lat.toStringAsFixed(4)}, Long: ${lng.toStringAsFixed(4)}';
    update(['profile_completion']);
  }

  void _showPermissionDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs your location to complete your profile. '
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
                requestLocationPermission();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ── Profile completion ─────────────────────────────────────────────────────

  Future<void> handleProfileCompletion() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      _showErrorSnackbar('Error', 'Please enter your name');
      return;
    }
    if (name.length < 2) {
      _showErrorSnackbar('Error', 'Name must be at least 2 characters');
      return;
    }
    if (_latitude == null || _longitude == null) {
      _showErrorSnackbar('Error', 'Location is required. Please try again.');
      return;
    }
    if (!isReferralCodeValid) {
      _showErrorSnackbar(
        'Invalid Referral Code',
        'Please enter a valid referral code or leave the field empty.',
      );
      return;
    }

    try {
      _isLoading = true;
      update(['profile_completion']);

      final referral = referralCodeController.text.trim();

      final body = <String, dynamic>{
        'name': name,
        'latitude': _latitude,
        'longitude': _longitude,
        'firebaseToken': _firebaseToken,
        'deviceOs': _deviceOs,
        'deviceName': _deviceName,
        if (referral.isNotEmpty) 'referralCode': referral.toUpperCase(),
      };

      final response = await _apiClient.put<Map<String, dynamic>>(
        endpoint: Urls.addUserDetails,
        data: body,
      );

      if (response['success'] == true) {
        await _storeUserData(response);
        Get.snackbar(
          'Success',
          response['message'] ?? 'Profile updated successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(Routes.bottomNav);
      } else {
        final message = (response['message'] ?? '').toString().toLowerCase();

        // ── Server explicitly rejected the referral code ──────────────────
        if (message.contains('invalid referral code') ||
            message.contains('referral')) {
          _referralRejectedByServer = true;
          update(['profile_completion']);
          // Don't show a snackbar — the inline field error is enough
        } else {
          _showErrorSnackbar(
            'Error',
            response['message'] ?? 'Failed to update profile',
          );
        }
      }
    } catch (e) {
      // FittorConnect throws the message string on 4xx — check it here too
      final err = e.toString().toLowerCase();
      if (err.contains('invalid referral code') || err.contains('referral')) {
        _referralRejectedByServer = true;
        update(['profile_completion']);
      } else {
        _showErrorSnackbar('Error', e.toString());
      }
    } finally {
      _isLoading = false;
      update(['profile_completion']);
    }
  }

  // ── Data storage ───────────────────────────────────────────────────────────

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
        debugPrint('✅ Tokens refreshed after profile completion');
      }

      if (response.containsKey('status')) {
        Store.status = response['status'] as String? ?? '';
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
          '💾 Profile stored — name: ${Store.name} | complete: ${Store.profileComplete}',
        );
      }
    } catch (e) {
      debugPrint('❌ _storeUserData error: $e');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
