import 'package:eatplek_app/core/network/api_client.dart';
import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/util/service_type.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/cart_api_model.dart';
import '../model/extra_model.dart';
import 'cart_controller.dart';

class CartExtrasController extends GetxController {
  final FittorConnect _apiClient = FittorConnect();

  // ── State ────────────────────────────────────────────────────────────────────
  final Rx<ExtraData?> extrasData = Rx<ExtraData?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  /// IDs of items currently being updated (for per-row loading spinner)
  final RxSet<String> updatingItems = <String>{}.obs;

  /// Quantities user has selected in dialog for new items
  final RxMap<String, int> selectedAddOnQty = <String, int>{}.obs;
  final RxMap<String, int> selectedCustomizationQty = <String, int>{}.obs;

  /// The cart item this dialog belongs to
  CartItem? _cartItem;
  CartItem? get cartItem => _cartItem;

  // ── Open Dialog ──────────────────────────────────────────────────────────────

  Future<void> openExtrasDialog(CartItem cartItem) async {
    _cartItem = cartItem;
    selectedAddOnQty.clear();
    selectedCustomizationQty.clear();
    extrasData.value = null;
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    // ✅ Use cartItem.id (cart item ID) for the fetch URL
    await _fetchExtras(cartItem.id ?? '');
  }

  Future<void> _fetchExtras(String cartItemId) async {
    try {
      final response = await _apiClient.get(
        // ✅ URL uses cartItem.id, e.g. /food/699e9460ecbc0067f7e62fe1/add-ons
        endpoint: '${Urls.fetchAddOnsUrl}$cartItemId/add-ons',
      );

      if (response != null && response is Map<String, dynamic>) {
        final model = ExtraModel.fromJson(response);

        if (model.success == true && model.data != null) {
          final data = model.data!;

          // Filter out items already in cart
          final cartAddOnIds =
              (_cartItem?.addOns ?? []).map((a) => a.addOnId).toSet();
          final cartCustomizationIds =
              (_cartItem?.customizations ?? [])
                  .map((c) => c.customizationId)
                  .toSet();

          final filteredAddOns =
              (data.addOns ?? [])
                  .where((a) => !cartAddOnIds.contains(a.id))
                  .toList();

          final filteredCustomizations =
              (data.customizations ?? [])
                  .where((c) => !cartCustomizationIds.contains(c.id))
                  .toList();

          extrasData.value = ExtraData(
            foodId: data.foodId,
            foodName: data.foodName,
            addOns: filteredAddOns,
            customizations: filteredCustomizations,
          );

          // If empty, dialog shows empty state — controller does NOT call
          // Get.back() here, that crashes when a snackbar is on the stack.
        } else {
          hasError.value = true;
          errorMessage.value = model.message ?? 'Failed to load extras';
        }
      } else {
        hasError.value = true;
        errorMessage.value = 'Invalid response';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('❌ CartExtrasController._fetchExtras: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Quantity Controls ────────────────────────────────────────────────────────

  Future<void> incrementAddOn(ExtraItem item) async {
    final newQty = (selectedAddOnQty[item.id!] ?? 0) + 1;
    selectedAddOnQty[item.id!] = newQty;
    await _updateCart(addOnItem: item, newQty: newQty);
  }

  Future<void> decrementAddOn(ExtraItem item) async {
    final current = selectedAddOnQty[item.id!] ?? 0;
    if (current <= 0) return;
    final newQty = current - 1;
    selectedAddOnQty[item.id!] = newQty;
    await _updateCart(addOnItem: item, newQty: newQty);
  }

  Future<void> incrementCustomization(ExtraItem item) async {
    final newQty = (selectedCustomizationQty[item.id!] ?? 0) + 1;
    selectedCustomizationQty[item.id!] = newQty;
    await _updateCart(customizationItem: item, newQty: newQty);
  }

  Future<void> decrementCustomization(ExtraItem item) async {
    final current = selectedCustomizationQty[item.id!] ?? 0;
    if (current <= 0) return;
    final newQty = current - 1;
    selectedCustomizationQty[item.id!] = newQty;
    await _updateCart(customizationItem: item, newQty: newQty);
  }

  // ── Core Cart Update ─────────────────────────────────────────────────────────

  Future<void> _updateCart({
    ExtraItem? addOnItem,
    ExtraItem? customizationItem,
    required int newQty,
  }) async {
    if (_cartItem == null) return;

    final isAddOn = addOnItem != null;
    final itemId = (addOnItem?.id ?? customizationItem?.id)!;
    updatingItems.add(itemId);

    try {
      final cartController = Get.find<CartController>();
      final serviceType = _getCleanServiceType(Store.deliveryPreference);
      final foodId = _cartItem!.foodId ?? '';

      final mergedAddOns = _buildMergedAddOns(
        _cartItem!.addOns ?? [],
        addOnItem,
        newQty,
        isAddOn,
      );

      final mergedCustomizations = _buildMergedCustomizations(
        _cartItem!.customizations ?? [],
        customizationItem,
        newQty,
        !isAddOn,
      );

      final Map<String, dynamic> body = {
        'foodId': foodId,
        'quantity': _cartItem!.quantity ?? 1,
        'serviceType': serviceType,
      };

      if (mergedAddOns.isNotEmpty) body['addOns'] = mergedAddOns;
      if (mergedCustomizations.isNotEmpty) {
        body['customizations'] = mergedCustomizations;
      }

      // ✅ Only send updateAddOns: true when an add-on is being updated
      if (isAddOn) body['updateAddOns'] = true;

      final response = await _apiClient.post(
        endpoint: Urls.addOrUpdateCartUrl,
        data: body,
      );

      if (response != null &&
          response is Map<String, dynamic> &&
          response['success'] == true &&
          response['data'] != null) {
        cartController.cartService.updateCartFromApi({
          'items': response['data']['items'] ?? [],
          'totals': response['data']['totals'] ?? {},
        });

        // Refresh local _cartItem reference
        final updatedItem = cartController.cartItems.firstWhereOrNull(
          (i) => i.foodId == foodId,
        );
        if (updatedItem != null) _cartItem = updatedItem;
      } else {
        // Revert optimistic update on failure
        if (isAddOn) {
          selectedAddOnQty[itemId] = newQty > 0 ? newQty - 1 : 0;
        } else {
          selectedCustomizationQty[itemId] = newQty > 0 ? newQty - 1 : 0;
        }
        debugPrint(
          '❌ CartExtrasController: Failed to update — \${response?["message"]}',
        );
      }
    } catch (e) {
      debugPrint('❌ CartExtrasController._updateCart: $e');
    } finally {
      updatingItems.remove(itemId);
    }
  }

  // ── Merge Helpers ────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _buildMergedAddOns(
    List<AddOn> existing,
    ExtraItem? newItem,
    int newQty,
    bool isAddOn,
  ) {
    final result =
        existing
            .map(
              (a) => <String, dynamic>{
                'addOnId': a.addOnId,
                'quantity': a.quantity ?? 0,
              },
            )
            .toList();

    if (isAddOn && newItem != null) {
      final idx = result.indexWhere((r) => r['addOnId'] == newItem.id);
      if (idx >= 0) {
        result[idx]['quantity'] = newQty;
      } else if (newQty > 0) {
        result.add({'addOnId': newItem.id, 'quantity': newQty});
      }
    }
    return result;
  }

  List<Map<String, dynamic>> _buildMergedCustomizations(
    List<AddOn> existing,
    ExtraItem? newItem,
    int newQty,
    bool isCustomization,
  ) {
    final result =
        existing
            .map(
              (c) => <String, dynamic>{
                'customizationId': c.customizationId,
                'quantity': c.quantity ?? 0,
              },
            )
            .toList();

    if (isCustomization && newItem != null) {
      final idx = result.indexWhere((r) => r['customizationId'] == newItem.id);
      if (idx >= 0) {
        result[idx]['quantity'] = newQty;
      } else if (newQty > 0) {
        result.add({'customizationId': newItem.id, 'quantity': newQty});
      }
    }
    return result;
  }

  String _getCleanServiceType(String pref) {
    return ServiceType.normalize(pref);
  }
}
