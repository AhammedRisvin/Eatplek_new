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

  // ── Toggle to true when going live ──
  static const bool _isProduction = false;

  // ── SANDBOX: PhonePe simulator app package
  // ── PRODUCTION: 'com.phonepe.app'
  static const String _sandboxPackageName = 'com.phonepe.simulator';
  static const String _productionPackageName = 'com.phonepe.app';

  // ── Must match <data android:scheme="eatplek" /> in AndroidManifest.xml ──
  static const String _appSchema = 'eatplek';

  // ── SANDBOX merchant ID — replace with live ID for production ──
  static const String _sandboxMerchantId = 'PGTESTPAYUAT86';

  String get _environment => _isProduction ? 'PRODUCTION' : 'SANDBOX';
  String get _merchantId => _sandboxMerchantId; // swap for production

  // ─────────────────────────────────────────────────────────────
  // PUBLIC ENTRY POINT
  // Called from OrderConfirmationController after vendor accepts.
  // ─────────────────────────────────────────────────────────────

  Future<PhonePePaymentResult> startPayment({
    required String orderId,
    required double amount,
    required String mobileNumber,
  }) async {
    // Step 1 — Init SDK
    final initialized = await _initSdk();
    if (!initialized) {
      return const PhonePePaymentResult(
        status: PhonePePaymentStatus.failed,
        errorMessage: 'Failed to initialize payment SDK. Please try again.',
      );
    }

    // Step 2 — Get token from backend
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

    // Step 3 — Launch PhonePe SDK
    final sdkStatus = await _launchSdk(initiateData.token);

    // Step 4 — Confirm with backend regardless of SDK result
    return _confirmPayment(
      orderId: orderId,
      merchantOrderId: initiateData.merchantOrderId,
      sdkStatus: sdkStatus,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 1 — Init SDK
  // ─────────────────────────────────────────────────────────────

  Future<bool> _initSdk() async {
    try {
      debugPrint('🔵 PhonePe SDK init — env: $_environment');
      final result = await PhonePePaymentSdk.init(
        _environment,
        _merchantId,
        '', // flowId — leave empty
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
  // ─────────────────────────────────────────────────────────────

  String? _lastInitiateError;

  Future<_InitiateData?> _initiatePayment({
    required String orderId,
    required double amount,
    required String mobileNumber,
  }) async {
    try {
      debugPrint('📤 Initiating payment — orderId: $orderId, amount: ₹$amount');

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

        // Map backend error messages to user-friendly strings
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
      debugPrint('🔴 Exception initiating payment: $e');
      _lastInitiateError =
          'Could not connect to payment server. Please check your connection.';
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 3 — Launch PhonePe SDK
  // ─────────────────────────────────────────────────────────────

  Future<_SdkStatus> _launchSdk(String token) async {
    try {
      debugPrint('🚀 Launching PhonePe SDK...');

      final response = await PhonePePaymentSdk.startTransaction(
        token, // base64 token from backend
        _appSchema, // 'eatplek'
      );

      log('SDK raw response: $response');

      if (response == null) {
        // null = user closed the PhonePe screen without paying
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
      debugPrint('🔴 SDK exception: $e');
      return _SdkStatus.failed;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 4 — POST /api/payments/confirm
  // Always called after SDK (except user cancel) so backend stays in sync.
  // ─────────────────────────────────────────────────────────────

  Future<PhonePePaymentResult> _confirmPayment({
    required String orderId,
    required String merchantOrderId,
    required _SdkStatus sdkStatus,
  }) async {
    // User cancelled before PhonePe screen — no point hitting confirm
    if (sdkStatus == _SdkStatus.cancelled) {
      return const PhonePePaymentResult(
        status: PhonePePaymentStatus.failed,
        errorMessage: 'Payment was cancelled.',
      );
    }

    try {
      debugPrint('🔍 Confirming payment with backend...');
      debugPrint('   orderId: $orderId | merchantOrderId: $merchantOrderId');

      final response = await _apiClient.post(
        endpoint: Urls.confirmPaymentUrl,
        data: {'orderId': orderId, 'merchantOrderId': merchantOrderId},
        timeout: const Duration(seconds: 30),
      );

      log('Confirm response: $response');

      if (response == null) {
        // Network failure during confirm — payment may have gone through.
        // Show pending instead of failed so user doesn't retry a paid order.
        return PhonePePaymentResult(
          status: PhonePePaymentStatus.pending,
          merchantOrderId: merchantOrderId,
          errorMessage:
              'Could not confirm payment status. Please check your orders.',
        );
      }

      final data = response['data'] as Map<String, dynamic>?;
      final paymentStatus = data?['paymentStatus'] as String? ?? '';

      // ── SUCCESS ──
      if (response['success'] == true && paymentStatus == 'paid') {
        debugPrint('✅ Payment confirmed as PAID');
        return PhonePePaymentResult(
          status: PhonePePaymentStatus.success,
          merchantOrderId: merchantOrderId,
        );
      }

      // ── PENDING (PhonePe returned PENDING to backend) ──
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

      // ── FAILED ──
      debugPrint('❌ Payment FAILED: $msg');
      return PhonePePaymentResult(
        status: PhonePePaymentStatus.failed,
        merchantOrderId: merchantOrderId,
        errorMessage: msg,
      );
    } catch (e) {
      debugPrint('🔴 Exception confirming payment: $e');
      // Network error during confirm — pending is safer than failed
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
