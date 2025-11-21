import 'dart:developer';

import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/routes/routes.dart';
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

  // Selected food item for bottom sheet
  Food? selectedFoodItem;
  Map<String, int> foodCustomizationCount = {}; // Track quantity/customization counts per food
  Map<String, List<AddOn>> foodSelectedAddOns = {}; // Track selected add-ons per food

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

      // RESET STATE WHEN FRESH API CALL
      resetAllSelections();

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

          // Initialize food tracking maps
          _initializeFoodTrackingMaps();

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
    // Remove emoji and extra spaces, keep only the service type
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

    // Default to delivery if unknown
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

  void _initializeFoodTrackingMaps() {
    // Clear existing maps
    foodCustomizationCount.clear();
    foodSelectedAddOns.clear();

    for (var categoryData in restaurantData) {
      if (categoryData.foods != null) {
        for (var food in categoryData.foods!) {
          if (food.foodId != null) {
            // Initialize quantity count map for each food (starts at 0)
            foodCustomizationCount[food.foodId!] = 0;
            // Initialize selected add-ons list
            foodSelectedAddOns[food.foodId!] = [];
          }
        }
      }
    }
  }

  // Category management
  void onCategoryTapped(int index) {
    if (selectedCategoryIndex != index) {
      selectedCategoryIndex = index;
      // Reset food selection when switching categories
      selectedFoodItem = null;
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

  // Food item selection for bottom sheet
  void selectFoodItem(Food foodItem) {
    if (foodItem.foodId == null) return;

    selectedFoodItem = foodItem;

    // If this food hasn't been initialized yet, initialize it
    if (!foodCustomizationCount.containsKey(foodItem.foodId!)) {
      foodCustomizationCount[foodItem.foodId!] = 0;
      foodSelectedAddOns[foodItem.foodId!] = [];
    }

    // Start with quantity 1 when selecting a food
    foodCustomizationCount[foodItem.foodId!] = 1;

    // Keep existing add-ons if they exist, don't reset them
    // This allows persistence across navigation

    debugPrint('🍔 Selected food: ${foodItem.foodName} (ID: ${foodItem.foodId})');
    update(['bottom_sheet_content', 'food_quantity_widget', 'total_price']);
  }

  // Customization management (now handles quantity for all food types)
  void toggleCustomization(String customizationId) {
    if (selectedFoodItem?.foodId == null) return;

    final foodId = selectedFoodItem!.foodId!;
    final currentCount = foodCustomizationCount[foodId] ?? 1;

    // Increment quantity
    foodCustomizationCount[foodId] = currentCount + 1;

    debugPrint('➕ Quantity increased: ${foodCustomizationCount[foodId]}');
    update(['customization_widget', 'total_price', 'bottom_sheet_content', 'food_quantity_widget']);
  }

  void decreaseCustomization() {
    if (selectedFoodItem?.foodId == null) return;

    final foodId = selectedFoodItem!.foodId!;
    final currentCount = foodCustomizationCount[foodId] ?? 1;

    if (currentCount > 1) {
      foodCustomizationCount[foodId] = currentCount - 1;
      debugPrint('➖ Quantity decreased: ${foodCustomizationCount[foodId]}');
      update(['customization_widget', 'total_price', 'bottom_sheet_content', 'food_quantity_widget']);
    }
  }

  int getCustomizationCount(String foodId) {
    return foodCustomizationCount[foodId] ?? 0;
  }

  // Add-on management (global, doesn't multiply)
  void toggleAddOn(String addOnId) {
    if (selectedFoodItem?.foodId == null) return;

    final foodId = selectedFoodItem!.foodId!;
    final selectedAddOns = foodSelectedAddOns[foodId] ?? [];

    // Find the add-on in the current food
    final addOn = selectedFoodItem!.addOns?.firstWhere((addon) => addon.addOnId == addOnId, orElse: () => AddOn());

    if (addOn != null && addOn.addOnId != null) {
      // Check if already selected
      final alreadySelected = selectedAddOns.any((a) => a.addOnId == addOnId);

      if (alreadySelected) {
        selectedAddOns.removeWhere((a) => a.addOnId == addOnId);
        debugPrint('❌ Removed add-on: ${addOn.name}');
      } else {
        selectedAddOns.add(addOn);
        debugPrint('✅ Added add-on: ${addOn.name}');
      }

      foodSelectedAddOns[foodId] = selectedAddOns;
      update(['addons_list', 'total_price', 'bottom_sheet_content']);
    }
  }

  List<AddOn> getSelectedAddOns(String foodId) {
    return foodSelectedAddOns[foodId] ?? [];
  }

  bool isAddOnSelected(String addOnId) {
    if (selectedFoodItem?.foodId == null) return false;

    final selectedAddOns = getSelectedAddOns(selectedFoodItem!.foodId!);
    return selectedAddOns.any((addon) => addon.addOnId == addOnId);
  }

  // Price calculations: (base price * quantity) + add-ons price
  double getTotalPrice() {
    if (selectedFoodItem == null || selectedFoodItem!.foodId == null) return 0;

    final foodId = selectedFoodItem!.foodId!;
    final quantity = getCustomizationCount(foodId);
    final selectedAddOns = getSelectedAddOns(foodId);

    // Base food price (use discount price if available, otherwise use food price)
    double basePrice = (selectedFoodItem!.discountPrice ?? selectedFoodItem!.foodPrice ?? 0).toDouble();

    // Add-ons cost (global, doesn't multiply with quantity)
    double addOnsPrice = 0;
    for (var addOn in selectedAddOns) {
      addOnsPrice += (addOn.price ?? 0).toDouble();
    }

    // Total: (base price * quantity) + add-ons price
    return (basePrice * quantity) + addOnsPrice;
  }

  double getBasePrice() {
    if (selectedFoodItem == null) return 0;
    return (selectedFoodItem!.discountPrice ?? selectedFoodItem!.foodPrice ?? 0).toDouble();
  }

  double getAddOnsPrice() {
    if (selectedFoodItem?.foodId == null) return 0;

    final selectedAddOns = getSelectedAddOns(selectedFoodItem!.foodId!);
    double totalAddOnsPrice = 0;
    for (var addOn in selectedAddOns) {
      totalAddOnsPrice += (addOn.price ?? 0).toDouble();
    }
    return totalAddOnsPrice;
  }

  // Navigate to food detail page
  void navigateToFoodDetail(Food foodItem) {
    if (foodItem.foodId == null || foodItem.foodName == null || foodItem.foodImage == null) {
      debugPrint('❌ Invalid food item for navigation');
      return;
    }

    Get.toNamed(
      Routes.foodDetailsView,
      arguments: {
        'foodName': foodItem.foodName,
        'foodImage': foodItem.foodImage,
        'foodId': foodItem.foodId,
        'foodPrice': foodItem.foodPrice,
        'discountPrice': foodItem.discountPrice,
        'actualPrice': foodItem.actualPrice,
        'customizations': foodItem.customizations,
        'addOns': foodItem.addOns,
      },
    );
  }

  // Log selected items when adding to cart (from bottom sheet)
  void logAndAddToCartFromBottomSheet() {
    if (selectedFoodItem == null || selectedFoodItem!.foodId == null) return;

    final foodId = selectedFoodItem!.foodId!;
    final quantity = getCustomizationCount(foodId);
    final selectedAddOns = getSelectedAddOns(foodId);
    final totalPrice = getTotalPrice();

    debugPrint('''
═══════════════════════════════════════════
📦 ADD TO CART FROM BOTTOM SHEET
═══════════════════════════════════════════
🍔 Food: ${selectedFoodItem!.foodName}
🆔 Food ID: $foodId
📊 Quantity: $quantity
💰 Base Price: ₹${getBasePrice()}
🎁 Add-ons: ${selectedAddOns.map((a) => '${a.name} (₹${a.price})').join(', ')}
🆔 Add-on IDs: ${selectedAddOns.map((a) => a.addOnId).join(', ')}
📈 Add-ons Total: ₹${getAddOnsPrice()}
💵 Total Price: ₹$totalPrice
═══════════════════════════════════════════
    ''');
  }

  // Log selected items when adding to cart (from food details page)
  void logAndAddToCartFromFoodDetails() {
    if (selectedFoodItem == null || selectedFoodItem!.foodId == null) return;

    final foodId = selectedFoodItem!.foodId!;
    final quantity = getCustomizationCount(foodId);
    final selectedAddOns = getSelectedAddOns(foodId);
    final totalPrice = getTotalPrice();

    debugPrint('''
═══════════════════════════════════════════
📦 ADD TO CART FROM FOOD DETAILS
═══════════════════════════════════════════
🍔 Food: ${selectedFoodItem!.foodName}
🆔 Food ID: $foodId
📊 Quantity: $quantity
💰 Base Price: ₹${getBasePrice()}
🎁 Add-ons: ${selectedAddOns.map((a) => '${a.name} (₹${a.price})').join(', ')}
🆔 Add-on IDs: ${selectedAddOns.map((a) => a.addOnId).join(', ')}
📈 Add-ons Total: ₹${getAddOnsPrice()}
💵 Total Price: ₹$totalPrice
═══════════════════════════════════════════
    ''');
  }

  // Reset selections for a specific food
  void resetFoodSelections(String foodId) {
    foodCustomizationCount[foodId] = 0;
    foodSelectedAddOns[foodId] = [];
    debugPrint('🔄 Reset selections for food: $foodId');
  }

  // Reset all selections ONLY when:
  // 1. Fresh API call (new restaurant)
  // 2. Completely exiting the restaurant view
  void resetAllSelections() {
    selectedFoodItem = null;
    foodCustomizationCount.clear();
    foodSelectedAddOns.clear();
    selectedCategoryIndex = 0;
    debugPrint('🔄 Reset all selections');
    update(['main_content', 'bottom_sheet_content']);
  }

  // Getters
  String get selectedCategoryName => selectedCategoryIndex < categories.length ? categories[selectedCategoryIndex] : '';
  int get foodItemsCount => getFilteredFoodItems().length;
  bool get hasCustomizations =>
      selectedFoodItem?.customizations != null && selectedFoodItem!.customizations!.isNotEmpty;
  bool get hasAddOns => selectedFoodItem?.addOns != null && selectedFoodItem!.addOns!.isNotEmpty;

  @override
  void onClose() {
    resetAllSelections();
    super.onClose();
  }
}
