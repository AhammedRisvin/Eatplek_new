import 'dart:async';

import 'package:eatplek_app/core/network/api_client.dart';
import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Service to manage cart state globally.
/// Both CartController and RestaurantDetailViewController listen to this.
///
/// POLLING STRATEGY:
/// - Timer fires every 3 seconds always (cheap — no network call)
/// - _silentPoll() only hits the API when [isCartViewActive] is true
/// - CartView sets isCartViewActive = true on enter, false on leave
/// - This means zero unnecessary API calls on Home / Orders / Profile
class CartService extends GetxService with WidgetsBindingObserver {
  // ── Cart state ─────────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  final RxMap<String, int> cartFoodQuantity = <String, int>{}.obs;
  final RxMap<String, Map<String, int>> cartCustomizationQuantity =
      <String, Map<String, int>>{}.obs;
  final RxMap<String, Map<String, int>> cartAddOnQuantity =
      <String, Map<String, int>>{}.obs;

  final RxInt itemCount = 0.obs;
  final RxDouble totalPrice = 0.0.obs;

  final FittorConnect _apiClient = FittorConnect();

  // ── Polling ────────────────────────────────────────────────────────────────
  Timer? _pollingTimer;
  static const Duration _pollingInterval = Duration(seconds: 3);

  /// Set to true only while CartView is the active screen.
  /// _silentPoll() skips the network call when this is false.
  bool isCartViewActive = false;

  /// True while any local cart mutation (add/remove/update) is in flight.
  bool localMutationInFlight = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

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
      // Only restart if CartView was active when app was backgrounded
      if (isCartViewActive) {
        debugPrint('📱 App resumed — CartView was active, restarting poll');
        startGlobalPolling();
      }
    } else if (state == AppLifecycleState.paused) {
      debugPrint('📱 App paused — stopping cart polling');
      stopGlobalPolling();
    }
  }

  // ── Cart view presence API ─────────────────────────────────────────────────

  /// Call from CartView.initState() or didChangeDependencies()
  void onCartViewEntered() {
    isCartViewActive = true;
    debugPrint('🛒 CartService: CartView entered — starting poll timer');
    // Cancel any existing timer first to avoid duplicates
    _pollingTimer?.cancel();
    // Fetch immediately on enter
    _silentPoll();
    // Start fresh timer — only runs while cart is open
    _pollingTimer = Timer.periodic(_pollingInterval, (_) => _silentPoll());
  }

  /// Call from CartView.dispose()
  void onCartViewExited() {
    isCartViewActive = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('🛒 CartService: CartView exited — poll timer stopped');
  }

  // ── Public polling API ─────────────────────────────────────────────────────

  /// No longer used for global polling.
  /// Kept for compatibility with didChangeAppLifecycleState.
  /// Actual polling is managed by onCartViewEntered/onCartViewExited.
  void startGlobalPolling() {
    if (isCartViewActive) {
      _pollingTimer?.cancel();
      _pollingTimer = Timer.periodic(_pollingInterval, (_) => _silentPoll());
      debugPrint('🔄 CartService: poll timer restarted (app resume)');
    }
  }

  void stopGlobalPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('⏹️ CartService: polling stopped');
  }

  // ── Silent poll ────────────────────────────────────────────────────────────

  Future<void> _silentPoll() async {
    // ✅ KEY GUARD — only hit the network if CartView is open
    if (!isCartViewActive) return;
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

      // ── Diff check — only update state if something actually changed ──────
      final hasChanged =
          itemCount.value != freshItemCount ||
          totalPrice.value != freshTotal ||
          _buildItemsSnapshot(cartItems) != _buildItemsSnapshot(freshItems);

      if (!hasChanged) {
        debugPrint('🔄 CartService poll: no change');
        return;
      }

      debugPrint('🔄 CartService poll: change detected — syncing');

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

      _notifyCartController(response);
    } catch (e) {
      debugPrint('⚠️ CartService silent poll error (ignored): $e');
    }
  }

  void _notifyCartController(Map<String, dynamic> freshResponse) {
    try {
      final ctrl = Get.find(tag: 'CartController');
      (ctrl as dynamic).syncFromPoll(freshResponse);
    } catch (_) {
      // CartController not registered — fine
    }
  }

  String _buildItemsSnapshot(List<Map<String, dynamic>> items) {
    final parts =
        items.map((i) => '${i['foodId']}:${i['quantity'] ?? 1}').toList()
          ..sort();
    return parts.join(',');
  }

  // ── Cart API helpers ───────────────────────────────────────────────────────

  /// One-shot fetch — called from HomeController on init for the badge count
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
      }
    } catch (e) {
      debugPrint('❌ CartService: fetchCartItemCount error — $e');
    }
  }

  void updateCartFromApi(Map<String, dynamic> cartData) {
    try {
      if (cartData['items'] != null) {
        cartItems.value = List<Map<String, dynamic>>.from(cartData['items']);
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
    } catch (e) {
      debugPrint('❌ CartService: Error updating cart - $e');
    }
  }

  void clearCart() {
    cartItems.clear();
    cartFoodQuantity.clear();
    cartCustomizationQuantity.clear();
    cartAddOnQuantity.clear();
    itemCount.value = 0;
    totalPrice.value = 0.0;
    debugPrint('🗑️ CartService: Cart cleared locally');
  }

  // ── Query helpers ──────────────────────────────────────────────────────────

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
