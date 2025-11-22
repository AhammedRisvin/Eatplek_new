import 'dart:convert';
import 'dart:developer';

import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../model/restaurent_details_model.dart';

class RestaurantDetailViewController extends GetxController {
  // API and loading states
  final FittorConnect _apiClient = FittorConnect();
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  // Restaurant data
  RestuarantDetailsModel? restaurantDetailsModel;
  List<RestuarantDetailsData> restaurantData = [];
  List<String> banners = [];

  // Category management
  int selectedCategoryIndex = 0;
  List<String> categories = [];

  // Cart state - persists across bottom sheet sessions
  Map<String, int> cartFoodQuantity = {}; // foodId -> quantity
  Map<String, Map<String, int>> cartCustomizationQuantity = {}; // foodId -> customizationId -> quantity
  Map<String, Map<String, int>> cartAddOnQuantity = {}; // foodId -> addOnId -> quantity

  // Bottom sheet temporary state - resets on close
  Food? selectedFoodItem;
  Map<String, int> bsCustomizationQuantity = {}; // Temporary customization quantities
  Map<String, int> bsAddOnQuantity = {}; // Temporary add-on quantities
  Map<String, int> bsItemQuantity = {}; // Bottom sheet item quantity for Scenario A (no customizations)

  // Edit mode tracking
  bool isEditMode = false;
  String? editingFoodId;

  String? restaurantId;

  @override
  void onInit() {
    super.onInit();
    _extractRestaurantIdAndFetch();
  }

  void _extractRestaurantIdAndFetch() {
    final args = Get.arguments;
    if (args != null && args.hotelId != null) {
      restaurantId = args.hotelId;
      debugPrint('🏪 Restaurant ID: $restaurantId');
      getRestaurantDetailsFn(restaurantId: restaurantId!);
    } else {
      hasError = true;
      errorMessage = 'Restaurant ID not found';
      update(['main_content']);
    }
  }

  // API call to fetch restaurant details
  Future<void> getRestaurantDetailsFn({required String restaurantId}) async {
    try {
      isLoading = true;
      hasError = false;
      errorMessage = '';

      update(['main_content']);

      // Clean the service preference - remove emoji and get just the value
      String serviceType = _getCleanServiceType(Store.deliveryPreference);

      final response = await _apiClient.get(
        endpoint: "${Urls.getRestaurantDetailsUrl}$restaurantId/foods?service=$serviceType",
      );

      log('Restaurant details response: $response');

      if (response != null && response is Map<String, dynamic>) {
        restaurantDetailsModel = RestuarantDetailsModel.fromJson(response);

        if (restaurantDetailsModel?.status == true && restaurantDetailsModel?.data != null) {
          restaurantData = restaurantDetailsModel!.data!;
          banners = restaurantDetailsModel?.banners ?? [];

          // Extract unique categories
          _extractCategories();

          // Filter by first category if available
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

      update(['main_content']);
    } catch (e) {
      debugPrint('Error in getRestaurantDetailsFn: $e');
      hasError = true;
      errorMessage = 'Error loading restaurant details: $e';
      isLoading = false;
      update(['main_content']);
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
    debugPrint('📂 Categories extracted: $categories');
  }

  // ==================== CATEGORY MANAGEMENT ====================

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

  // ==================== BOTTOM SHEET MANAGEMENT ====================

  /// Open bottom sheet for a food item - NEW VERSION (Add or Edit)
  void selectFoodItem(Food foodItem, {bool isEdit = false}) {
    if (foodItem.foodId == null) return;

    selectedFoodItem = foodItem;
    editingFoodId = foodItem.foodId!;
    isEditMode = isEdit;

    // Reset temporary bottom sheet state
    bsCustomizationQuantity.clear();
    bsAddOnQuantity.clear();
    bsItemQuantity.clear();

    if (isEdit) {
      // Initialize with existing cart data for editing
      _initializeBottomSheetStateForEdit(foodItem.foodId!);
      debugPrint('✏️ Edit mode - Selected food: ${foodItem.foodName} (ID: ${foodItem.foodId})');
    } else {
      // Fresh state for adding
      _initializeBottomSheetStateForAdd(foodItem.foodId!);
      debugPrint('➕ Add mode - Selected food: ${foodItem.foodName} (ID: ${foodItem.foodId})');
    }

    update(['bottom_sheet_content', 'bottom_sheet_header']);
  }

  /// Initialize bottom sheet state for ADD mode (fresh state)
  void _initializeBottomSheetStateForAdd(String foodId) {
    // Always start with quantity 1 for add mode
    bsItemQuantity[foodId] = 1;
    // Clear add-ons and customizations for fresh add
    bsCustomizationQuantity.clear();
    bsAddOnQuantity.clear();
  }

  /// Initialize bottom sheet state for EDIT mode (load existing data)
  void _initializeBottomSheetStateForEdit(String foodId) {
    // Check if item has customizations in cart
    if (cartCustomizationQuantity.containsKey(foodId)) {
      bsCustomizationQuantity = Map.from(cartCustomizationQuantity[foodId]!);
    }

    // Load existing add-ons
    if (cartAddOnQuantity.containsKey(foodId)) {
      bsAddOnQuantity = Map.from(cartAddOnQuantity[foodId]!);
    }

    // For edit mode, load existing quantity (for items without customizations)
    if (cartFoodQuantity.containsKey(foodId)) {
      bsItemQuantity[foodId] = cartFoodQuantity[foodId]!;
    } else {
      bsItemQuantity[foodId] = 1;
    }
  }

  /// Reset bottom sheet state when closing
  void resetBottomSheetState() {
    selectedFoodItem = null;
    bsCustomizationQuantity.clear();
    bsAddOnQuantity.clear();
    bsItemQuantity.clear();
    isEditMode = false;
    editingFoodId = null;
    debugPrint('🔄 Reset bottom sheet state');
  }

  // ==================== SCENARIO A - BOTTOM SHEET ITEM QUANTITY ====================

  /// Get bottom sheet item quantity for Scenario A
  int getBottomSheetItemQuantity() {
    if (selectedFoodItem?.foodId == null) return 1;
    return bsItemQuantity[selectedFoodItem!.foodId!] ?? 1;
  }

  /// Increase bottom sheet item quantity for Scenario A
  void increaseBottomSheetItemQuantity() {
    if (selectedFoodItem?.foodId == null) return;

    final foodId = selectedFoodItem!.foodId!;
    final currentQty = getBottomSheetItemQuantity();
    bsItemQuantity[foodId] = currentQty + 1;

    debugPrint('🟢 Bottom sheet qty increased to: ${bsItemQuantity[foodId]}');
    update(['total_price']);
  }

  /// Decrease bottom sheet item quantity for Scenario A
  void decreaseBottomSheetItemQuantity() {
    if (selectedFoodItem?.foodId == null) return;

    final foodId = selectedFoodItem!.foodId!;
    final currentQty = getBottomSheetItemQuantity();

    if (currentQty > 1) {
      bsItemQuantity[foodId] = currentQty - 1;
      debugPrint('🟢 Bottom sheet qty decreased to: ${bsItemQuantity[foodId]}');
    } else {
      bsItemQuantity[foodId] = 1;
    }

    update(['total_price']);
  }

  // ==================== CUSTOMIZATION MANAGEMENT (BOTTOM SHEET) ====================

  void toggleCustomization(String customizationId) {
    if (selectedFoodItem?.foodId == null) return;

    final currentQty = bsCustomizationQuantity[customizationId] ?? 0;
    bsCustomizationQuantity[customizationId] = currentQty + 1;

    debugPrint('➕ Customization increased: $customizationId = ${bsCustomizationQuantity[customizationId]}');
    update(['customization_widget', 'bottom_sheet_content', 'total_price']);
  }

  void decreaseCustomization(String customizationId) {
    if (selectedFoodItem?.foodId == null) return;

    final currentQty = bsCustomizationQuantity[customizationId] ?? 0;

    if (currentQty > 0) {
      bsCustomizationQuantity[customizationId] = currentQty - 1;

      if (bsCustomizationQuantity[customizationId] == 0) {
        bsCustomizationQuantity.remove(customizationId);
      }

      debugPrint('➖ Customization decreased: $customizationId = ${bsCustomizationQuantity[customizationId] ?? 0}');

      // Auto-close if last customization removed (Scenario C with edit mode)
      if (bsCustomizationQuantity.isEmpty) {
        debugPrint('🔴 Last customization removed in edit mode, removing from cart and closing sheet');

        final foodId = selectedFoodItem!.foodId!;

        // Remove from cart if in edit mode
        if (isEditMode) {
          cartCustomizationQuantity.remove(foodId);
          cartAddOnQuantity.remove(foodId);
          debugPrint('🗑️ Removed item ${selectedFoodItem!.foodName} from cart');
        }

        Get.back();
        resetBottomSheetState();

        // Trigger UI update for food grid (to change edit icon back to add button)
        // and bottom cart bar (to update or hide if no items)
        update(['food_grid', 'bottom_cart_bar']);

        return;
      }

      update(['customization_widget', 'bottom_sheet_content', 'total_price']);
    }
  }

  int getCustomizationCount(String customizationId) {
    return bsCustomizationQuantity[customizationId] ?? 0;
  }

  int getTotalCustomizationQuantity() {
    int total = 0;
    bsCustomizationQuantity.forEach((_, qty) {
      total += qty;
    });
    return total;
  }

  // ==================== ADD-ON MANAGEMENT (BOTTOM SHEET) ====================

  void toggleAddOn(String addOnId) {
    if (selectedFoodItem?.foodId == null) return;

    final currentQty = bsAddOnQuantity[addOnId] ?? 0;
    bsAddOnQuantity[addOnId] = currentQty + 1;

    debugPrint('➕ Add-on increased: $addOnId = ${bsAddOnQuantity[addOnId]}');
    update(['addons_list', 'bottom_sheet_content', 'total_price']);
  }

  void decreaseAddOn(String addOnId) {
    if (selectedFoodItem?.foodId == null) return;

    final currentQty = bsAddOnQuantity[addOnId] ?? 0;

    if (currentQty > 0) {
      bsAddOnQuantity[addOnId] = currentQty - 1;

      if (bsAddOnQuantity[addOnId] == 0) {
        bsAddOnQuantity.remove(addOnId);
      }

      debugPrint('➖ Add-on decreased: $addOnId = ${bsAddOnQuantity[addOnId] ?? 0}');
      update(['addons_list', 'bottom_sheet_content', 'total_price']);
    }
  }

  int getAddOnCount(String addOnId) {
    return bsAddOnQuantity[addOnId] ?? 0;
  }

  // ==================== FOOD WIDGET QUANTITY (NO CUSTOMIZATIONS) ====================

  void increaseFoodQuantity(String foodId) {
    final currentQty = cartFoodQuantity[foodId] ?? 0;
    cartFoodQuantity[foodId] = currentQty + 1;

    debugPrint('➕ Food quantity increased: $foodId = ${cartFoodQuantity[foodId]}');
    update(['food_grid', 'bottom_cart_bar']);
  }

  void decreaseFoodQuantity(String foodId) {
    final currentQty = cartFoodQuantity[foodId] ?? 0;

    if (currentQty > 0) {
      cartFoodQuantity[foodId] = currentQty - 1;

      if (cartFoodQuantity[foodId] == 0) {
        cartFoodQuantity.remove(foodId);
      }

      debugPrint('➖ Food quantity decreased: $foodId = ${cartFoodQuantity[foodId] ?? 0}');
      update(['food_grid', 'bottom_cart_bar']);
    }
  }

  int getFoodQuantity(String foodId) {
    return cartFoodQuantity[foodId] ?? 0;
  }

  // ==================== PRICE CALCULATIONS ====================

  double getBasePrice() {
    if (selectedFoodItem == null) return 0;
    return (selectedFoodItem!.discountPrice ?? selectedFoodItem!.foodPrice ?? 0).toDouble();
  }

  double getAddOnsPrice() {
    double total = 0;
    bsAddOnQuantity.forEach((addOnId, qty) {
      final addOn = selectedFoodItem?.addOns?.firstWhere((a) => a.addOnId == addOnId, orElse: () => AddOn());
      if (addOn != null && addOn.addOnId != null) {
        total += (addOn.price ?? 0).toDouble() * qty;
      }
    });
    return total;
  }

  double getCustomizationPrice() {
    double total = 0;
    bsCustomizationQuantity.forEach((customId, qty) {
      final customization = selectedFoodItem?.customizations?.firstWhere(
        (c) => c.customizationId == customId,
        orElse: () => Customization(),
      );
      if (customization != null && customization.customizationId != null) {
        total += (customization.price ?? 0).toDouble() * qty;
      }
    });
    return total;
  }

  /// Calculate total price for bottom sheet button
  double getTotalBottomSheetPrice() {
    final basePrice = getBasePrice();
    final addOnsPrice = getAddOnsPrice();
    final customizationPrice = getCustomizationPrice();

    // If has customizations, use total customization quantity as multiplier
    if (selectedFoodItem?.customizations != null && selectedFoodItem!.customizations!.isNotEmpty) {
      int customQtyTotal = getTotalCustomizationQuantity();
      if (customQtyTotal == 0) return 0;
      return (basePrice * customQtyTotal) + addOnsPrice;
    }

    // For items without customizations (Scenario A), multiply by item quantity
    final itemQty = getBottomSheetItemQuantity();
    return (basePrice * itemQty) + addOnsPrice;
  }

  // ==================== ADD TO CART / UPDATE CART (FROM BOTTOM SHEET) ====================

  void addItemToCart() {
    if (selectedFoodItem?.foodId == null) return;

    final foodId = selectedFoodItem!.foodId!;
    final hasCustomizations = selectedFoodItem?.customizations != null && selectedFoodItem!.customizations!.isNotEmpty;

    if (hasCustomizations) {
      // For items with customizations: store customization and add-on quantities
      int customQtyTotal = getTotalCustomizationQuantity();
      if (customQtyTotal == 0) return; // Don't add if no customization selected

      if (isEditMode) {
        // EDIT MODE: Replace existing customizations and add-ons
        cartCustomizationQuantity[foodId] = Map.from(bsCustomizationQuantity);
        if (bsAddOnQuantity.isNotEmpty) {
          cartAddOnQuantity[foodId] = Map.from(bsAddOnQuantity);
        } else {
          cartAddOnQuantity.remove(foodId);
        }

        debugPrint('''
═══════════════════════════════════════════
✏️ UPDATE CART (WITH CUSTOMIZATIONS)
═══════════════════════════════════════════
🍔 Food: ${selectedFoodItem!.foodName}
🆔 Food ID: $foodId
📊 Customizations: $bsCustomizationQuantity
🎁 Add-ons: $bsAddOnQuantity
💵 Total Price: ₹${getTotalBottomSheetPrice()}
═══════════════════════════════════════════
        ''');
      } else {
        // ADD MODE: Add new item with customizations
        cartCustomizationQuantity[foodId] = Map.from(bsCustomizationQuantity);
        if (bsAddOnQuantity.isNotEmpty) {
          cartAddOnQuantity[foodId] = Map.from(bsAddOnQuantity);
        }

        debugPrint('''
═══════════════════════════════════════════
📦 ADD TO CART (WITH CUSTOMIZATIONS)
═══════════════════════════════════════════
🍔 Food: ${selectedFoodItem!.foodName}
🆔 Food ID: $foodId
📊 Customizations: $bsCustomizationQuantity
🎁 Add-ons: $bsAddOnQuantity
💵 Total Price: ₹${getTotalBottomSheetPrice()}
═══════════════════════════════════════════
        ''');
      }
    } else {
      // For items without customizations (Scenario A)
      final itemQty = getBottomSheetItemQuantity();

      if (isEditMode) {
        // EDIT MODE: Replace quantity and add-ons
        cartFoodQuantity[foodId] = itemQty;
        if (bsAddOnQuantity.isNotEmpty) {
          cartAddOnQuantity[foodId] = Map.from(bsAddOnQuantity);
        } else {
          cartAddOnQuantity.remove(foodId);
        }

        debugPrint('''
═══════════════════════════════════════════
✏️ UPDATE CART (WITHOUT CUSTOMIZATIONS)
═══════════════════════════════════════════
🍔 Food: ${selectedFoodItem!.foodName}
🆔 Food ID: $foodId
📊 Quantity: ${cartFoodQuantity[foodId]}
🎁 Add-ons: $bsAddOnQuantity
💵 Total Price: ₹${getTotalBottomSheetPrice()}
═══════════════════════════════════════════
        ''');
      } else {
        // ADD MODE: Add to existing quantity
        final currentQty = cartFoodQuantity[foodId] ?? 0;
        cartFoodQuantity[foodId] = currentQty + itemQty;

        if (bsAddOnQuantity.isNotEmpty) {
          cartAddOnQuantity[foodId] = Map.from(bsAddOnQuantity);
        }

        debugPrint('''
═══════════════════════════════════════════
📦 ADD TO CART (WITHOUT CUSTOMIZATIONS)
═══════════════════════════════════════════
🍔 Food: ${selectedFoodItem!.foodName}
🆔 Food ID: $foodId
📊 Quantity: ${cartFoodQuantity[foodId]}
🎁 Add-ons: $bsAddOnQuantity
💵 Total Price: ₹${getTotalBottomSheetPrice()}
═══════════════════════════════════════════
        ''');
      }
    }

    // Close bottom sheet and reset state
    Get.back();
    resetBottomSheetState();

    // Update UI
    update(['food_grid', 'bottom_cart_bar']);
  }

  // ==================== CART SUMMARY ====================

  int getTotalCartItemCount() {
    int total = 0;

    // Count food items without customizations
    cartFoodQuantity.forEach((_, qty) {
      total += qty;
    });

    // Count customization items
    cartCustomizationQuantity.forEach((_, customMap) {
      customMap.forEach((_, qty) {
        total += qty;
      });
    });

    return total;
  }

  double getTotalCartPrice() {
    double total = 0;

    // Price from food without customizations + their add-ons
    cartFoodQuantity.forEach((foodId, qty) {
      final food = _getFoodById(foodId);
      if (food != null) {
        final basePrice = (food.discountPrice ?? food.foodPrice ?? 0).toDouble();
        total += basePrice * qty;

        // Add add-on prices for this food
        if (cartAddOnQuantity.containsKey(foodId)) {
          cartAddOnQuantity[foodId]!.forEach((addOnId, addOnQty) {
            final addOn = food.addOns?.firstWhere((a) => a.addOnId == addOnId, orElse: () => AddOn());
            if (addOn != null && addOn.addOnId != null) {
              total += (addOn.price ?? 0).toDouble() * addOnQty;
            }
          });
        }
      }
    });

    // Price from customized items
    cartCustomizationQuantity.forEach((foodId, customMap) {
      final food = _getFoodById(foodId);
      if (food != null) {
        final basePrice = (food.discountPrice ?? food.foodPrice ?? 0).toDouble();

        customMap.forEach((customId, customQty) {
          total += basePrice * customQty;
        });

        // Add add-on prices for this customized food
        if (cartAddOnQuantity.containsKey(foodId)) {
          cartAddOnQuantity[foodId]!.forEach((addOnId, addOnQty) {
            final addOn = food.addOns?.firstWhere((a) => a.addOnId == addOnId, orElse: () => AddOn());
            if (addOn != null && addOn.addOnId != null) {
              total += (addOn.price ?? 0).toDouble() * addOnQty;
            }
          });
        }
      }
    });

    return total;
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

  // ==================== GETTERS ====================

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

  /// Check if food item is in cart
  bool isFoodInCart(String foodId) {
    return cartFoodQuantity.containsKey(foodId) || cartCustomizationQuantity.containsKey(foodId);
  }

  /// Get button text based on edit mode
  String getBottomSheetButtonText() {
    return isEditMode ? 'Edit Item' : 'Add Item';
  }

  // ==================== CART LOGGING METHODS ====================

  /// Get complete cart details with food items, customizations, and add-ons
  Map<String, dynamic> getCartDetails() {
    final cartDetails = <String, dynamic>{};

    // Items without customizations
    cartDetails['items_without_customizations'] = [];
    cartFoodQuantity.forEach((foodId, qty) {
      final food = _getFoodById(foodId);
      if (food != null) {
        final addOnsList = <Map<String, dynamic>>[];

        final itemData = {
          'foodId': foodId,
          'foodName': food.foodName,
          'quantity': qty,
          'basePrice': (food.discountPrice ?? food.foodPrice ?? 0),
          'totalPrice': (food.discountPrice ?? food.foodPrice ?? 0) * qty,
          'addOns': addOnsList,
        };

        // Add add-ons for this food if any
        if (cartAddOnQuantity.containsKey(foodId)) {
          cartAddOnQuantity[foodId]!.forEach((addOnId, addOnQty) {
            final addOn = food.addOns?.firstWhere((a) => a.addOnId == addOnId, orElse: () => AddOn());
            if (addOn != null && addOn.addOnId != null) {
              addOnsList.add({
                'addOnId': addOnId,
                'addOnName': addOn.name,
                'quantity': addOnQty,
                'price': addOn.price,
                'totalPrice': (addOn.price ?? 0) * addOnQty,
              });
            }
          });
        }

        (cartDetails['items_without_customizations'] as List).add(itemData);
      }
    });

    // Items with customizations
    cartDetails['items_with_customizations'] = [];
    cartCustomizationQuantity.forEach((foodId, customMap) {
      final food = _getFoodById(foodId);
      if (food != null) {
        final customizationsList = <Map<String, dynamic>>[];
        final addOnsList = <Map<String, dynamic>>[];

        customMap.forEach((customId, customQty) {
          final customization = food.customizations?.firstWhere(
            (c) => c.customizationId == customId,
            orElse: () => Customization(),
          );
          if (customization != null && customization.customizationId != null) {
            customizationsList.add({
              'customizationId': customId,
              'customizationName': customization.name,
              'quantity': customQty,
              'price': customization.price,
              'totalPrice': (customization.price ?? 0) * customQty,
            });
          }
        });

        final itemData = {
          'foodId': foodId,
          'foodName': food.foodName,
          'basePrice': (food.discountPrice ?? food.foodPrice ?? 0),
          'customizations': customizationsList,
          'addOns': addOnsList,
        };

        // Calculate total price for customized items
        double totalCustomizationQuantity = 0;
        customMap.forEach((_, customQty) {
          totalCustomizationQuantity += customQty;
        });
        itemData['totalCustomizationQuantity'] = totalCustomizationQuantity.toInt();
        itemData['totalPrice'] = ((food.discountPrice ?? food.foodPrice ?? 0) * totalCustomizationQuantity);

        // Add add-ons for this customized food if any
        if (cartAddOnQuantity.containsKey(foodId)) {
          cartAddOnQuantity[foodId]!.forEach((addOnId, addOnQty) {
            final addOn = food.addOns?.firstWhere((a) => a.addOnId == addOnId, orElse: () => AddOn());
            if (addOn != null && addOn.addOnId != null) {
              addOnsList.add({
                'addOnId': addOnId,
                'addOnName': addOn.name,
                'quantity': addOnQty,
                'price': addOn.price,
                'totalPrice': (addOn.price ?? 0) * addOnQty,
              });
            }
          });
        }

        (cartDetails['items_with_customizations'] as List).add(itemData);
      }
    });

    cartDetails['total_items'] = getTotalCartItemCount();
    cartDetails['total_price'] = getTotalCartPrice();

    return cartDetails;
  }

  /// Log cart details in a formatted way
  void logCartDetails() {
    final cartData = getCartDetails();

    debugPrint('''
╔════════════════════════════════════════════════════════════════════════════╗
║                          🛒 COMPLETE CART DETAILS                          ║
╚════════════════════════════════════════════════════════════════════════════╝
    ''');

    // Log items without customizations
    if ((cartData['items_without_customizations'] as List).isNotEmpty) {
      debugPrint('📦 ITEMS WITHOUT CUSTOMIZATIONS:');
      debugPrint('─────────────────────────────────────────────────────────────────────────────');
      for (var item in cartData['items_without_customizations'] as List) {
        debugPrint('  🍔 ${item['foodName']}');
        debugPrint('     └─ Food ID: ${item['foodId']}');
        debugPrint('     └─ Quantity: ${item['quantity']}');
        debugPrint('     └─ Base Price: ₹${item['basePrice']}');
        debugPrint('     └─ Item Total: ₹${item['totalPrice']}');

        if ((item['addOns'] as List).isNotEmpty) {
          debugPrint('     └─ Add-ons:');
          for (var addOn in item['addOns'] as List) {
            debugPrint('        ├─ ${addOn['addOnName']} (Qty: ${addOn['quantity']}) - ₹${addOn['totalPrice']}');
          }
        }
        debugPrint('');
      }
    }

    // Log items with customizations
    if ((cartData['items_with_customizations'] as List).isNotEmpty) {
      debugPrint('🎨 ITEMS WITH CUSTOMIZATIONS:');
      debugPrint('─────────────────────────────────────────────────────────────────────────────');
      for (var item in cartData['items_with_customizations'] as List) {
        debugPrint('  🍔 ${item['foodName']}');
        debugPrint('     └─ Food ID: ${item['foodId']}');
        debugPrint('     └─ Base Price: ₹${item['basePrice']}');
        debugPrint('     └─ Total Customization Quantity: ${item['totalCustomizationQuantity']}');
        debugPrint('     └─ Customizations:');

        for (var custom in item['customizations'] as List) {
          debugPrint(
            '        ├─ ${custom['customizationName']} (Qty: ${custom['quantity']}) - ₹${custom['totalPrice']}',
          );
        }

        if ((item['addOns'] as List).isNotEmpty) {
          debugPrint('     └─ Add-ons:');
          for (var addOn in item['addOns'] as List) {
            debugPrint('        ├─ ${addOn['addOnName']} (Qty: ${addOn['quantity']}) - ₹${addOn['totalPrice']}');
          }
        }

        debugPrint('     └─ Item Total: ₹${item['totalPrice']}');
        debugPrint('');
      }
    }

    debugPrint('╔════════════════════════════════════════════════════════════════════════════╗');
    debugPrint('║ 📊 CART SUMMARY                                                            ║');
    debugPrint('╠════════════════════════════════════════════════════════════════════════════╣');
    debugPrint(
      '║ Total Items: ${cartData['total_items']}                                                              ║',
    );
    debugPrint(
      '║ Total Price: ₹${cartData['total_price']}                                                            ║',
    );
    debugPrint(
      '╚════════════════════════════════════════════════════════════════════════════╝'
      '',
    );
  }

  /// Alternative: Get cart as JSON (for API calls)
  String getCartDetailsAsJson() {
    return jsonEncode(getCartDetails());
  }
}
