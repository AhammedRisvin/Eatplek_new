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
  final RxDouble subtotalPrice = 0.0.obs;

  final Map<String, Set<String>> _locallyRemovedAddOns = {};
  final Map<String, Set<String>> _locallyRemovedCustomizations = {};

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
        return;
      }

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
        cartItems.value =
            List<Map<String, dynamic>>.from(
              cartData['items'],
            ).map(_sanitizeCartItem).toList();
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
        final totals = cartData['totals'] as Map<String, dynamic>;
        itemCount.value = totals['itemCount'] ?? 0;
        totalPrice.value = (totals['grandTotal'] ?? 0).toDouble();
        subtotalPrice.value = _resolveSubtotal(totals);
      }
    } catch (e) {
      debugPrint('❌ CartService: Error updating cart - $e');
    }
  }

  double _resolveSubtotal(Map<String, dynamic> totals) {
    double itemsTotal = 0;
    for (final item in cartItems) {
      itemsTotal += _cartItemFoodTotal(item);
    }

    if (itemsTotal > 0) return itemsTotal;
    final subtotal = totals['subTotal'] ?? totals['subtotal'];
    if (subtotal is num) {
      final addOnTotal = totals['addOnTotal'];
      final customizationTotal = totals['customizationTotal'];
      return subtotal.toDouble() +
          (addOnTotal is num ? addOnTotal.toDouble() : 0) +
          (customizationTotal is num ? customizationTotal.toDouble() : 0);
    }
    return (totals['grandTotal'] ?? 0).toDouble();
  }

  double _cartItemFoodTotal(Map<String, dynamic> item) {
    final itemTotal = _asDouble(item['itemTotal']);
    final quantity = _asDouble(item['quantity']) ?? 1;
    final basePrice =
        _asDouble(item['effectivePrice']) ??
        _asDouble(item['basePrice']) ??
        _asDouble(item['discountPrice']) ??
        0;
    final baseTotal = basePrice * quantity;
    final addOnsTotal = _nestedOptionsTotal(item['addOns']);
    final customizationsTotal = _nestedOptionsTotal(item['customizations']);
    final hasCustomizations =
        item['customizations'] is List &&
        (item['customizations'] as List).isNotEmpty;

    if (hasCustomizations) {
      if (customizationsTotal > 0 || addOnsTotal > 0) {
        return customizationsTotal + addOnsTotal;
      }
      return itemTotal ?? baseTotal;
    }

    if (basePrice > 0) return baseTotal + addOnsTotal;

    return itemTotal ?? addOnsTotal;
  }

  double _nestedOptionsTotal(dynamic options) {
    if (options is! List) return 0;

    double total = 0;
    for (final option in options) {
      if (option is Map) {
        total +=
            (_asDouble(option['price']) ?? 0) *
            (_asDouble(option['quantity']) ?? 0);
      }
    }
    return total;
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  void clearCart() {
    cartItems.clear();
    cartFoodQuantity.clear();
    cartCustomizationQuantity.clear();
    cartAddOnQuantity.clear();
    itemCount.value = 0;
    totalPrice.value = 0.0;
    subtotalPrice.value = 0.0;
    _locallyRemovedAddOns.clear();
    _locallyRemovedCustomizations.clear();
    debugPrint('🗑️ CartService: Cart cleared locally');
  }

  void recordSubmittedOptionState({
    required String foodId,
    dynamic addOns,
    dynamic customizations,
  }) {
    _recordOptionState(
      foodId: foodId,
      options: addOns,
      removedOptions: _locallyRemovedAddOns,
      idKey: 'addOnId',
    );
    _recordOptionState(
      foodId: foodId,
      options: customizations,
      removedOptions: _locallyRemovedCustomizations,
      idKey: 'customizationId',
    );
  }

  bool isOptionLocallyRemoved({
    required String foodId,
    required String optionId,
    required bool isCustomization,
  }) {
    if (foodId.isEmpty || optionId.isEmpty) return false;
    final removedOptions =
        isCustomization ? _locallyRemovedCustomizations : _locallyRemovedAddOns;
    return removedOptions[foodId]?.contains(optionId) ?? false;
  }

  void _recordOptionState({
    required String foodId,
    required dynamic options,
    required Map<String, Set<String>> removedOptions,
    required String idKey,
  }) {
    if (options is! List || foodId.isEmpty) return;

    for (final option in options) {
      if (option is! Map) continue;
      final id = _optionId(option, idKey);
      if (id.isEmpty) continue;

      final quantity = _asDouble(option['quantity']) ?? 0;
      if (quantity <= 0) {
        removedOptions.putIfAbsent(foodId, () => <String>{}).add(id);
      } else {
        removedOptions[foodId]?.remove(id);
        if (removedOptions[foodId]?.isEmpty ?? false) {
          removedOptions.remove(foodId);
        }
      }
    }
  }

  Map<String, dynamic> _sanitizeCartItem(Map<String, dynamic> item) {
    final foodId = item['foodId']?.toString() ?? '';
    if (foodId.isEmpty) return item;

    return {
      ...item,
      'addOns': _sanitizeOptions(
        foodId: foodId,
        options: item['addOns'],
        removedOptions: _locallyRemovedAddOns,
        idKey: 'addOnId',
      ),
      'customizations': _sanitizeOptions(
        foodId: foodId,
        options: item['customizations'],
        removedOptions: _locallyRemovedCustomizations,
        idKey: 'customizationId',
      ),
    };
  }

  List<Map<String, dynamic>> _sanitizeOptions({
    required String foodId,
    required dynamic options,
    required Map<String, Set<String>> removedOptions,
    required String idKey,
  }) {
    if (options is! List) return [];

    final removedIds = removedOptions[foodId] ?? <String>{};
    return options
        .whereType<Map>()
        .where((option) {
          final id = _optionId(option, idKey);
          final quantity = _asDouble(option['quantity']) ?? 0;
          return quantity > 0 && !removedIds.contains(id);
        })
        .map((option) => Map<String, dynamic>.from(option))
        .toList();
  }

  String _optionId(Map option, String idKey) {
    final nested =
        idKey == 'addOnId' ? option['addOn'] : option['customization'];
    return (option[idKey] ??
            option['id'] ??
            option['_id'] ??
            (nested is Map
                ? nested[idKey] ?? nested['id'] ?? nested['_id']
                : null) ??
            '')
        .toString();
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
