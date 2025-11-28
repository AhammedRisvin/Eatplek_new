import 'dart:async';
import 'dart:convert';

import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../model/restaurent_details_model.dart';

class RestaurantDetailViewController extends GetxController {
  final FittorConnect _apiClient = FittorConnect();

  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  RestuarantDetailsModel? restaurantDetailsModel;
  List<RestuarantDetailsData> restaurantData = [];
  List<String> banners = [];

  int selectedCategoryIndex = 0;
  List<String> categories = [];

  // Cart state
  Map<String, int> cartFoodQuantity = {};
  Map<String, Map<String, int>> cartCustomizationQuantity = {};
  Map<String, Map<String, int>> cartAddOnQuantity = {};

  // API response storage (Source of truth)
  Map<String, dynamic>? lastCartItemResponse;
  List<Map<String, dynamic>> cartItems = [];

  // Bottom sheet state
  Food? selectedFoodItem;
  Map<String, int> bsCustomizationQuantity = {};
  Map<String, int> bsAddOnQuantity = {};
  Map<String, int> bsItemQuantity = {};

  bool isEditMode = false;
  String? editingFoodId;
  String? restaurantId;

  // Debouncer for Scenario 1
  Timer? _quantityDebounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void onInit() {
    super.onInit();
    _extractRestaurantIdAndFetch();
  }

  @override
  void onClose() {
    _quantityDebounceTimer?.cancel();
    super.onClose();
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
        endpoint: "${Urls.getRestaurantDetailsUrl}$restaurantId/foods?service=$serviceType",
      );

      if (response != null && response is Map<String, dynamic>) {
        restaurantDetailsModel = RestuarantDetailsModel.fromJson(response);

        if (restaurantDetailsModel?.status == true && restaurantDetailsModel?.data != null) {
          restaurantData = restaurantDetailsModel!.data!;
          banners = restaurantDetailsModel?.banners ?? [];

          // ✅ Initialize cart from foods with cartCount > 0
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
          errorMessage = restaurantDetailsModel?.message ?? 'Failed to load restaurant details';
          isLoading = false;
        }
      } else {
        hasError = true;
        errorMessage = 'Invalid response format';
        isLoading = false;
      }

      // ✅ Include 'bottom_cart_bar' to refresh cart display
      update(['main_content', 'bottom_cart_bar']);
    } catch (e) {
      hasError = true;
      errorMessage = 'Error loading restaurant details: $e';
      isLoading = false;
      update(['main_content']);
    }
  }

  // ✅ Initialize cart from restaurant data
  void _initializeCartFromRestaurantData() {
    try {
      debugPrint('🔄 Initializing cart from restaurant data...');

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

            // Check if food has cartCount > 0
            if (food.cartCount != null && food.cartCount! > 0) {
              debugPrint('📦 Found item in cart: ${food.foodName} (qty: ${food.cartCount})');

              // Build cart item structure
              final basePrice = (food.discountPrice ?? food.foodPrice ?? 0).toDouble();
              final hasCustomizations = food.customizations != null && food.customizations!.isNotEmpty;

              Map<String, dynamic> cartItem = {
                'foodId': foodId,
                'foodName': food.foodName,
                'foodImage': food.foodImage,
                'quantity': hasCustomizations ? 1 : (food.cartCount?.toInt() ?? 1),
                'basePrice': basePrice,
                'effectivePrice': basePrice,
                'customizations': [],
                'addOns': [],
                'itemTotal': basePrice * (hasCustomizations ? 1 : (food.cartCount?.toInt() ?? 1)),
              };

              // Add customizations with cartCount
              if (hasCustomizations) {
                List<Map<String, dynamic>> customizationsList = [];

                for (var customization in food.customizations!) {
                  if (customization.cartCount != null && customization.cartCount! > 0) {
                    debugPrint('   📌 Customization: ${customization.name} (qty: ${customization.cartCount})');

                    customizationsList.add({
                      'customizationId': customization.customizationId,
                      'name': customization.name,
                      'price': customization.price,
                      'quantity': customization.cartCount,
                    });

                    cartCustomizationQuantity[foodId] ??= {};
                    cartCustomizationQuantity[foodId]![customization.customizationId!] =
                        customization.cartCount!.toInt();
                  }
                }

                cartItem['customizations'] = customizationsList;

                // Calculate total price for customizations
                int totalCustomizationQty = 0;
                for (var custom in customizationsList) {
                  totalCustomizationQty += (custom['quantity'] as int);
                }
                cartItem['itemTotal'] = basePrice * totalCustomizationQty;
              } else {
                cartFoodQuantity[foodId] = food.cartCount!.toInt();
              }

              // Add add-ons with cartCount
              if (food.addOns != null) {
                List<Map<String, dynamic>> addOnsList = [];

                for (var addOn in food.addOns!) {
                  if (addOn.cartCount != null && addOn.cartCount! > 0) {
                    debugPrint('   🧂 Add-on: ${addOn.name} (qty: ${addOn.cartCount})');

                    addOnsList.add({
                      'addOnId': addOn.addOnId,
                      'name': addOn.name,
                      'price': addOn.price,
                      'quantity': addOn.cartCount,
                    });

                    cartAddOnQuantity[foodId] ??= {};
                    cartAddOnQuantity[foodId]![addOn.addOnId!] = addOn.cartCount!.toInt();

                    // Add add-on price to total
                    totalPrice += (addOn.price ?? 0).toDouble() * addOn.cartCount!;
                  }
                }

                cartItem['addOns'] = addOnsList;
              }

              cartItems.add(cartItem);

              // Calculate total items and price
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

      // Create a mock lastCartItemResponse for BottomCartBar
      if (cartItems.isNotEmpty) {
        lastCartItemResponse = {
          'items': cartItems,
          'totals': {'itemCount': totalItems, 'grandTotal': totalPrice},
        };
        debugPrint('✅ Cart initialized from page load: $totalItems items, ₹${totalPrice.toStringAsFixed(2)} total');
      } else {
        debugPrint('ℹ️ No items in cart on page load');
      }
    } catch (e) {
      debugPrint('❌ Error initializing cart from restaurant data: $e');
    }
  }

  String _getCleanServiceType(String servicePreference) {
    String cleaned = servicePreference.toLowerCase().trim();

    if (cleaned.contains('delivery') || cleaned.contains('🛵')) {
      return 'delivery';
    } else if (cleaned.contains('dine-in') || cleaned.contains('dine in') || cleaned.contains('🍽')) {
      return 'dine-in';
    } else if (cleaned.contains('takeaway') || cleaned.contains('🎁')) {
      return 'takeaway';
    } else if (cleaned.contains('car-dine') || cleaned.contains('car dine') || cleaned.contains('🚗')) {
      return 'car-dine-in';
    }

    return 'delivery';
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
    if (selectedCategoryIndex < 0 || selectedCategoryIndex >= restaurantData.length) {
      return [];
    }

    final selectedCategory = restaurantData[selectedCategoryIndex];
    return selectedCategory.foods ?? [];
  }

  void filterFoodByCategory(String category) {
    update(['food_grid']);
  }

  // SCENARIO DETECTION
  bool _isScenario1(Food foodItem) {
    final hasCustomizations = foodItem.customizations != null && foodItem.customizations!.isNotEmpty;
    final hasAddOns = foodItem.addOns != null && foodItem.addOns!.isNotEmpty;
    return !hasCustomizations && !hasAddOns;
  }

  bool _isScenario2(Food foodItem) {
    final hasCustomizations = foodItem.customizations != null && foodItem.customizations!.isNotEmpty;
    final hasAddOns = foodItem.addOns != null && foodItem.addOns!.isNotEmpty;
    return !hasCustomizations && hasAddOns;
  }

  bool _isScenario3And4(Food foodItem) {
    final hasCustomizations = foodItem.customizations != null && foodItem.customizations!.isNotEmpty;
    return hasCustomizations;
  }

  // CHECK IF ITEM IS IN CART
  bool _isItemInCart(String foodId) {
    return cartItems.any((item) => item['foodId'] == foodId);
  }

  // GET CURRENT CART ITEM FROM API RESPONSE
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
      // Scenario 1: Food only
      bsItemQuantity[foodId] = 1;
    } else if (!hasCustomizations && hasAddOns) {
      // Scenario 2: Food + Add-ons
      bsItemQuantity[foodId] = 1;
      // ❌ NO: Don't initialize all add-ons with 0 in ADD mode
      // Only user-selected add-ons will be in bsAddOnQuantity
    } else {
      // Scenario 3 & 4: Customizations (food qty always 1)
      bsItemQuantity[foodId] = 1;
      // ❌ NO: Don't initialize all customizations/add-ons with 0 in ADD mode
      // Only user-selected items will be in the maps
    }

    debugPrint('📝 ADD MODE: Scenario initialized empty for ${foodItem.foodName}');
  }

  void _initializeBottomSheetStateForEdit(Food foodItem) {
    final foodId = foodItem.foodId!;
    final hasCustomizations = _isScenario3And4(foodItem);

    // Clear existing data
    bsCustomizationQuantity.clear();
    bsAddOnQuantity.clear();
    bsItemQuantity.clear();

    // Get the current cart item from API response
    final currentCartItem = _getCartItemFromResponse(foodId);

    if (currentCartItem == null) {
      debugPrint('⚠️ EDIT MODE: No current cart item found for $foodId');
      return;
    }

    debugPrint('📖 EDIT MODE: Pre-filling from API response for ${foodItem.foodName}');

    if (!hasCustomizations) {
      // Scenario 1 & 2: Get food quantity from API response
      final quantity = currentCartItem['quantity'] ?? 1;
      bsItemQuantity[foodId] = quantity;
      debugPrint('📖 Scenario 1/2: Food qty = $quantity');

      // ✅ FIXED: Only pre-fill add-ons that were ALREADY in the cart
      if (currentCartItem['addOns'] != null) {
        final addOns = currentCartItem['addOns'] as List;
        for (var addOn in addOns) {
          final addOnId = addOn['addOnId'] ?? '';
          final addOnQty = addOn['quantity'] ?? 0;
          if (addOnId.isNotEmpty) {
            bsAddOnQuantity[addOnId] = addOnQty;
            debugPrint('📖 Add-on ${addOn['name']}: qty = $addOnQty');
          }
        }
      }
    } else {
      // Scenario 3 & 4: Pre-fill customizations from API response
      // ✅ FIXED: Only pre-fill customizations that were ALREADY in the cart
      if (currentCartItem['customizations'] != null) {
        final customizations = currentCartItem['customizations'] as List;
        for (var customization in customizations) {
          final customId = customization['customizationId'] ?? '';
          final customQty = customization['quantity'] ?? 0;
          if (customId.isNotEmpty) {
            bsCustomizationQuantity[customId] = customQty;
            debugPrint('📖 Customization ${customization['name']}: qty = $customQty');
          }
        }
      }

      // ✅ FIXED: Only pre-fill add-ons that were ALREADY in the cart
      if (currentCartItem['addOns'] != null) {
        final addOns = currentCartItem['addOns'] as List;
        for (var addOn in addOns) {
          final addOnId = addOn['addOnId'] ?? '';
          final addOnQty = addOn['quantity'] ?? 0;
          if (addOnId.isNotEmpty) {
            bsAddOnQuantity[addOnId] = addOnQty;
            debugPrint('📖 Add-on ${addOn['name']}: qty = $addOnQty');
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

  // ✅ SCENARIO 2: Allow decrease to 0 in EDIT mode, block in ADD mode
  void decreaseBottomSheetItemQuantity() {
    if (selectedFoodItem?.foodId == null) return;

    final foodId = selectedFoodItem!.foodId!;
    final currentQty = getBottomSheetItemQuantity();

    if (isEditMode) {
      // ✅ EDIT MODE: Allow quantity to go to 0
      if (currentQty > 0) {
        bsItemQuantity[foodId] = currentQty - 1;
        debugPrint('🍔 Scenario 2 EDIT: Food qty decreased to ${bsItemQuantity[foodId]}');

        // ❌ DON'T clear add-ons here - we need them for the API request!
        // They will be sent to backend with quantity 0 when removing item
        // The backend needs the complete structure including add-ons

        update(['total_price']);
      }
    } else {
      // ✅ ADD MODE: Block quantity from going below 1
      if (currentQty > 1) {
        bsItemQuantity[foodId] = currentQty - 1;
        debugPrint('🍔 Scenario 2 ADD: Food qty decreased to ${bsItemQuantity[foodId]}');
        update(['total_price']);
      }
      // Do nothing if currentQty == 1 (block from going to 0)
    }
  }

  void toggleCustomization(String customizationId) {
    if (selectedFoodItem?.foodId == null) return;

    final currentQty = bsCustomizationQuantity[customizationId] ?? 0;
    bsCustomizationQuantity[customizationId] = currentQty + 1;

    debugPrint('📌 Customization qty increased to ${bsCustomizationQuantity[customizationId]}');

    update(['customization_widget', 'bottom_sheet_content', 'total_price']);
  }

  // ✅ SCENARIO 3 & 4: Decrease customization
  void decreaseCustomization(String customizationId) {
    if (selectedFoodItem?.foodId == null) return;

    final currentQty = bsCustomizationQuantity[customizationId] ?? 0;

    if (currentQty > 0) {
      bsCustomizationQuantity[customizationId] = currentQty - 1;

      debugPrint('📌 Customization qty decreased to ${bsCustomizationQuantity[customizationId]}');

      // ❌ DON'T clear add-ons when customizations reach 0
      // We need them for the API request when removing the item
      // The backend needs the complete structure including add-ons
      // Only clear after API response succeeds

      update(['customization_widget', 'addons_list', 'bottom_sheet_content', 'total_price']);
    }
  }

  int getCustomizationCount(String customizationId) {
    return bsCustomizationQuantity[customizationId] ?? 0;
  }

  // ✅ UPDATED: Only count non-zero quantities
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

    debugPrint('🧂 Add-on qty increased to ${bsAddOnQuantity[addOnId]}');

    update(['addons_list', 'bottom_sheet_content', 'total_price']);
  }

  void decreaseAddOn(String addOnId) {
    if (selectedFoodItem?.foodId == null) return;

    final currentQty = bsAddOnQuantity[addOnId] ?? 0;

    if (currentQty > 0) {
      bsAddOnQuantity[addOnId] = currentQty - 1;

      debugPrint('🧂 Add-on qty decreased to ${bsAddOnQuantity[addOnId]}');

      update(['addons_list', 'bottom_sheet_content', 'total_price']);
    }
  }

  int getAddOnCount(String addOnId) {
    return bsAddOnQuantity[addOnId] ?? 0;
  }

  // SCENARIO 1: Quantity change with debouncer
  void increaseScenario1Quantity(String foodId) {
    final currentQty = cartFoodQuantity[foodId] ?? 0;
    cartFoodQuantity[foodId] = currentQty + 1;

    update(['food_grid', 'bottom_cart_bar']);

    _debouncedUpdateQuantity(foodId, cartFoodQuantity[foodId]!);
  }

  void decreaseScenario1Quantity(String foodId) {
    final currentQty = cartFoodQuantity[foodId] ?? 0;

    if (currentQty > 1) {
      cartFoodQuantity[foodId] = currentQty - 1;
      update(['food_grid', 'bottom_cart_bar']);
      _debouncedUpdateQuantity(foodId, cartFoodQuantity[foodId]!);
    } else if (currentQty == 1) {
      // ✅ IMMEDIATE: API call when reaching 0
      debugPrint('🍕 Scenario 1: Quantity reached 0 - making immediate API call for removal');
      cartFoodQuantity.remove(foodId);
      update(['food_grid', 'bottom_cart_bar']);
      _callScenario1UpdateQuantityApi(foodId, 0);
    }
  }

  void _debouncedUpdateQuantity(String foodId, int quantity) {
    _quantityDebounceTimer?.cancel();
    _quantityDebounceTimer = Timer(_debounceDuration, () {
      _callScenario1UpdateQuantityApi(foodId, quantity);
    });
  }

  // SCENARIO 1: API call for quantity update
  Future<void> _callScenario1UpdateQuantityApi(String foodId, int quantity) async {
    try {
      debugPrint('🔄 Scenario 1: Updating quantity via API - foodId: $foodId, qty: $quantity');

      final requestBody = {
        'foodId': foodId,
        'quantity': quantity,
        'serviceType': _getCleanServiceType(Store.deliveryPreference),
      };

      final response = await _apiClient.post(endpoint: Urls.addOrUpdateCartUrl, data: requestBody);

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          final cartData = response['data'];
          _updateCartFromApiResponse(cartData);
          debugPrint('✅ Scenario 1: Quantity updated successfully');
          update(['food_grid', 'bottom_cart_bar']);
        } else {
          // ✅ ERROR: Revert UI change
          debugPrint('❌ Scenario 1: API Error - ${response['message']}');
          _revertScenario1Change(foodId);
          Get.snackbar('Error', response['message'] ?? 'Failed to update quantity');
        }
      }
    } catch (e) {
      debugPrint('❌ Scenario 1: Exception while updating quantity: $e');
      _revertScenario1Change(foodId);
      Get.snackbar('Error', 'Failed to update quantity');
    }
  }

  // ✅ NEW: Revert Scenario 1 UI changes on API failure
  void _revertScenario1Change(String foodId) {
    // Revert from API response (source of truth)
    cartFoodQuantity.clear();
    cartAddOnQuantity.clear();

    for (var item in cartItems) {
      final id = item['foodId'] ?? '';
      if (id.isNotEmpty) {
        cartFoodQuantity[id] = item['quantity'] ?? 0;

        if (item['addOns'] != null && (item['addOns'] as List).isNotEmpty) {
          cartAddOnQuantity[id] = {};
          for (var addOn in item['addOns'] as List) {
            cartAddOnQuantity[id]![addOn['addOnId']] = addOn['quantity'] ?? 0;
          }
        }
      }
    }

    update(['food_grid', 'bottom_cart_bar']);
  }

  // SCENARIO 2-4: Add/Update item to cart via API
  Future<void> addOrUpdateItemToCart() async {
    if (selectedFoodItem?.foodId == null) return;

    try {
      final foodId = selectedFoodItem!.foodId!;
      final hasCustomizations = _isScenario3And4(selectedFoodItem!);

      debugPrint('🚀 Adding/Updating item to cart - Mode: ${isEditMode ? "EDIT" : "ADD"}');

      // ✅ NEW: For EDIT mode with qty 0 in Scenario 2
      if (isEditMode && !hasCustomizations && getBottomSheetItemQuantity() == 0) {
        debugPrint('🍔 Scenario 2 EDIT: Food qty is 0 - calling remove API');
        await _callRemoveItemWithQtyZero(foodId);
        return;
      }

      // ✅ NEW: For EDIT mode with customization qty 0 in Scenario 3 & 4
      if (isEditMode && hasCustomizations && getTotalCustomizationQuantity() == 0) {
        debugPrint('📌 Scenario 3/4 EDIT: Customization qty is 0 - calling remove API');
        await _callRemoveItemWithQtyZero(foodId);
        return;
      }

      // Build request body based on scenario
      final requestBody = _buildAddToCartRequestBody();

      if (requestBody == null) {
        debugPrint('❌ Error: Could not build request body');
        return;
      }

      debugPrint('📤 API Request: ${jsonEncode(requestBody)}');

      final response = await _apiClient.post(endpoint: Urls.addOrUpdateCartUrl, data: requestBody);

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          final cartData = response['data'];
          _updateCartFromApiResponse(cartData);

          debugPrint('✅ Item ${isEditMode ? "updated" : "added"} successfully');

          // ✅ FIXED: Use Navigator.pop instead of Get.back to avoid snackbar controller issues
          resetBottomSheetState();
          Navigator.pop(Get.context!);

          update(['food_grid', 'bottom_cart_bar']);
        } else {
          // ✅ FIXED: Show error BEFORE closing sheet to avoid overlay error
          debugPrint('❌ API Error: ${response['message']}');
          Get.snackbar('Error', response['message'] ?? 'Failed to add item to cart');
          // Don't close sheet on error - let user retry or dismiss manually
        }
      }
    } catch (e) {
      // ✅ FIXED: Show error BEFORE closing sheet to avoid overlay error
      debugPrint('❌ Exception while adding item: $e');
      Get.snackbar('Error', 'Failed to add item to cart');
      // Don't close sheet on error - let user retry or dismiss manually
    }
  }

  // ✅ NEW: Remove item API call when quantity is 0
  Future<void> _callRemoveItemWithQtyZero(String foodId) async {
    try {
      debugPrint('🗑️ Removing item (qty=0) - foodId: $foodId');

      final requestBody = _buildRemoveItemRequestBody(foodId);

      debugPrint('📤 Remove API Request: ${jsonEncode(requestBody)}');

      final response = await _apiClient.post(endpoint: Urls.addOrUpdateCartUrl, data: requestBody);

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          final cartData = response['data'];
          _updateCartFromApiResponse(cartData);

          debugPrint('✅ Item removed successfully (qty=0)');

          // ✅ FIXED: Use Navigator.pop instead of Get.back
          resetBottomSheetState();
          Navigator.pop(Get.context!);

          update(['food_grid', 'bottom_cart_bar']);
        } else {
          // ✅ FIXED: Show error using safe method that checks context
          debugPrint('❌ API Error: ${response['message']}');
          _showSafeSnackbar('Error', response['message'] ?? 'Failed to remove item');
          // Don't close sheet on error - let user retry
        }
      }
    } catch (e) {
      // ✅ FIXED: Show error using safe method
      debugPrint('❌ Exception while removing item: $e');
      _showSafeSnackbar('Error', 'Failed to remove item');
      // Don't close sheet on error - let user retry
    }
  }

  // ✅ NEW: Safe snackbar method that avoids overlay errors
  void _showSafeSnackbar(String title, String message) {
    try {
      // Try using GetX snackbar first (works when context is valid)
      if (Get.context != null && ModalRoute.of(Get.context!) != null) {
        Get.snackbar(title, message);
      } else {
        // Fallback: Use debugPrint if context is invalid
        debugPrint('⚠️ Snackbar skipped (invalid context): $title - $message');
      }
    } catch (e) {
      // Final fallback: Just log the error
      debugPrint('⚠️ Snackbar error (fallback): $title - $message');
      debugPrint('Error details: $e');
    }
  }

  // ✅ NEW: Build request body for removing item with all associated customizations/add-ons
  Map<String, dynamic> _buildRemoveItemRequestBody(String foodId) {
    final serviceType = _getCleanServiceType(Store.deliveryPreference);

    // ✅ FIXED: For customization scenarios, ALWAYS send quantity=1
    // For food-only scenarios, send quantity=0
    final hasCustomizations = bsCustomizationQuantity.isNotEmpty;
    final foodQuantity = hasCustomizations ? 1 : 0;

    final requestBody = {'foodId': foodId, 'quantity': foodQuantity, 'serviceType': serviceType};

    if (!hasCustomizations) {
      // Scenario 2: Include all add-ons (even with 0 quantity)
      if (bsAddOnQuantity.isNotEmpty) {
        final addOnsToSend = bsAddOnQuantity.entries.map((e) => {'addOnId': e.key, 'quantity': e.value}).toList();

        if (addOnsToSend.isNotEmpty) {
          requestBody['addOns'] = addOnsToSend;
          debugPrint('📤 Remove (Scenario 2): Including ${addOnsToSend.length} add-ons');
        }
      }
    } else {
      // Scenario 3 & 4: Include all customizations and add-ons (even with 0 quantity)
      if (bsCustomizationQuantity.isNotEmpty) {
        final customizationsToSend =
            bsCustomizationQuantity.entries.map((e) => {'customizationId': e.key, 'quantity': e.value}).toList();

        if (customizationsToSend.isNotEmpty) {
          requestBody['customizations'] = customizationsToSend;
          debugPrint('📤 Remove (Scenario 3/4): Including ${customizationsToSend.length} customizations');
        }
      }

      if (bsAddOnQuantity.isNotEmpty) {
        final addOnsToSend = bsAddOnQuantity.entries.map((e) => {'addOnId': e.key, 'quantity': e.value}).toList();

        if (addOnsToSend.isNotEmpty) {
          requestBody['addOns'] = addOnsToSend;
          debugPrint('📤 Remove (Scenario 3/4): Including ${addOnsToSend.length} add-ons');
        }
      }
    }

    return requestBody;
  }

  // Update cart state from API response
  void _updateCartFromApiResponse(Map<String, dynamic> cartData) {
    try {
      // Store the API response as source of truth
      lastCartItemResponse = cartData;

      // Extract items from response
      if (cartData['items'] != null) {
        cartItems = List<Map<String, dynamic>>.from(cartData['items']);
        debugPrint('📊 Cart updated: ${cartItems.length} items');
      }

      // Update local maps from API response (for consistency)
      cartFoodQuantity.clear();
      cartCustomizationQuantity.clear();
      cartAddOnQuantity.clear();

      for (var item in cartItems) {
        final foodId = item['foodId'] ?? '';
        if (foodId.isEmpty) continue;

        // Check if item has customizations
        final hasCustomizations = item['customizations'] != null && (item['customizations'] as List).isNotEmpty;

        if (!hasCustomizations) {
          // Scenario 1 & 2
          cartFoodQuantity[foodId] = item['quantity'] ?? 1;

          if (item['addOns'] != null && (item['addOns'] as List).isNotEmpty) {
            cartAddOnQuantity[foodId] = {};
            for (var addOn in item['addOns'] as List) {
              cartAddOnQuantity[foodId]![addOn['addOnId']] = addOn['quantity'] ?? 0;
            }
          }
        } else {
          // Scenario 3 & 4
          cartCustomizationQuantity[foodId] = {};
          for (var custom in item['customizations'] as List) {
            cartCustomizationQuantity[foodId]![custom['customizationId']] = custom['quantity'] ?? 0;
          }

          if (item['addOns'] != null && (item['addOns'] as List).isNotEmpty) {
            cartAddOnQuantity[foodId] = {};
            for (var addOn in item['addOns'] as List) {
              cartAddOnQuantity[foodId]![addOn['addOnId']] = addOn['quantity'] ?? 0;
            }
          }
        }
      }

      debugPrint('✅ Local maps synchronized with API response');
    } catch (e) {
      debugPrint('❌ Error updating cart from API response: $e');
    }
  }

  // ✅ UPDATED: Build request body for add/update cart API
  // In ADD mode: Only send items with quantity > 0
  // In EDIT mode: Send ALL items (including zeros) to maintain backend consistency
  Map<String, dynamic>? _buildAddToCartRequestBody() {
    if (selectedFoodItem?.foodId == null) return null;

    final foodId = selectedFoodItem!.foodId!;
    final serviceType = _getCleanServiceType(Store.deliveryPreference);
    final hasCustomizations = _isScenario3And4(selectedFoodItem!);

    if (!hasCustomizations) {
      // Scenario 1 & 2: Food + optional add-ons
      final quantity = getBottomSheetItemQuantity();
      final requestBody = {'foodId': foodId, 'quantity': quantity, 'serviceType': serviceType};

      // ✅ UPDATED: In EDIT mode, send ALL add-ons (including those with 0 quantity)
      // In ADD mode, send only add-ons with quantity > 0
      if (bsAddOnQuantity.isNotEmpty) {
        final addOnsToSend =
            isEditMode
                ? bsAddOnQuantity.entries.map((e) => {'addOnId': e.key, 'quantity': e.value}).toList()
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
      // Scenario 3 & 4: Customizations + optional add-ons
      final requestBody = {'foodId': foodId, 'quantity': 1, 'serviceType': serviceType};

      // ✅ UPDATED: In EDIT mode, send ALL customizations (including those with 0 quantity)
      // In ADD mode, send only customizations with quantity > 0
      if (bsCustomizationQuantity.isNotEmpty) {
        final customizationsToSend =
            isEditMode
                ? bsCustomizationQuantity.entries.map((e) => {'customizationId': e.key, 'quantity': e.value}).toList()
                : bsCustomizationQuantity.entries
                    .where((e) => e.value > 0)
                    .map((e) => {'customizationId': e.key, 'quantity': e.value})
                    .toList();

        if (customizationsToSend.isNotEmpty) {
          requestBody['customizations'] = customizationsToSend;
        }
      }

      // ✅ UPDATED: In EDIT mode, send ALL add-ons (including those with 0 quantity)
      // In ADD mode, send only add-ons with quantity > 0
      if (bsAddOnQuantity.isNotEmpty) {
        final addOnsToSend =
            isEditMode
                ? bsAddOnQuantity.entries.map((e) => {'addOnId': e.key, 'quantity': e.value}).toList()
                : bsAddOnQuantity.entries
                    .where((e) => e.value > 0)
                    .map((e) => {'addOnId': e.key, 'quantity': e.value})
                    .toList();

        if (addOnsToSend.isNotEmpty) {
          requestBody['addOns'] = addOnsToSend;
        }
      }

      return requestBody;
    }
  }

  double getBasePrice() {
    if (selectedFoodItem == null) return 0;
    return (selectedFoodItem!.discountPrice ?? selectedFoodItem!.foodPrice ?? 0).toDouble();
  }

  double getAddOnsPrice() {
    double total = 0;
    bsAddOnQuantity.forEach((addOnId, qty) {
      if (qty > 0) {
        final addOn = selectedFoodItem?.addOns?.firstWhere((a) => a.addOnId == addOnId, orElse: () => AddOn());
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

  // ✅ FIXED: Calculate total price for bottom sheet
  // Customization scenario: customizationPrice + addOnsPrice (NO base price multiplication)
  // Food scenario: (basePrice * qty) + addOnsPrice
  double getTotalBottomSheetPrice() {
    final basePrice = getBasePrice();
    final addOnsPrice = getAddOnsPrice();
    final customizationPrice = getCustomizationPrice();

    if (selectedFoodItem?.customizations != null && selectedFoodItem!.customizations!.isNotEmpty) {
      // ✅ CUSTOMIZATION SCENARIO: Only customizations + addOns
      // DO NOT multiply basePrice - customization prices already include base food
      int customQtyTotal = getTotalCustomizationQuantity();
      if (customQtyTotal == 0) return 0;
      return customizationPrice + addOnsPrice;
    }

    // ✅ FOOD SCENARIO (1 & 2): Food + optional add-ons
    final itemQty = getBottomSheetItemQuantity();
    return (basePrice * itemQty) + addOnsPrice;
  }

  int getTotalCartItemCount() {
    try {
      if (lastCartItemResponse != null && lastCartItemResponse!['totals'] != null) {
        return lastCartItemResponse!['totals']['itemCount'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error getting item count: $e');
    }
    return 0;
  }

  double getTotalCartPrice() {
    try {
      if (lastCartItemResponse != null && lastCartItemResponse!['totals'] != null) {
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
        final food = categoryData.foods!.firstWhere((f) => f.foodId == foodId, orElse: () => Food());
        if (food.foodId != null) return food;
      }
    }
    return null;
  }

  bool get hasCartItems => getTotalCartItemCount() > 0;

  String get selectedCategoryName => selectedCategoryIndex < categories.length ? categories[selectedCategoryIndex] : '';

  int get foodItemsCount => getFilteredFoodItems().length;

  bool get hasCustomizations =>
      selectedFoodItem?.customizations != null && selectedFoodItem!.customizations!.isNotEmpty;

  bool get hasAddOns => selectedFoodItem?.addOns != null && selectedFoodItem!.addOns!.isNotEmpty;

  bool get isBottomSheetReady {
    if (hasCustomizations) {
      return getTotalCustomizationQuantity() > 0;
    }
    return true;
  }

  bool isFoodInCart(String foodId) {
    return _isItemInCart(foodId);
  }

  String getBottomSheetButtonText() {
    return isEditMode ? 'Edit Item' : 'Add Item';
  }

  // Get cart display info for BottomCartBar
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
