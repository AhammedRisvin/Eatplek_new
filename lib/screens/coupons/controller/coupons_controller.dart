import 'package:eatplek_app/core/network/api_client.dart';
import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../cart/controller/cart_controller.dart';
import '../model/coupons_model.dart';

class CouponsController extends GetxController {
  final FittorConnect _apiClient = FittorConnect();

  // ─── State ───────────────────────────────────────────────────────────────
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  List<CouponData> coupons = [];

  // Tracks which coupon code is currently mid-apply (for per-card spinner)
  String? applyingCode;

  // Guard: prevents _fetchCoupons from running more than once concurrently
  bool _fetchStarted = false;

  // ─── Lifecycle ───────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _fetchCoupons();
  }

  // ─── Fetch coupons ───────────────────────────────────────────────────────
  Future<void> _fetchCoupons() async {
    // Prevent concurrent or repeated calls
    if (_fetchStarted) return;
    _fetchStarted = true;

    try {
      isLoading = true;
      hasError = false;
      errorMessage = '';
      update();

      final cartController = Get.find<CartController>();
      final vendorId = cartController.cartModel?.data?.vendor?.id ?? '';
      final endpoint =
          vendorId.isNotEmpty
              ? '${Urls.getCouponsUrl}?vendor=$vendorId'
              : Urls.getCouponsUrl;

      final response = await _apiClient.get(endpoint: endpoint);

      if (response != null && response is Map<String, dynamic>) {
        final model = GetCouponsModel.fromJson(response);
        if (model.success == true) {
          coupons = model.data ?? [];
          hasError = false;
        } else {
          hasError = true;
          errorMessage = model.message ?? 'Failed to load coupons';
        }
      } else {
        hasError = true;
        errorMessage = 'Invalid response format';
      }
    } catch (e) {
      hasError = true;
      errorMessage = 'Error loading coupons: $e';
      debugPrint('❌ Error fetching coupons: $e');
    } finally {
      isLoading = false;
      _fetchStarted = false; // reset so retry works
      update();
    }
  }

  Future<void> retryfetch() {
    _fetchStarted = false; // allow retry explicitly
    return _fetchCoupons();
  }

  // ─── Apply coupon: validate → apply → refresh cart → pop to cart ─────────
  Future<void> applyCode(String code, {Function(String error)? onError}) async {
    final trimmedCode = code.trim().toUpperCase();
    if (trimmedCode.isEmpty) {
      onError?.call('Please enter a promo code');
      return;
    }

    try {
      applyingCode = trimmedCode;
      update();

      final cartController = Get.find<CartController>();
      final vendorId = cartController.cartModel?.data?.vendor?.id ?? '';

      // ── Step 1: Validate ──────────────────────────────────────────────────
      debugPrint('🔍 Validating coupon: $trimmedCode');
      final validateResponse = await _apiClient.post(
        endpoint:
            vendorId.isNotEmpty
                ? '${Urls.validateCouponUrl}?vendor=$vendorId'
                : Urls.validateCouponUrl,
        data: {'code': trimmedCode},
      );

      if (validateResponse == null ||
          validateResponse is! Map<String, dynamic>) {
        throw Exception('Invalid validation response');
      }
      if (validateResponse['success'] != true) {
        onError?.call(
          validateResponse['message'] ?? 'Coupon validation failed',
        );
        return;
      }
      debugPrint('✅ Coupon validated: $trimmedCode');

      // ── Step 2: Apply ─────────────────────────────────────────────────────
      debugPrint('🎟️ Applying coupon: $trimmedCode');
      final applyResponse = await _apiClient.post(
        endpoint:
            vendorId.isNotEmpty
                ? '${Urls.applyCouponUrl}?vendor=$vendorId'
                : Urls.applyCouponUrl,
        data: {'code': trimmedCode},
      );

      if (applyResponse == null || applyResponse is! Map<String, dynamic>) {
        throw Exception('Invalid apply response');
      }
      if (applyResponse['success'] != true) {
        onError?.call(applyResponse['message'] ?? 'Failed to apply coupon');
        return;
      }
      debugPrint('✅ Coupon applied: $trimmedCode');

      // ── Step 3: Refresh cart ──────────────────────────────────────────────
      await cartController.fetchCartData();
      cartController.setAppliedPromoCode(trimmedCode);

      // ── Step 4: Navigate back ────────────────────────────────────────────
      // Get.back() internally calls closeCurrentSnackbar() which crashes if
      // a snackbar is queued but not yet initialized. Use Navigator directly
      // to bypass GetX snackbar queue entirely.
      Get.key.currentState?.pop();
    } catch (e) {
      debugPrint('❌ Error applying coupon: $e');
      // FittorConnect throws the error message string directly from _handleError
      // so we can show it as-is to the user
      final message = e.toString().replaceAll('Exception: ', '');
      onError?.call(message);
    } finally {
      applyingCode = null;
      update();
    }
  }

  // ─── Remove coupon: DELETE call → refresh cart ────────────────────────────
  Future<void> removeCoupon({Function(String error)? onError}) async {
    try {
      final cartController = Get.find<CartController>();
      final vendorId = cartController.cartModel?.data?.vendor?.id ?? '';

      debugPrint('🗑️ Removing coupon...');
      final response = await _apiClient.delete(
        endpoint:
            vendorId.isNotEmpty
                ? '${Urls.removeCouponUrl}?vendor=$vendorId'
                : Urls.removeCouponUrl,
      );

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true) {
          await cartController.fetchCartData();
          cartController.removePromoCode();
          debugPrint('✅ Coupon removed');
        } else {
          onError?.call(response['message'] ?? 'Failed to remove coupon');
        }
      } else {
        onError?.call('Failed to remove coupon');
      }
    } catch (e) {
      debugPrint('❌ Error removing coupon: $e');
      final message = e.toString().replaceAll('Exception: ', '');
      onError?.call(message);
    }
  }
}
