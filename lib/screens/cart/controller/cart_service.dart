import 'dart:async';

import 'package:eatplek_app/core/network/api_client.dart';
import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Service to manage cart state globally.
/// Both CartController and RestaurantDetailViewController listen to this.
/// Also owns global silent polling so friend cart updates reflect everywhere.
class CartService extends GetxService with WidgetsBindingObserver {
  // ── Cart state ────────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  final RxMap<String, int> cartFoodQuantity = <String, int>{}.obs;
  final RxMap<String, Map<String, int>> cartCustomizationQuantity =
      <String, Map<String, int>>{}.obs;
  final RxMap<String, Map<String, int>> cartAddOnQuantity =
      <String, Map<String, int>>{}.obs;

  final RxInt itemCount = 0.obs;
  final RxDouble totalPrice = 0.0.obs;

  final FittorConnect _apiClient = FittorConnect();

  // ── Polling ───────────────────────────────────────────────────────────────
  Timer? _pollingTimer;
  static const Duration _pollingInterval = Duration(seconds: 3);

  /// True while any local cart mutation (add/remove/update) is in flight.
  /// CartController sets this before API calls so the poll cycle knows
  /// a diff was owner-triggered, not friend-triggered.
  bool localMutationInFlight = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('📱 App resumed — restarting cart polling');
      startGlobalPolling();
    } else if (state == AppLifecycleState.paused) {
      debugPrint('📱 App paused — stopping cart polling');
      stopGlobalPolling();
    }
  }

  // ── Public polling API ────────────────────────────────────────────────────

  /// Call once from main.dart after CartService is registered, only when
  /// Store.userToken is not empty (i.e. user is logged in).
  void startGlobalPolling() {
    if (_pollingTimer?.isActive == true) return;
    if (Store.userToken.isEmpty) {
      debugPrint('⏭️ CartService: skipping poll start — no token');
      return;
    }
    debugPrint(
      '🔄 CartService: global polling started (every ${_pollingInterval.inSeconds}s)',
    );
    _pollingTimer = Timer.periodic(_pollingInterval, (_) => _silentPoll());
  }

  void stopGlobalPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('⏹️ CartService: global polling stopped');
  }

  // ── Silent poll ───────────────────────────────────────────────────────────

  Future<void> _silentPoll() async {
    if (Store.userToken.isEmpty) return;

    try {
      final response = await _apiClient.get(endpoint: Urls.getCartUrl);
      if (response == null || response is! Map<String, dynamic>) return;
      if (response['success'] != true || response['data'] == null) return;

      final data = response['data'] as Map<String, dynamic>;

      final freshItems =
          data['items'] != null
              ? List<Map<String, dynamic>>.from(data['items'])
              : <Map<String, dynamic>>[];
      final freshTotals = data['totals'] as Map<String, dynamic>?;
      final freshItemCount = freshTotals?['itemCount'] ?? 0;
      final freshTotal = (freshTotals?['grandTotal'] ?? 0).toDouble();

      // ── Diff check ────────────────────────────────────────────────────────
      final oldItemCount = itemCount.value;
      final oldTotal = totalPrice.value;
      final oldItemsSnapshot = _buildItemsSnapshot(cartItems);
      final newItemsSnapshot = _buildItemsSnapshot(freshItems);

      final hasChanged =
          oldItemCount != freshItemCount ||
          oldTotal != freshTotal ||
          oldItemsSnapshot != newItemsSnapshot;

      if (!hasChanged) {
        debugPrint('🔄 CartService poll: no change');
        return;
      }

      debugPrint('🔄 CartService poll: change detected — syncing silently');

      updateCartFromApi({
        'items': freshItems,
        'totals': {
          'itemCount': freshItemCount,
          'grandTotal': freshTotal,
          'subTotal': freshTotals?['subTotal'] ?? 0,
          'taxAmount': freshTotals?['taxAmount'] ?? 0,
          'taxPercentage': freshTotals?['taxPercentage'] ?? 0,
          'packingChargeTotal': freshTotals?['packingChargeTotal'] ?? 0,
          'discountTotal': freshTotals?['discountTotal'] ?? 0,
          'couponDiscount': freshTotals?['couponDiscount'] ?? 0,
        },
      });

      // If CartController is alive (user is on CartView), sync its cartModel
      // so items, totals, coupon, and vendor all reflect the fresh data.
      _notifyCartController(response);
    } catch (e) {
      debugPrint('⚠️ CartService silent poll error (ignored): $e');
    }
  }

  /// Notify CartController to re-sync its cartModel from the fresh response.
  /// This keeps CartView's price summary, coupon, and vendor in sync.
  void _notifyCartController(Map<String, dynamic> freshResponse) {
    try {
      // Dynamic lookup avoids a hard import cycle
      final ctrl = Get.find(tag: 'CartController');
      (ctrl as dynamic).syncFromPoll(freshResponse);
    } catch (_) {
      // CartController not registered — user isn't on cart screen, fine
    }
  }

  /// Builds a lightweight string snapshot of items for diffing.
  /// Format: "foodId:qty,foodId:qty,..."  sorted for stable comparison.
  String _buildItemsSnapshot(List<Map<String, dynamic>> items) {
    final parts =
        items.map((i) => '${i['foodId']}:${i['quantity'] ?? 1}').toList()
          ..sort();
    return parts.join(',');
  }

  // ── Cart API helpers ──────────────────────────────────────────────────────

  /// Lightweight fetch — called from HomeController on init to populate
  /// itemCount for the bottom nav badge without needing CartController alive.
  Future<void> fetchCartItemCount() async {
    try {
      debugPrint('🛒 CartService: Fetching cart item count...');
      final response = await _apiClient.get(endpoint: Urls.getCartUrl);

      if (response != null &&
          response is Map<String, dynamic> &&
          response['success'] == true &&
          response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;

        final items =
            data['items'] != null
                ? List<Map<String, dynamic>>.from(data['items'])
                : <Map<String, dynamic>>[];

        final totals = data['totals'] as Map<String, dynamic>?;

        updateCartFromApi({
          'items': items,
          'totals': {
            'itemCount': totals?['itemCount'] ?? 0,
            'grandTotal': totals?['grandTotal'] ?? 0,
            'subTotal': totals?['subTotal'] ?? 0,
            'taxAmount': totals?['taxAmount'] ?? 0,
            'taxPercentage': totals?['taxPercentage'] ?? 0,
            'packingChargeTotal': totals?['packingChargeTotal'] ?? 0,
            'discountTotal': totals?['discountTotal'] ?? 0,
            'couponDiscount': totals?['couponDiscount'] ?? 0,
          },
        });

        debugPrint(
          '✅ CartService: Item count loaded — ${itemCount.value} items',
        );
      } else {
        debugPrint('⚠️ CartService: Empty or failed cart response');
      }
    } catch (e) {
      debugPrint('❌ CartService: fetchCartItemCount error — $e');
    }
  }

  /// Update cart state from API response
  void updateCartFromApi(Map<String, dynamic> cartData) {
    try {
      debugPrint('🔄 CartService: Updating cart from API response');

      if (cartData['items'] != null) {
        cartItems.value = List<Map<String, dynamic>>.from(cartData['items']);
        debugPrint('📊 CartService: ${cartItems.length} items in cart');
      }

      cartFoodQuantity.clear();
      cartCustomizationQuantity.clear();
      cartAddOnQuantity.clear();

      for (var item in cartItems) {
        final foodId = item['foodId'] ?? '';
        if (foodId.isEmpty) continue;

        final hasCustomizations =
            item['customizations'] != null &&
            (item['customizations'] as List).isNotEmpty;

        if (!hasCustomizations) {
          cartFoodQuantity[foodId] = item['quantity'] ?? 1;

          if (item['addOns'] != null && (item['addOns'] as List).isNotEmpty) {
            cartAddOnQuantity[foodId] = {};
            for (var addOn in item['addOns'] as List) {
              cartAddOnQuantity[foodId]![addOn['addOnId']] =
                  addOn['quantity'] ?? 0;
            }
          }
        } else {
          cartCustomizationQuantity[foodId] = {};
          for (var custom in item['customizations'] as List) {
            cartCustomizationQuantity[foodId]![custom['customizationId']] =
                custom['quantity'] ?? 0;
          }

          if (item['addOns'] != null && (item['addOns'] as List).isNotEmpty) {
            cartAddOnQuantity[foodId] = {};
            for (var addOn in item['addOns'] as List) {
              cartAddOnQuantity[foodId]![addOn['addOnId']] =
                  addOn['quantity'] ?? 0;
            }
          }
        }
      }

      if (cartData['totals'] != null) {
        itemCount.value = cartData['totals']['itemCount'] ?? 0;
        totalPrice.value = (cartData['totals']['grandTotal'] ?? 0).toDouble();
      }

      debugPrint('✅ CartService: Cart state synchronized');
    } catch (e) {
      debugPrint('❌ CartService: Error updating cart - $e');
    }
  }

  /// Clear cart locally — call after successful clearCart API response
  void clearCart() {
    cartItems.clear();
    cartFoodQuantity.clear();
    cartCustomizationQuantity.clear();
    cartAddOnQuantity.clear();
    itemCount.value = 0;
    totalPrice.value = 0.0;
    debugPrint('🗑️ CartService: Cart cleared locally');
  }

  // ── Query helpers ─────────────────────────────────────────────────────────

  bool isFoodInCart(String foodId) =>
      cartItems.any((item) => item['foodId'] == foodId);

  int getFoodQuantity(String foodId) => cartFoodQuantity[foodId] ?? 0;

  Map<String, int> getCustomizationQuantities(String foodId) =>
      cartCustomizationQuantity[foodId] ?? {};

  Map<String, int> getAddOnQuantities(String foodId) =>
      cartAddOnQuantity[foodId] ?? {};

  bool foodHasCustomizations(String foodId) =>
      cartCustomizationQuantity.containsKey(foodId) &&
      cartCustomizationQuantity[foodId]!.isNotEmpty;
}
