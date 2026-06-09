import 'dart:async';

import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/util/service_type.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../cart/controller/cart_service.dart';
import '../model/restaurent_details_model.dart';

class RestaurantDetailViewController extends GetxController {
  final bool skipInitialFetch;

  RestaurantDetailViewController({this.skipInitialFetch = false});

  final FittorConnect _apiClient = FittorConnect();

  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  RestuarantDetailsModel? restaurantDetailsModel;
  List<RestuarantDetailsData> restaurantData = [];
  List<String> banners = [];

  int selectedCategoryIndex = 0;
  List<String> categories = [];

  final RxMap<String, int> cartFoodQuantity = <String, int>{}.obs;
  final RxMap<String, Map<String, int>> cartCustomizationQuantity =
      <String, Map<String, int>>{}.obs;
  final RxMap<String, Map<String, int>> cartAddOnQuantity =
      <String, Map<String, int>>{}.obs;

  Map<String, dynamic>? lastCartItemResponse;
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  Food? selectedFoodItem;
  Map<String, int> bsCustomizationQuantity = {};
  Map<String, int> bsAddOnQuantity = {};
  Map<String, int> bsItemQuantity = {};

  bool isEditMode = false;
  String? editingFoodId;
  String? restaurantId;
  bool isCartSubmitting = false;

  Timer? _quantityDebounceTimer;
  Timer? _autoRemoveCheckTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _autoRemoveCheckDuration = Duration(milliseconds: 800);

  DateTime _lastLocalApiUpdate = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    if (!skipInitialFetch) {
      _extractRestaurantIdAndFetch();
    }
    _setupExternalCartSyncListener();
  }

  @override
  void onClose() {
    _quantityDebounceTimer?.cancel();
    _autoRemoveCheckTimer?.cancel();
    super.onClose();
  }

  void _setupExternalCartSyncListener() {
    final cartService = Get.find<CartService>();

    ever(cartService.cartItems, (_) {
      final timeSinceLastUpdate = DateTime.now().difference(
        _lastLocalApiUpdate,
      );

      if (timeSinceLastUpdate.inSeconds > 2) {
        _syncWithExternalCartService();
      }
    });
  }

  void _syncWithExternalCartService() {
    try {
      final cartService = Get.find<CartService>();

      cartItems.value = List<Map<String, dynamic>>.from(cartService.cartItems);

      cartFoodQuantity.clear();
      cartCustomizationQuantity.clear();
      cartAddOnQuantity.clear();

      for (var item in cartService.cartItems) {
        final foodId = item['foodId'] ?? '';
        if (foodId.isEmpty) continue;

        final hasCustomizations =
            item['customizations'] != null &&
            (item['customizations'] as List).isNotEmpty;

        if (!hasCustomizations) {
          cartFoodQuantity[foodId] = item['quantity'] ?? 0;

          if (item['addOns'] != null && (item['addOns'] as List).isNotEmpty) {
            cartAddOnQuantity[foodId] = {};
            for (var addOn in item['addOns'] as List) {
              final addOnId = _addOnIdFromMap(addOn);
              if (addOnId.isNotEmpty) {
                cartAddOnQuantity[foodId]![addOnId] = addOn['quantity'] ?? 0;
              }
            }
          }
        } else {
          cartCustomizationQuantity[foodId] = {};
          for (var custom in item['customizations'] as List) {
            final customizationId = _customizationIdFromMap(custom);
            if (customizationId.isNotEmpty) {
              cartCustomizationQuantity[foodId]![customizationId] =
                  custom['quantity'] ?? 0;
            }
          }

          if (item['addOns'] != null && (item['addOns'] as List).isNotEmpty) {
            cartAddOnQuantity[foodId] = {};
            for (var addOn in item['addOns'] as List) {
              final addOnId = _addOnIdFromMap(addOn);
              if (addOnId.isNotEmpty) {
                cartAddOnQuantity[foodId]![addOnId] = addOn['quantity'] ?? 0;
              }
            }
          }
        }
      }

      lastCartItemResponse = {
        'items': cartService.cartItems.toList(),
        'totals': {
          'itemCount': cartService.itemCount.value,
          'grandTotal': cartService.totalPrice.value,
        },
      };

      update(['food_grid', 'bottom_cart_bar']);
    } catch (e) {
      debugPrint('Error syncing with CartService: $e');
    }
  }

  void _extractRestaurantIdAndFetch() {
    final args = Get.arguments;
    if (args != null && args.hotelId != null) {
      restaurantId = args.hotelId;
      getRestaurantDetailsFn(restaurantId: restaurantId!);
    } else {
      hasError = true;
      errorMessage = 'Restaurant ID not found';
      update(['main_content']);
    }
  }

  Future<void> getRestaurantDetailsFn({required String restaurantId}) async {
    try {
      isLoading = true;
      hasError = false;
      errorMessage = '';

      update(['main_content']);

      String serviceType = _getCleanServiceType(Store.deliveryPreference);

      final response = await _apiClient.get(
        endpoint:
            "${Urls.getRestaurantDetailsUrl}$restaurantId/foods?service=${Uri.encodeQueryComponent(serviceType)}",
      );

      if (response != null && response is Map<String, dynamic>) {
        restaurantDetailsModel = RestuarantDetailsModel.fromJson(response);

        if (restaurantDetailsModel?.status == true &&
            restaurantDetailsModel?.data != null) {
          restaurantData = restaurantDetailsModel!.data!;
          banners = restaurantDetailsModel?.banners ?? [];

          _initializeCartFromRestaurantData();

          _extractCategories();

          if (categories.isNotEmpty) {
            selectedCategoryIndex = 0;
            filterFoodByCategory(categories[0]);
          }

          hasError = false;
          isLoading = false;
        } else {
          hasError = true;
          errorMessage =
              restaurantDetailsModel?.message ??
              'Failed to load restaurant details';
          isLoading = false;
        }
      } else {
        hasError = true;
        errorMessage = 'Invalid response format';
        isLoading = false;
      }

      update(['main_content', 'bottom_cart_bar']);
    } catch (e) {
      hasError = true;
      errorMessage = 'Error loading restaurant details: $e';
      isLoading = false;
      update(['main_content']);
    }
  }

  void _initializeCartFromRestaurantData() {
    try {
      cartItems.clear();
      cartFoodQuantity.clear();
      cartCustomizationQuantity.clear();
      cartAddOnQuantity.clear();

      int totalItems = 0;
      double totalPrice = 0;

      for (var categoryData in restaurantData) {
        if (categoryData.foods != null) {
          for (var food in categoryData.foods!) {
            final foodId = food.foodId;
            if (foodId == null) continue;

            if (food.cartCount != null && food.cartCount! > 0) {
              final basePrice = _effectiveFoodPrice(food);
              final hasCustomizations =
                  food.customizations != null &&
                  food.customizations!.isNotEmpty;

              Map<String, dynamic> cartItem = {
                'foodId': foodId,
                'foodName': food.foodName,
                'foodImage': food.foodImage,
                'quantity':
                    hasCustomizations ? 1 : (food.cartCount?.toInt() ?? 1),
                'basePrice': basePrice,
                'effectivePrice': basePrice,
                'customizations': [],
                'addOns': [],
                'itemTotal':
                    basePrice *
                    (hasCustomizations ? 1 : (food.cartCount?.toInt() ?? 1)),
              };

              if (hasCustomizations) {
                List<Map<String, dynamic>> customizationsList = [];

                for (var customization in food.customizations!) {
                  if (customization.cartCount != null &&
                      customization.cartCount! > 0) {
                    customizationsList.add({
                      'customizationId': customization.customizationId,
                      'name': customization.name,
                      'price': customization.price,
                      'quantity': customization.cartCount,
                    });

                    cartCustomizationQuantity[foodId] ??= {};
                    cartCustomizationQuantity[foodId]![customization
                            .customizationId!] =
                        customization.cartCount!.toInt();
                  }
                }

                cartItem['customizations'] = customizationsList;

                int totalCustomizationQty = 0;
                for (var custom in customizationsList) {
                  totalCustomizationQty += (custom['quantity'] as int);
                }
                cartItem['itemTotal'] = basePrice * totalCustomizationQty;
              } else {
                cartFoodQuantity[foodId] = food.cartCount!.toInt();
              }

              if (food.addOns != null) {
                List<Map<String, dynamic>> addOnsList = [];

                for (var addOn in food.addOns!) {
                  if (addOn.cartCount != null && addOn.cartCount! > 0) {
                    addOnsList.add({
                      'addOnId': addOn.addOnId,
                      'name': addOn.name,
                      'price': addOn.price,
                      'quantity': addOn.cartCount,
                    });

                    cartAddOnQuantity[foodId] ??= {};
                    cartAddOnQuantity[foodId]![addOn.addOnId!] =
                        addOn.cartCount!.toInt();

                    totalPrice +=
                        (addOn.price ?? 0).toDouble() * addOn.cartCount!;
                  }
                }

                cartItem['addOns'] = addOnsList;
              }

              cartItems.add(cartItem);

              if (hasCustomizations) {
                int customQtyTotal = (cartItem['customizations'] as List).fold(
                  0,
                  (sum, c) => sum + (c['quantity'] as int),
                );
                totalItems += customQtyTotal;
              } else {
                totalItems += (food.cartCount!.toInt());
              }

              totalPrice += cartItem['itemTotal'];
            }
          }
        }
      }

      if (cartItems.isNotEmpty) {
        lastCartItemResponse = {
          'items': cartItems.toList(),
          'totals': {'itemCount': totalItems, 'grandTotal': totalPrice},
        };

        final cartService = Get.find<CartService>();
        cartService.updateCartFromApi({
          'items': cartItems.toList(),
          'totals': {'itemCount': totalItems, 'grandTotal': totalPrice},
        });
      }
    } catch (e) {
      debugPrint('Error initializing cart from restaurant data: $e');
    }
  }

  String _getCleanServiceType(String servicePreference) {
    return ServiceType.normalize(servicePreference);
  }

  void _extractCategories() {
    Set<String> uniqueCategories = {};
    for (var data in restaurantData) {
      if (data.category != null && data.category!.isNotEmpty) {
        uniqueCategories.add(data.category!);
      }
    }
    categories = uniqueCategories.toList();
  }

  void onCategoryTapped(int index) {
    if (selectedCategoryIndex != index) {
      selectedCategoryIndex = index;
      update(['category_tabs', 'food_grid']);
      filterFoodByCategory(categories[index]);
    }
  }

  List<Food> getFilteredFoodItems() {
    if (selectedCategoryIndex < 0 ||
        selectedCategoryIndex >= restaurantData.length) {
      return [];
    }

    final selectedCategory = restaurantData[selectedCategoryIndex];
    return selectedCategory.foods ?? [];
  }

  void filterFoodByCategory(String category) {
    update(['food_grid']);
  }

  bool _isScenario1(Food foodItem) {
    final hasCustomizations =
        foodItem.customizations != null && foodItem.customizations!.isNotEmpty;
    final hasAddOns = foodItem.addOns != null && foodItem.addOns!.isNotEmpty;
    return !hasCustomizations && !hasAddOns;
  }

  bool _isScenario2(Food foodItem) {
    final hasCustomizations =
        foodItem.customizations != null && foodItem.customizations!.isNotEmpty;
    final hasAddOns = foodItem.addOns != null && foodItem.addOns!.isNotEmpty;
    return !hasCustomizations && hasAddOns;
  }

  bool _isScenario3And4(Food foodItem) {
    final hasCustomizations =
        foodItem.customizations != null && foodItem.customizations!.isNotEmpty;
    return hasCustomizations;
  }

  bool _isItemInCart(String foodId) {
    return cartItems.any((item) => item['foodId'] == foodId);
  }

  Map<String, dynamic>? _getCartItemFromResponse(String foodId) {
    try {
      return cartItems.firstWhere((item) => item['foodId'] == foodId);
    } catch (e) {
      return null;
    }
  }

  void selectFoodItem(Food foodItem, {bool isEdit = false}) {
    if (foodItem.foodId == null) return;

    selectedFoodItem = foodItem;
    editingFoodId = foodItem.foodId!;
    isEditMode = isEdit;

    bsCustomizationQuantity.clear();
    bsAddOnQuantity.clear();
    bsItemQuantity.clear();

    if (isEdit) {
      _initializeBottomSheetStateForEdit(foodItem);
    } else {
      _initializeBottomSheetStateForAdd(foodItem);
    }

    update(['bottom_sheet_content', 'bottom_sheet_header']);
  }

  void _initializeBottomSheetStateForAdd(Food foodItem) {
    final foodId = foodItem.foodId!;
    final hasCustomizations = _isScenario3And4(foodItem);
    final hasAddOns = foodItem.addOns != null && foodItem.addOns!.isNotEmpty;

    if (!hasCustomizations && !hasAddOns) {
      bsItemQuantity[foodId] = 1;
    } else if (!hasCustomizations && hasAddOns) {
      bsItemQuantity[foodId] = 1;
    } else {
      bsItemQuantity[foodId] = 1;
    }
  }

  void _initializeBottomSheetStateForEdit(Food foodItem) {
    final foodId = foodItem.foodId!;
    final hasCustomizations = _isScenario3And4(foodItem);

    bsCustomizationQuantity.clear();
    bsAddOnQuantity.clear();
    bsItemQuantity.clear();

    final cartService = Get.find<CartService>();

    Map<String, dynamic>? currentCartItem;
    for (var item in cartService.cartItems) {
      if (item['foodId'] == foodId) {
        currentCartItem = item;
        break;
      }
    }

    if (currentCartItem == null) {
      return;
    }

    if (!hasCustomizations) {
      final quantity = currentCartItem['quantity'] ?? 1;
      bsItemQuantity[foodId] = quantity;

      if (currentCartItem['addOns'] != null) {
        final addOns = currentCartItem['addOns'] as List;
        for (var addOn in addOns) {
          final addOnId = _addOnIdFromMap(addOn);
          final addOnQty = addOn['quantity'] ?? 0;
          if (addOnId.isNotEmpty) {
            bsAddOnQuantity[addOnId] = addOnQty;
          }
        }
      }
    } else {
      if (currentCartItem['customizations'] != null) {
        final customizations = currentCartItem['customizations'] as List;
        for (var customization in customizations) {
          final customId = _customizationIdFromMap(customization);
          final customQty = customization['quantity'] ?? 0;
          if (customId.isNotEmpty) {
            bsCustomizationQuantity[customId] = customQty;
          }
        }
      }

      if (currentCartItem['addOns'] != null) {
        final addOns = currentCartItem['addOns'] as List;
        for (var addOn in addOns) {
          final addOnId = _addOnIdFromMap(addOn);
          final addOnQty = addOn['quantity'] ?? 0;
          if (addOnId.isNotEmpty) {
            bsAddOnQuantity[addOnId] = addOnQty;
          }
        }
      }
    }
  }

  void resetBottomSheetState() {
    selectedFoodItem = null;
    bsCustomizationQuantity.clear();
    bsAddOnQuantity.clear();
    bsItemQuantity.clear();
    isEditMode = false;
    editingFoodId = null;
  }

  int getBottomSheetItemQuantity() {
    if (selectedFoodItem?.foodId == null) return 1;
    return bsItemQuantity[selectedFoodItem!.foodId!] ?? 1;
  }

  void increaseBottomSheetItemQuantity() {
    if (selectedFoodItem?.foodId == null) return;

    final foodId = selectedFoodItem!.foodId!;
    final currentQty = getBottomSheetItemQuantity();
    bsItemQuantity[foodId] = currentQty + 1;

    update(['total_price']);
  }

  void decreaseBottomSheetItemQuantity() {
    if (selectedFoodItem?.foodId == null) return;

    final foodId = selectedFoodItem!.foodId!;
    final currentQty = getBottomSheetItemQuantity();

    if (isEditMode) {
      if (currentQty > 0) {
        bsItemQuantity[foodId] = currentQty - 1;
        update(['total_price']);

        _scheduleAutoRemoveCheckForScenario1And2();
      }
    } else {
      if (currentQty > 1) {
        bsItemQuantity[foodId] = currentQty - 1;
        update(['total_price']);
      }
    }
  }

  void toggleCustomization(String customizationId) {
    if (selectedFoodItem?.foodId == null) return;

    final currentQty = bsCustomizationQuantity[customizationId] ?? 0;
    bsCustomizationQuantity[customizationId] = currentQty + 1;

    update(['customization_widget', 'bottom_sheet_content', 'total_price']);
  }

  void decreaseCustomization(String customizationId) {
    if (selectedFoodItem?.foodId == null) return;

    final currentQty = bsCustomizationQuantity[customizationId] ?? 0;

    if (currentQty > 0) {
      bsCustomizationQuantity[customizationId] = currentQty - 1;

      update([
        'customization_widget',
        'addons_list',
        'bottom_sheet_content',
        'total_price',
      ]);

      _scheduleAutoRemoveCheckForScenario3And4();
    }
  }

  int getCustomizationCount(String customizationId) {
    return bsCustomizationQuantity[customizationId] ?? 0;
  }

  int getTotalCustomizationQuantity() {
    int total = 0;
    bsCustomizationQuantity.forEach((_, qty) {
      if (qty > 0) {
        total += qty;
      }
    });
    return total;
  }

  void toggleAddOn(String addOnId) {
    if (selectedFoodItem?.foodId == null) return;

    final currentQty = bsAddOnQuantity[addOnId] ?? 0;
    bsAddOnQuantity[addOnId] = currentQty + 1;

    update(['addons_list', 'bottom_sheet_content', 'total_price']);
  }

  void decreaseAddOn(String addOnId) {
    if (selectedFoodItem?.foodId == null) return;

    final currentQty = bsAddOnQuantity[addOnId] ?? 0;

    if (currentQty > 0) {
      bsAddOnQuantity[addOnId] = currentQty - 1;

      update(['addons_list', 'bottom_sheet_content', 'total_price']);

      _scheduleAutoRemoveCheckForScenario1And2();
    }
  }

  int getAddOnCount(String addOnId) {
    return bsAddOnQuantity[addOnId] ?? 0;
  }

  // ============================================================================
  // AUTO REMOVAL LOGIC
  // ============================================================================

  void _scheduleAutoRemoveCheckForScenario1And2() {
    debugPrint('🔴 Scheduling auto-remove check for Scenario 1 & 2');

    _autoRemoveCheckTimer?.cancel();
    _autoRemoveCheckTimer = Timer(_autoRemoveCheckDuration, () {
      if (selectedFoodItem?.foodId == null) return;

      final foodId = selectedFoodItem!.foodId!;
      final currentQty = getBottomSheetItemQuantity();

      debugPrint(
        '🔴 Auto-remove check - foodId: $foodId, qty: $currentQty, isEditMode: $isEditMode',
      );

      if (isEditMode && currentQty == 0) {
        debugPrint('🔴 Scenario 1 & 2: Auto-removing item - quantity is 0');
        _removeItemFromCartDirectly(foodId);
      }
    });
  }

  void _scheduleAutoRemoveCheckForScenario3And4() {
    debugPrint('🟣 Scheduling auto-remove check for Scenario 3 & 4');

    _autoRemoveCheckTimer?.cancel();
    _autoRemoveCheckTimer = Timer(_autoRemoveCheckDuration, () {
      if (selectedFoodItem?.foodId == null) return;

      final foodId = selectedFoodItem!.foodId!;
      final totalCustomQty = getTotalCustomizationQuantity();

      debugPrint(
        '🟣 Auto-remove check - foodId: $foodId, totalCustomQty: $totalCustomQty, isEditMode: $isEditMode',
      );

      if (isEditMode && totalCustomQty == 0) {
        debugPrint(
          '🟣 Scenario 3 & 4: All customizations are zero - Auto-removing item and clearing add-ons',
        );
        _validateCustomizationsAndCleanAddOns(foodId);
      }
    });
  }

  void _validateCustomizationsAndCleanAddOns(String foodId) {
    final totalCustomQty = getTotalCustomizationQuantity();

    if (totalCustomQty == 0) {
      debugPrint('🟣 Clearing add-ons for foodId: $foodId');
      bsAddOnQuantity.clear();
      update(['addons_list', 'bottom_sheet_content', 'total_price']);
    }
  }

  Future<void> _removeItemFromCartDirectly(String foodId) async {
    try {
      debugPrint('🟠 Removing item directly from cart: $foodId');

      final requestBody = {
        'foodId': foodId,
        'quantity': 0,
        'serviceType': _getCleanServiceType(Store.deliveryPreference),
      };

      _lastLocalApiUpdate = DateTime.now();

      final response = await _apiClient.post(
        endpoint: Urls.addOrUpdateCartUrl,
        data: requestBody,
      );

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          final cartData = response['data'];

          debugPrint('🟠 Item successfully removed - updating cart state');

          _updateCartFromApiResponse(cartData);

          final cartService = Get.find<CartService>();
          cartService.updateCartFromApi(cartData);

          resetBottomSheetState();

          Future.delayed(Duration(milliseconds: 200), () {
            if (Get.context != null) {
              Navigator.pop(Get.context!);
            }
          });

          debugPrint('🟠 Bottom sheet closed after item removal');
        } else {
          debugPrint('🟠 Failed to remove item: ${response['message']}');
          Get.snackbar('Error', response['message'] ?? 'Failed to remove item');
        }
      }
    } catch (e) {
      debugPrint('🟠 Error removing item directly: $e');
      Get.snackbar('Error', 'Failed to remove item from cart');
    }
  }

  // ============================================================================
  // SCENARIO 1 QUANTITY METHODS — with optimistic CartService update
  // ============================================================================

  void increaseScenario1Quantity(String foodId) {
    final currentQty = cartFoodQuantity[foodId] ?? 0;
    cartFoodQuantity[foodId] = currentQty + 1;

    // ✅ Optimistic update — BottomCartBar appears immediately, no delay
    _updateCartServiceOptimistically(foodId, cartFoodQuantity[foodId]!);

    _debouncedUpdateQuantity(foodId, cartFoodQuantity[foodId]!);
  }

  void decreaseScenario1Quantity(String foodId) {
    final currentQty = cartFoodQuantity[foodId] ?? 0;

    if (currentQty > 1) {
      cartFoodQuantity[foodId] = currentQty - 1;

      // ✅ Optimistic update — BottomCartBar updates immediately
      _updateCartServiceOptimistically(foodId, cartFoodQuantity[foodId]!);

      _debouncedUpdateQuantity(foodId, cartFoodQuantity[foodId]!);
    } else if (currentQty == 1) {
      cartFoodQuantity.remove(foodId);

      // ✅ Optimistic update — BottomCartBar hides immediately when last item removed
      _updateCartServiceOptimistically(foodId, 0);

      _callScenario1UpdateQuantityApi(foodId, 0);
    }
  }

  /// ✅ Optimistically updates CartService so BottomCartBar reacts instantly.
  ///
  /// This runs BEFORE the debounce/API call so the UI is never waiting on the
  /// network for a simple +/- tap. If the API later fails, [_revertScenario1Change]
  /// corrects the state.
  void _updateCartServiceOptimistically(String foodId, int newQty) {
    try {
      final cartService = Get.find<CartService>();

      // Work on a mutable copy of current cart items
      final List<Map<String, dynamic>> updatedItems = List.from(cartItems);

      if (newQty == 0) {
        // Remove the item entirely
        updatedItems.removeWhere((item) => item['foodId'] == foodId);
      } else {
        final existingIndex = updatedItems.indexWhere(
          (item) => item['foodId'] == foodId,
        );

        // Resolve base price from existing cart entry or restaurant data
        final food = _getFoodById(foodId);
        final basePrice = _effectiveFoodPrice(food);

        if (existingIndex != -1) {
          // Update quantity + itemTotal on existing entry
          updatedItems[existingIndex] = {
            ...updatedItems[existingIndex],
            'quantity': newQty,
            'itemTotal': basePrice * newQty,
          };
        } else {
          // First tap — build a brand-new cart entry optimistically
          updatedItems.add({
            'foodId': foodId,
            'foodName': food?.foodName ?? '',
            'foodImage': food?.foodImage ?? '',
            'quantity': newQty,
            'basePrice': basePrice,
            'effectivePrice': basePrice,
            'customizations': [],
            'addOns': [],
            'itemTotal': basePrice * newQty,
          });
        }
      }

      // Recalculate totals from the optimistic list
      int totalCount = 0;
      double totalPrice = 0.0;
      for (final item in updatedItems) {
        totalCount += (item['quantity'] as int? ?? 0);
        totalPrice += (item['itemTotal'] as double? ?? 0.0);
      }

      debugPrint(
        '⚡ Optimistic cart update — foodId: $foodId, qty: $newQty, '
        'totalItems: $totalCount, totalPrice: $totalPrice',
      );

      // Push to CartService — this triggers BottomCartBar via Obx immediately
      cartService.updateCartFromApi({
        'items': updatedItems,
        'totals': {'itemCount': totalCount, 'grandTotal': totalPrice},
      });

      // Keep local cartItems in sync so subsequent optimistic updates are correct
      cartItems.value = updatedItems;
    } catch (e) {
      debugPrint('❌ Error in optimistic cart update: $e');
    }
  }

  void _debouncedUpdateQuantity(String foodId, int quantity) {
    _quantityDebounceTimer?.cancel();
    _quantityDebounceTimer = Timer(_debounceDuration, () {
      _callScenario1UpdateQuantityApi(foodId, quantity);
    });
  }

  Future<void> _callScenario1UpdateQuantityApi(
    String foodId,
    int quantity,
  ) async {
    try {
      _lastLocalApiUpdate = DateTime.now();

      final requestBody = {
        'foodId': foodId,
        'quantity': quantity,
        'serviceType': _getCleanServiceType(Store.deliveryPreference),
      };

      final response = await _apiClient.post(
        endpoint: Urls.addOrUpdateCartUrl,
        data: requestBody,
      );

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          final cartData = response['data'];

          _mergeScenario1Update(
            cartData,
            updatingFoodId: foodId,
            quantity: quantity,
          );

          final cartService = Get.find<CartService>();
          cartService.updateCartFromApi(cartData);
        } else {
          // API failed — revert the optimistic change
          _revertScenario1Change(foodId);
          Get.snackbar(
            'Error',
            response['message'] ?? 'Failed to update quantity',
          );
        }
      }
    } catch (e) {
      // Network/parse error — revert the optimistic change
      _revertScenario1Change(foodId);
      Get.snackbar('Error', 'Failed to update quantity');
    }
  }

  void _mergeScenario1Update(
    Map<String, dynamic> cartData, {
    required String updatingFoodId,
    required int quantity,
  }) {
    try {
      if (cartData['items'] != null) {
        cartItems.value = List<Map<String, dynamic>>.from(cartData['items']);
      }

      final itemInResponse = (cartData['items'] as List?)?.firstWhere(
        (item) => item['foodId'] == updatingFoodId,
        orElse: () => null,
      );

      if (itemInResponse != null) {
        final responseQuantity = itemInResponse['quantity'] ?? 0;
        cartFoodQuantity[updatingFoodId] = responseQuantity;

        if (itemInResponse['addOns'] != null &&
            (itemInResponse['addOns'] as List).isNotEmpty) {
          cartAddOnQuantity[updatingFoodId] = {};
          for (var addOn in itemInResponse['addOns'] as List) {
            final addOnId = _addOnIdFromMap(addOn);
            if (addOnId.isNotEmpty) {
              cartAddOnQuantity[updatingFoodId]![addOnId] =
                  addOn['quantity'] ?? 0;
            }
          }
        } else {
          cartAddOnQuantity.remove(updatingFoodId);
        }
      } else {
        cartFoodQuantity.remove(updatingFoodId);
        cartAddOnQuantity.remove(updatingFoodId);
      }

      if (cartData['totals'] != null) {
        lastCartItemResponse = cartData;
      }
    } catch (e) {
      debugPrint('Error merging Scenario 1 update: $e');
    }
  }

  void _revertScenario1Change(String foodId) {
    // Revert local maps back from the last known good cartItems list
    cartFoodQuantity.clear();
    cartAddOnQuantity.clear();

    for (var item in cartItems) {
      final id = item['foodId'] ?? '';
      if (id.isNotEmpty) {
        cartFoodQuantity[id] = item['quantity'] ?? 0;

        if (item['addOns'] != null && (item['addOns'] as List).isNotEmpty) {
          cartAddOnQuantity[id] = {};
          for (var addOn in item['addOns'] as List) {
            final addOnId = _addOnIdFromMap(addOn);
            if (addOnId.isNotEmpty) {
              cartAddOnQuantity[id]![addOnId] = addOn['quantity'] ?? 0;
            }
          }
        }
      }
    }

    // Also revert CartService to match
    final cartService = Get.find<CartService>();
    cartService.updateCartFromApi({
      'items': cartItems.toList(),
      'totals':
          lastCartItemResponse?['totals'] ??
          {'itemCount': 0, 'grandTotal': 0.0},
    });
  }

  // ============================================================================
  // ADD/UPDATE TO CART
  // ============================================================================

  Future<void> addOrUpdateItemToCart() async {
    if (selectedFoodItem?.foodId == null) return;
    if (isCartSubmitting) return;

    try {
      isCartSubmitting = true;
      update(['total_price']);

      _autoRemoveCheckTimer?.cancel();

      final foodId = selectedFoodItem!.foodId!;
      final hasCustomizations = _isScenario3And4(selectedFoodItem!);
      final hasAddOns =
          selectedFoodItem?.addOns != null &&
          selectedFoodItem!.addOns!.isNotEmpty;

      if (hasCustomizations && getTotalCustomizationQuantity() == 0) {
        bsAddOnQuantity.clear();
      }

      final requestBody = _buildAddToCartRequestBody();

      if (requestBody == null) {
        return;
      }

      final response = await _apiClient.post(
        endpoint: Urls.addOrUpdateCartUrl,
        data: requestBody,
      );

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          final cartData = Map<String, dynamic>.from(response['data']);
          _applySubmittedSelectionToCartData(cartData, requestBody);

          if (!hasCustomizations && !hasAddOns) {
            _mergeScenario1Update(
              cartData,
              updatingFoodId: foodId,
              quantity: getBottomSheetItemQuantity(),
            );
          } else {
            _updateCartFromApiResponse(cartData);
          }

          final cartService = Get.find<CartService>();
          cartService.recordSubmittedOptionState(
            foodId: foodId,
            addOns: requestBody['addOns'],
            customizations: requestBody['customizations'],
          );
          cartService.updateCartFromApi(cartData);
          update(['food_grid', 'bottom_cart_bar']);

          resetBottomSheetState();
          Navigator.pop(Get.context!);
        } else {
          final msg = response['message'] ?? 'Failed to add item to cart';
          _showErrorSnackbar(msg);
        }
      } else {
        _showErrorSnackbar('Failed to add item to cart');
      }
    } catch (e) {
      debugPrint('❌ addOrUpdateItemToCart error: $e');
      _showErrorSnackbar('Something went wrong. Please try again.');
    } finally {
      isCartSubmitting = false;
      update(['total_price']);
    }
  }

  // ============================================================================
  // ERROR SNACKBAR — dark background with red border, used for all cart errors
  // ============================================================================

  /// All cart errors go through here — vendor conflict, network errors, etc.
  /// Uses [Get.rawSnackbar] for full layout control over an open bottom sheet.
  void _showErrorSnackbar(String message) {
    final isVendorConflict =
        message.toLowerCase().contains('another vendor') ||
        message.toLowerCase().contains('clear cart');

    final icon =
        isVendorConflict
            ? Icons.remove_shopping_cart_rounded
            : Icons.error_rounded;

    Get.rawSnackbar(
      messageText: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFFF5252), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w400,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      borderRadius: 14,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      boxShadows: [
        BoxShadow(
          color: const Color(0xFFD32F2F).withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 2),
        ),
      ],
      borderWidth: 1.5,
    );
  }

  Future<void> _callRemoveItemWithQtyZero(String foodId) async {
    try {
      final requestBody = _buildRemoveItemRequestBody(foodId);

      final response = await _apiClient.post(
        endpoint: Urls.addOrUpdateCartUrl,
        data: requestBody,
      );

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          final cartData = response['data'];
          _updateCartFromApiResponse(cartData);

          final cartService = Get.find<CartService>();
          cartService.updateCartFromApi(cartData);
          update(['food_grid', 'bottom_cart_bar']);

          resetBottomSheetState();
          Navigator.pop(Get.context!);
        } else {
          _showSafeSnackbar(
            'Error',
            response['message'] ?? 'Failed to remove item',
          );
        }
      }
    } catch (e) {
      _showSafeSnackbar('Error', 'Failed to remove item');
    }
  }

  void _showSafeSnackbar(String title, String message) {
    try {
      if (Get.context != null && ModalRoute.of(Get.context!) != null) {
        Get.snackbar(title, message);
      }
    } catch (e) {
      debugPrint('Snackbar error: $title - $message');
    }
  }

  Map<String, dynamic> _buildRemoveItemRequestBody(String foodId) {
    final serviceType = _getCleanServiceType(Store.deliveryPreference);

    final hasCustomizations =
        bsCustomizationQuantity.isNotEmpty &&
        bsCustomizationQuantity.values.any((qty) => qty > 0);

    final foodQuantity = hasCustomizations ? 1 : 0;

    final requestBody = {
      'foodId': foodId,
      'quantity': foodQuantity,
      'serviceType': serviceType,
    };

    if (!hasCustomizations) {
      if (bsAddOnQuantity.isNotEmpty) {
        final addOnsToSend =
            bsAddOnQuantity.entries
                .map((e) => {'addOnId': e.key, 'quantity': e.value})
                .toList();

        if (addOnsToSend.isNotEmpty) {
          requestBody['addOns'] = addOnsToSend;
        }
      }
    } else {
      if (bsCustomizationQuantity.isNotEmpty) {
        final customizationsToSend =
            bsCustomizationQuantity.entries
                .map((e) => {'customizationId': e.key, 'quantity': e.value})
                .toList();

        if (customizationsToSend.isNotEmpty) {
          requestBody['customizations'] = customizationsToSend;
        }
      }

      if (bsAddOnQuantity.isNotEmpty) {
        final addOnsToSend =
            bsAddOnQuantity.entries
                .map((e) => {'addOnId': e.key, 'quantity': e.value})
                .toList();

        if (addOnsToSend.isNotEmpty) {
          requestBody['addOns'] = addOnsToSend;
        }
      }
    }

    return requestBody;
  }

  void _updateCartFromApiResponse(Map<String, dynamic> cartData) {
    try {
      lastCartItemResponse = cartData;

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
              final addOnId = _addOnIdFromMap(addOn);
              if (addOnId.isNotEmpty) {
                cartAddOnQuantity[foodId]![addOnId] = addOn['quantity'] ?? 0;
              }
            }
          }
        } else {
          cartCustomizationQuantity[foodId] = {};
          for (var custom in item['customizations'] as List) {
            final customizationId = _customizationIdFromMap(custom);
            if (customizationId.isNotEmpty) {
              cartCustomizationQuantity[foodId]![customizationId] =
                  custom['quantity'] ?? 0;
            }
          }

          if (item['addOns'] != null && (item['addOns'] as List).isNotEmpty) {
            cartAddOnQuantity[foodId] = {};
            for (var addOn in item['addOns'] as List) {
              final addOnId = _addOnIdFromMap(addOn);
              if (addOnId.isNotEmpty) {
                cartAddOnQuantity[foodId]![addOnId] = addOn['quantity'] ?? 0;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating cart from API response: $e');
    }
  }

  Map<String, dynamic>? _buildAddToCartRequestBody() {
    if (selectedFoodItem?.foodId == null) return null;

    final foodId = selectedFoodItem!.foodId!;
    final serviceType = _getCleanServiceType(Store.deliveryPreference);
    final hasCustomizations = _isScenario3And4(selectedFoodItem!);

    if (!hasCustomizations) {
      final quantity = getBottomSheetItemQuantity();
      final requestBody = {
        'foodId': foodId,
        'quantity': quantity,
        'serviceType': serviceType,
      };

      if (bsAddOnQuantity.isNotEmpty) {
        final addOnsToSend =
            isEditMode
                ? bsAddOnQuantity.entries
                    .map((e) => {'addOnId': e.key, 'quantity': e.value})
                    .toList()
                : bsAddOnQuantity.entries
                    .where((e) => e.value > 0)
                    .map((e) => {'addOnId': e.key, 'quantity': e.value})
                    .toList();

        if (addOnsToSend.isNotEmpty) {
          requestBody['addOns'] = addOnsToSend;
        }
      }

      return requestBody;
    } else {
      final requestBody = {
        'foodId': foodId,
        'quantity': 1,
        'serviceType': serviceType,
      };

      if (bsCustomizationQuantity.isNotEmpty) {
        final customizationsToSend =
            isEditMode
                ? bsCustomizationQuantity.entries
                    .map((e) => {'customizationId': e.key, 'quantity': e.value})
                    .toList()
                : bsCustomizationQuantity.entries
                    .where((e) => e.value > 0)
                    .map((e) => {'customizationId': e.key, 'quantity': e.value})
                    .toList();

        if (customizationsToSend.isNotEmpty || isEditMode) {
          requestBody['customizations'] = customizationsToSend;
        }
      }

      if (bsAddOnQuantity.isNotEmpty) {
        final addOnsToSend =
            isEditMode
                ? bsAddOnQuantity.entries
                    .map((e) => {'addOnId': e.key, 'quantity': e.value})
                    .toList()
                : bsAddOnQuantity.entries
                    .where((e) => e.value > 0)
                    .map((e) => {'addOnId': e.key, 'quantity': e.value})
                    .toList();

        if (addOnsToSend.isNotEmpty || isEditMode) {
          requestBody['addOns'] = addOnsToSend;
        }
      }

      return requestBody;
    }
  }

  void _applySubmittedSelectionToCartData(
    Map<String, dynamic> cartData,
    Map<String, dynamic> requestBody,
  ) {
    final items = cartData['items'];
    final foodId = requestBody['foodId']?.toString() ?? '';
    if (foodId.isEmpty || items is! List) return;

    final itemIndex = items.indexWhere((item) {
      return item is Map && item['foodId']?.toString() == foodId;
    });
    if (itemIndex == -1) return;

    final item = Map<String, dynamic>.from(items[itemIndex] as Map);
    final addOns = _submittedAddOns(requestBody['addOns']);
    final customizations = _submittedCustomizations(
      requestBody['customizations'],
    );

    if (requestBody.containsKey('addOns')) {
      item['addOns'] = addOns;
    }
    if (requestBody.containsKey('customizations')) {
      item['customizations'] = customizations;
    }

    item['itemTotal'] = _submittedItemTotal(item);
    items[itemIndex] = item;
    cartData['items'] = items;
  }

  List<Map<String, dynamic>> _submittedAddOns(dynamic submitted) {
    if (submitted is! List) return [];

    return submitted
        .whereType<Map>()
        .where((addOn) => (_asDouble(addOn['quantity']) ?? 0) > 0)
        .map((addOn) {
          final addOnId = addOn['addOnId']?.toString() ?? '';
          final source = selectedFoodItem?.addOns?.firstWhere(
            (item) => item.addOnId == addOnId || item.id == addOnId,
            orElse: () => AddOn(),
          );
          return {
            'addOnId': addOnId,
            'name': source?.name ?? '',
            'price': source?.price ?? 0,
            'quantity': addOn['quantity'] ?? 0,
          };
        })
        .toList();
  }

  List<Map<String, dynamic>> _submittedCustomizations(dynamic submitted) {
    if (submitted is! List) return [];

    return submitted
        .whereType<Map>()
        .where(
          (customization) => (_asDouble(customization['quantity']) ?? 0) > 0,
        )
        .map((customization) {
          final customizationId =
              customization['customizationId']?.toString() ?? '';
          final source = selectedFoodItem?.customizations?.firstWhere(
            (item) =>
                item.customizationId == customizationId ||
                item.id == customizationId,
            orElse: () => Customization(),
          );
          return {
            'customizationId': customizationId,
            'name': source?.name ?? '',
            'price': source?.price ?? 0,
            'quantity': customization['quantity'] ?? 0,
          };
        })
        .toList();
  }

  double _submittedItemTotal(Map<String, dynamic> item) {
    final quantity = _asDouble(item['quantity']) ?? 1;
    final basePrice =
        _asDouble(item['effectivePrice']) ??
        _asDouble(item['basePrice']) ??
        _effectiveFoodPrice(selectedFoodItem);
    final addOnsTotal = _optionTotal(item['addOns']);
    final customizationsTotal = _optionTotal(item['customizations']);

    if (customizationsTotal > 0) {
      return customizationsTotal + addOnsTotal;
    }
    return (basePrice * quantity) + addOnsTotal;
  }

  double getBasePrice() {
    if (selectedFoodItem == null) return 0;
    return _effectiveFoodPrice(selectedFoodItem);
  }

  double _effectiveFoodPrice(Food? food) {
    if (food == null) return 0;
    return _asDouble(food.specialOfferPrice) ??
        food.discountPrice ??
        food.foodPrice ??
        0;
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  double _optionTotal(dynamic options) {
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

  String _addOnIdFromMap(dynamic addOn) {
    if (addOn is! Map) return '';
    final nested = addOn['addOn'];
    return (addOn['addOnId'] ??
            addOn['id'] ??
            addOn['_id'] ??
            (nested is Map
                ? nested['addOnId'] ?? nested['id'] ?? nested['_id']
                : null) ??
            '')
        .toString();
  }

  String _customizationIdFromMap(dynamic customization) {
    if (customization is! Map) return '';
    final nested = customization['customization'];
    return (customization['customizationId'] ??
            customization['id'] ??
            customization['_id'] ??
            (nested is Map
                ? nested['customizationId'] ?? nested['id'] ?? nested['_id']
                : null) ??
            '')
        .toString();
  }

  double getAddOnsPrice() {
    double total = 0;
    bsAddOnQuantity.forEach((addOnId, qty) {
      if (qty > 0) {
        final addOn = selectedFoodItem?.addOns?.firstWhere(
          (a) => a.addOnId == addOnId,
          orElse: () => AddOn(),
        );
        if (addOn != null && addOn.addOnId != null) {
          total += (addOn.price ?? 0).toDouble() * qty;
        }
      }
    });
    return total;
  }

  double getCustomizationPrice() {
    double total = 0;
    bsCustomizationQuantity.forEach((customId, qty) {
      if (qty > 0) {
        final customization = selectedFoodItem?.customizations?.firstWhere(
          (c) => c.customizationId == customId,
          orElse: () => Customization(),
        );
        if (customization != null && customization.customizationId != null) {
          total += (customization.price ?? 0).toDouble() * qty;
        }
      }
    });
    return total;
  }

  double getTotalBottomSheetPrice() {
    final basePrice = getBasePrice();
    final addOnsPrice = getAddOnsPrice();
    final customizationPrice = getCustomizationPrice();

    if (selectedFoodItem?.customizations != null &&
        selectedFoodItem!.customizations!.isNotEmpty) {
      int customQtyTotal = getTotalCustomizationQuantity();
      if (customQtyTotal == 0) return 0;
      return customizationPrice + addOnsPrice;
    }

    final itemQty = getBottomSheetItemQuantity();
    return (basePrice * itemQty) + addOnsPrice;
  }

  int getTotalCartItemCount() {
    try {
      if (lastCartItemResponse != null &&
          lastCartItemResponse!['totals'] != null) {
        return lastCartItemResponse!['totals']['itemCount'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error getting item count: $e');
    }
    return 0;
  }

  double getTotalCartPrice() {
    try {
      if (lastCartItemResponse != null &&
          lastCartItemResponse!['totals'] != null) {
        return (lastCartItemResponse!['totals']['grandTotal'] ?? 0).toDouble();
      }
    } catch (e) {
      debugPrint('Error getting total price: $e');
    }
    return 0;
  }

  Food? _getFoodById(String foodId) {
    for (var categoryData in restaurantData) {
      if (categoryData.foods != null) {
        final food = categoryData.foods!.firstWhere(
          (f) => f.foodId == foodId,
          orElse: () => Food(),
        );
        if (food.foodId != null) return food;
      }
    }
    return null;
  }

  bool get hasCartItems => getTotalCartItemCount() > 0;

  String get selectedCategoryName =>
      selectedCategoryIndex < categories.length
          ? categories[selectedCategoryIndex]
          : '';

  int get foodItemsCount => getFilteredFoodItems().length;

  bool get hasCustomizations =>
      selectedFoodItem?.customizations != null &&
      selectedFoodItem!.customizations!.isNotEmpty;

  bool get hasAddOns =>
      selectedFoodItem?.addOns != null && selectedFoodItem!.addOns!.isNotEmpty;

  bool get isBottomSheetReady {
    if (hasCustomizations) {
      return getTotalCustomizationQuantity() > 0;
    }
    return true;
  }

  bool isFoodInCart(String foodId) {
    return cartFoodQuantity.containsKey(foodId) &&
        cartFoodQuantity[foodId]! > 0;
  }

  String getBottomSheetButtonText() {
    return isEditMode ? 'Edit Item' : 'Add Item';
  }

  Map<String, dynamic>? getCartDisplayInfo() {
    if (lastCartItemResponse == null) return null;

    return {
      'itemCount': getTotalCartItemCount(),
      'totalPrice': getTotalCartPrice(),
      'items': cartItems,
      'totals': lastCartItemResponse!['totals'],
    };
  }
}
