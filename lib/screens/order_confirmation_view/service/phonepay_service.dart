import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

// ─────────────────────────────────────────────────────────────
// RESULT MODEL
// ─────────────────────────────────────────────────────────────

enum PhonePePaymentStatus { success, failed, pending }

class PhonePePaymentResult {
  final PhonePePaymentStatus status;
  final String? merchantOrderId;
  final String? errorMessage;

  const PhonePePaymentResult({
    required this.status,
    this.merchantOrderId,
    this.errorMessage,
  });

  bool get isSuccess => status == PhonePePaymentStatus.success;
  bool get isFailed => status == PhonePePaymentStatus.failed;
  bool get isPending => status == PhonePePaymentStatus.pending;
}

// ─────────────────────────────────────────────────────────────
// SERVICE
// ─────────────────────────────────────────────────────────────

class PhonePeService {
  static final PhonePeService _instance = PhonePeService._internal();
  factory PhonePeService() => _instance;
  PhonePeService._internal();

  final FittorConnect _apiClient = FittorConnect();

  // ─────────────────────────────────────────────────────────────
  // CONFIG — update these when going live
  // ─────────────────────────────────────────────────────────────

  // Set true while backend has PAYMENT_DEMO_MODE=true
  // Set false once backend has real PhonePe sandbox/production credentials
  static const bool _isDemoMode = true;

  // Toggle when going live
  static const bool _isProduction = false;

  // Must match <data android:scheme="eatplek"/> in AndroidManifest.xml
  static const String _appSchema = 'eatplek';

  // SANDBOX simulator package — switch to 'com.phonepe.app' for production
  static const String _phonePePackage = 'com.phonepe.simulator';

  // Replace with real merchant ID from PhonePe dashboard
  // SANDBOX test ID: 'PGTESTPAYUAT86'
  static const String _merchantId = 'PGTESTPAYUAT86';

  // appId is optional — leave empty unless PhonePe team provides one
  static const String _appId = '';

  String get _environment => _isProduction ? 'PRODUCTION' : 'SANDBOX';

  // ─────────────────────────────────────────────────────────────
  // PUBLIC ENTRY POINT
  // ─────────────────────────────────────────────────────────────

  Future<PhonePePaymentResult> startPayment({
    required String orderId,
    required double amount,
    required String mobileNumber,
  }) async {
    // Step 1 — Call backend to initiate (gets token + checksum)
    final initiateData = await _initiatePayment(
      orderId: orderId,
      amount: amount,
      mobileNumber: mobileNumber,
    );
    if (initiateData == null) {
      return PhonePePaymentResult(
        status: PhonePePaymentStatus.failed,
        errorMessage: _lastInitiateError,
      );
    }

    // Step 2 — Demo mode: skip SDK entirely, call confirm directly
    if (_isDemoMode) {
      debugPrint('🎭 DEMO MODE — skipping PhonePe SDK, confirming directly');
      return _confirmPayment(
        orderId: orderId,
        merchantOrderId: initiateData.merchantOrderId,
        sdkStatus: _SdkStatus.success,
      );
    }

    // Step 3 — Real mode: init SDK
    // Official param order: environment, appId, merchantId, enableLogs
    final initialized = await _initSdk();
    if (!initialized) {
      return const PhonePePaymentResult(
        status: PhonePePaymentStatus.failed,
        errorMessage: 'Failed to initialize payment SDK. Please try again.',
      );
    }

    // Step 4 — Launch SDK with body + checksum
    final sdkStatus = await _launchSdk(
      body: initiateData.body,
      checksum: initiateData.checksum,
    );

    // Step 5 — Confirm with backend
    return _confirmPayment(
      orderId: orderId,
      merchantOrderId: initiateData.merchantOrderId,
      sdkStatus: sdkStatus,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 1 — Init SDK
  // Official signature: init(environment, appId, merchantId, enableLogs)
  // NOTE: appId comes BEFORE merchantId — common mistake to swap these
  // ─────────────────────────────────────────────────────────────

  Future<bool> _initSdk() async {
    try {
      debugPrint(
        '🔵 PhonePe SDK init — env: $_environment, merchantId: $_merchantId',
      );

      final result = await PhonePePaymentSdk.init(
        _environment, // 'SANDBOX' or 'PRODUCTION'
        _appId, // appId — empty string if not provided by PhonePe
        _merchantId, // your merchant ID
        true, // enableLogs — set false in production
      );

      debugPrint('🟢 PhonePe SDK initialized: $result');
      return result == true;
    } catch (e) {
      debugPrint('🔴 PhonePe SDK init error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 2 — POST /api/payments/initiate
  // Backend returns: token (base64 body), checksum, merchantOrderId
  // ─────────────────────────────────────────────────────────────

  String? _lastInitiateError;

  Future<_InitiateData?> _initiatePayment({
    required String orderId,
    required double amount,
    required String mobileNumber,
  }) async {
    try {
      debugPrint(
        '📤 Initiating — orderId: $orderId | amount: ₹$amount | phone: $mobileNumber',
      );

      final response = await _apiClient.post(
        endpoint: Urls.initiatePaymentUrl,
        data: {
          'orderId': orderId,
          'amount': amount,
          'mobileNumber': mobileNumber,
        },
        timeout: const Duration(seconds: 30),
      );

      log('Initiate response: $response');

      if (response == null) {
        _lastInitiateError = 'No response from server. Please try again.';
        return null;
      }

      if (response['success'] != true) {
        final msg =
            response['message'] as String? ?? 'Payment initiation failed';
        if (msg.contains('accepted')) {
          _lastInitiateError = 'This order has not been confirmed yet.';
        } else if (msg.contains('already completed')) {
          _lastInitiateError =
              'Payment has already been completed for this order.';
        } else if (msg.contains('not configured') ||
            msg.contains('PAYMENT_DEMO_MODE')) {
          _lastInitiateError =
              'Payment service is not available. Please contact support.';
        } else {
          _lastInitiateError = msg;
        }
        debugPrint('🔴 Initiate failed: $_lastInitiateError');
        return null;
      }

      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        _lastInitiateError = 'Unexpected response from server.';
        return null;
      }

      final token = data['token'] as String?;
      final merchantOrderId = data['merchantOrderId'] as String?;
      // Checksum is only present in real mode — backend computes it
      // In demo mode this will be null which is fine since we skip the SDK
      final checksum = data['checksum'] as String?;

      if (token == null || token.isEmpty) {
        _lastInitiateError =
            'Invalid payment token received. Please try again.';
        return null;
      }

      debugPrint('✅ Initiate success');
      debugPrint('   token: $token');
      debugPrint('   merchantOrderId: $merchantOrderId');
      debugPrint('   checksum present: ${checksum != null}');

      // In real mode, the SDK expects the body as a JSON string of the payload.
      // The token from backend is already the base64-encoded payload.
      // We wrap it into the request format the SDK expects.
      final body =
          _isDemoMode
              ? token // demo — token value doesn't matter, SDK is skipped
              : jsonEncode({
                'orderId': merchantOrderId ?? orderId,
                'merchantId': _merchantId,
                'token': token,
                'paymentMode': {'type': 'PAY_PAGE'},
              });

      return _InitiateData(
        token: token,
        body: body,
        checksum: checksum ?? '',
        merchantOrderId: merchantOrderId ?? orderId,
      );
    } catch (e) {
      debugPrint('🔴 Exception initiating payment: $e');
      _lastInitiateError =
          'Could not connect to payment server. Please check your connection.';
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 3 — Launch PhonePe SDK (real mode only)
  // Official signature: startTransaction(body, appSchema, checksum, packageName)
  // body     = JSON string of payment payload
  // appSchema = your deep-link scheme ('eatplek')
  // checksum  = SHA256 computed by backend
  // packageName = PhonePe app package ('com.phonepe.simulator' for sandbox)
  // ─────────────────────────────────────────────────────────────

  Future<_SdkStatus> _launchSdk({
    required String body,
    required String checksum,
  }) async {
    try {
      debugPrint('🚀 Launching PhonePe SDK...');
      debugPrint('   package: $_phonePePackage');
      debugPrint('   appSchema: $_appSchema');

      final response = await PhonePePaymentSdk.startTransaction(
        body, // JSON string payload
        _appSchema, // 'eatplek' — deep-link callback scheme
      );

      log('SDK raw response: $response');

      if (response == null) {
        debugPrint('⚠️ SDK returned null — user likely cancelled');
        return _SdkStatus.cancelled;
      }

      final status = response['status']?.toString().toUpperCase() ?? '';
      final error = response['error']?.toString() ?? '';
      debugPrint('   SDK status: $status | error: $error');

      switch (status) {
        case 'SUCCESS':
          return _SdkStatus.success;
        case 'FAILURE':
        case 'FAILED':
          return _SdkStatus.failed;
        case 'PENDING':
          return _SdkStatus.pending;
        default:
          return _SdkStatus.unknown;
      }
    } catch (e) {
      debugPrint('🔴 SDK launch exception: $e');
      return _SdkStatus.failed;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 4 — POST /api/payments/confirm
  // ─────────────────────────────────────────────────────────────

  Future<PhonePePaymentResult> _confirmPayment({
    required String orderId,
    required String merchantOrderId,
    required _SdkStatus sdkStatus,
  }) async {
    // User cancelled before PhonePe screen — skip confirm
    if (sdkStatus == _SdkStatus.cancelled) {
      return const PhonePePaymentResult(
        status: PhonePePaymentStatus.failed,
        errorMessage: 'Payment was cancelled.',
      );
    }

    try {
      debugPrint(
        '🔍 Confirming — orderId: $orderId | merchantOrderId: $merchantOrderId',
      );

      final response = await _apiClient.post(
        endpoint: Urls.confirmPaymentUrl,
        data: {'orderId': orderId, 'merchantOrderId': merchantOrderId},
        timeout: const Duration(seconds: 30),
      );

      log('Confirm response: $response');

      if (response == null) {
        // Network failure — show pending so user doesn't retry a paid order
        return PhonePePaymentResult(
          status: PhonePePaymentStatus.pending,
          merchantOrderId: merchantOrderId,
          errorMessage:
              'Could not confirm payment status. Please check your orders.',
        );
      }

      final data = response['data'] as Map<String, dynamic>?;
      final paymentStatus = data?['paymentStatus'] as String? ?? '';

      // SUCCESS
      if (response['success'] == true && paymentStatus == 'paid') {
        debugPrint('✅ Payment confirmed — PAID');
        return PhonePePaymentResult(
          status: PhonePePaymentStatus.success,
          merchantOrderId: merchantOrderId,
        );
      }

      // PENDING
      final msg =
          response['message'] as String? ?? 'Payment could not be confirmed';
      if (msg.toUpperCase().contains('PENDING') || paymentStatus == 'pending') {
        debugPrint('⏳ Payment PENDING');
        return PhonePePaymentResult(
          status: PhonePePaymentStatus.pending,
          merchantOrderId: merchantOrderId,
          errorMessage:
              'Your payment is being processed. We\'ll update your order shortly.',
        );
      }

      // FAILED
      debugPrint('❌ Payment FAILED: $msg');
      return PhonePePaymentResult(
        status: PhonePePaymentStatus.failed,
        merchantOrderId: merchantOrderId,
        errorMessage: msg,
      );
    } catch (e) {
      debugPrint('🔴 Exception confirming payment: $e');
      return PhonePePaymentResult(
        status: PhonePePaymentStatus.pending,
        merchantOrderId: merchantOrderId,
        errorMessage: 'Payment status unknown. Please check your orders.',
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────
// INTERNAL TYPES
// ─────────────────────────────────────────────────────────────

class _InitiateData {
  final String token;
  final String body; // JSON string for SDK startTransaction
  final String checksum; // SHA256 from backend for SDK startTransaction
  final String merchantOrderId;

  const _InitiateData({
    required this.token,
    required this.body,
    required this.checksum,
    required this.merchantOrderId,
  });
}

enum _SdkStatus { success, failed, pending, cancelled, unknown }
