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
  // CONFIG
  // ─────────────────────────────────────────────────────────────

  // Set false once backend turns off PAYMENT_DEMO_MODE
  static const bool _isDemoMode = true;

  // Toggle when going to production
  static const bool _isProduction = false;

  // Must match <data android:scheme="eatplek"/> in AndroidManifest.xml
  // iOS only — Android doesn't need appSchema
  static const String _appSchema = 'eatplek';

  // Replace with real merchant ID once backend has real PhonePe credentials
  static const String _merchantId = 'PGTESTPAYUAT86';

  // flowId — pass unique user ID or UUID for analytics/debugging
  // Can be empty string if not needed
  static const String _flowId = '';

  String get _environment => _isProduction ? 'PRODUCTION' : 'SANDBOX';

  // ─────────────────────────────────────────────────────────────
  // PUBLIC ENTRY POINT
  // ─────────────────────────────────────────────────────────────

  Future<PhonePePaymentResult> startPayment({
    required String orderId,
    required double amount,
    required String mobileNumber,
  }) async {
    // Step 1 — Call backend initiate → get token + merchantOrderId
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

    // Step 2 — Demo mode: skip SDK, confirm directly with backend
    if (_isDemoMode) {
      debugPrint('🎭 DEMO MODE — skipping PhonePe SDK, confirming directly');
      return _confirmPayment(
        orderId: orderId,
        merchantOrderId: initiateData.merchantOrderId,
        sdkStatus: _SdkStatus.success,
      );
    }

    // Step 3 — Real mode: init SDK
    // Official signature: init(environment, merchantId, flowId, enableLogs)
    final initialized = await _initSdk();
    if (!initialized) {
      return const PhonePePaymentResult(
        status: PhonePePaymentStatus.failed,
        errorMessage: 'Failed to initialize payment SDK. Please try again.',
      );
    }

    // Step 4 — Build request JSON and launch SDK
    // Official: startTransaction(request, appSchema)
    // request = JSON string of { orderId, merchantId, token, paymentMode }
    final sdkStatus = await _launchSdk(
      orderId: initiateData.merchantOrderId,
      token: initiateData.token,
    );

    // Step 5 — Confirm with backend
    return _confirmPayment(
      orderId: orderId,
      merchantOrderId: initiateData.merchantOrderId,
      sdkStatus: sdkStatus,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // INIT SDK
  // Official: init(environment, merchantId, flowId, enableLogs)
  // ─────────────────────────────────────────────────────────────

  Future<bool> _initSdk() async {
    try {
      debugPrint(
        '🔵 PhonePe SDK init — env: $_environment | merchantId: $_merchantId',
      );

      final result = await PhonePePaymentSdk.init(
        _environment, // 'SANDBOX' or 'PRODUCTION'
        _merchantId, // merchant ID from PhonePe dashboard
        _flowId, // flowId for analytics — can be empty string
        true, // enableLogs — set false in production
      );

      debugPrint('🟢 SDK initialized: $result');
      return result == true;
    } catch (e) {
      debugPrint('🔴 SDK init error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // POST /api/payments/initiate
  // ─────────────────────────────────────────────────────────────

  String? _lastInitiateError;

  Future<_InitiateData?> _initiatePayment({
    required String orderId,
    required double amount,
    required String mobileNumber,
  }) async {
    try {
      debugPrint(
        '📤 Initiating — orderId: $orderId | ₹$amount | phone: $mobileNumber',
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

      if (token == null || token.isEmpty) {
        _lastInitiateError =
            'Invalid payment token received. Please try again.';
        return null;
      }

      debugPrint('✅ Initiate success — merchantOrderId: $merchantOrderId');
      return _InitiateData(
        token: token,
        merchantOrderId: merchantOrderId ?? orderId,
      );
    } catch (e) {
      debugPrint('🔴 Exception initiating: $e');
      _lastInitiateError =
          'Could not connect to payment server. Please check your connection.';
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LAUNCH SDK
  // Official: startTransaction(request, appSchema)
  // request = JSON STRING of { orderId, merchantId, token, paymentMode }
  // This is NOT the raw base64 token — it is a JSON object encoded as string
  // ─────────────────────────────────────────────────────────────

  Future<_SdkStatus> _launchSdk({
    required String orderId,
    required String token,
  }) async {
    try {
      // Build the request payload as per PhonePe docs
      final Map<String, dynamic> payload = {
        'orderId': orderId,
        'merchantId': _merchantId,
        'token': token,
        'paymentMode': {'type': 'PAY_PAGE'},
      };

      // Must be passed as JSON string, not a Map
      final String request = jsonEncode(payload);
      debugPrint('🚀 Launching PhonePe SDK...');
      debugPrint('   request: $request');

      final response = await PhonePePaymentSdk.startTransaction(
        request, // JSON string
        _appSchema, // iOS only, ignored on Android — 'eatplek'
      );

      log('SDK raw response: $response');

      if (response == null) {
        // null = user closed PhonePe without completing payment
        debugPrint('⚠️ SDK returned null — user likely cancelled');
        return _SdkStatus.cancelled;
      }

      final status = response['status']?.toString().toUpperCase() ?? '';
      final error = response['error']?.toString() ?? '';
      debugPrint('   status: $status | error: $error');

      switch (status) {
        case 'SUCCESS':
          return _SdkStatus.success;
        case 'FAILURE':
        case 'FAILED':
          return _SdkStatus.failed;
        // SDK docs say 'INTERRUPTED' is also possible — treat same as pending
        case 'INTERRUPTED':
        case 'PENDING':
          return _SdkStatus.pending;
        default:
          debugPrint('⚠️ Unknown SDK status: $status');
          return _SdkStatus.unknown;
      }
    } catch (e) {
      debugPrint('🔴 SDK launch exception: $e');
      return _SdkStatus.failed;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // POST /api/payments/confirm
  // Always called after SDK returns (except on user cancel)
  // ─────────────────────────────────────────────────────────────

  Future<PhonePePaymentResult> _confirmPayment({
    required String orderId,
    required String merchantOrderId,
    required _SdkStatus sdkStatus,
  }) async {
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
        debugPrint('✅ Confirmed — PAID');
        return PhonePePaymentResult(
          status: PhonePePaymentStatus.success,
          merchantOrderId: merchantOrderId,
        );
      }

      // PENDING
      final msg =
          response['message'] as String? ?? 'Payment could not be confirmed';
      if (msg.toUpperCase().contains('PENDING') || paymentStatus == 'pending') {
        debugPrint('⏳ PENDING');
        return PhonePePaymentResult(
          status: PhonePePaymentStatus.pending,
          merchantOrderId: merchantOrderId,
          errorMessage:
              'Your payment is being processed. We\'ll update your order shortly.',
        );
      }

      // FAILED
      debugPrint('❌ FAILED: $msg');
      return PhonePePaymentResult(
        status: PhonePePaymentStatus.failed,
        merchantOrderId: merchantOrderId,
        errorMessage: msg,
      );
    } catch (e) {
      debugPrint('🔴 Exception confirming: $e');
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
  final String merchantOrderId;
  const _InitiateData({required this.token, required this.merchantOrderId});
}

enum _SdkStatus { success, failed, pending, cancelled, unknown }
