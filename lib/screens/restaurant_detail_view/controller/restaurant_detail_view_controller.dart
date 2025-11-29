import 'dart:async';

import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../cart/controller/cart_service.dart';
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

  final RxMap<String, int> cartFoodQuantity = <String, int>{}.obs;
  final RxMap<String, Map<String, int>> cartCustomizationQuantity = <String, Map<String, int>>{}.obs;
  final RxMap<String, Map<String, int>> cartAddOnQuantity = <String, Map<String, int>>{}.obs;

  Map<String, dynamic>? lastCartItemResponse;
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  Food? selectedFoodItem;
  Map<String, int> bsCustomizationQuantity = {};
  Map<String, int> bsAddOnQuantity = {};
  Map<String, int> bsItemQuantity = {};

  bool isEditMode = false;
  String? editingFoodId;
  String? restaurantId;

  Timer? _quantityDebounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  DateTime _lastLocalApiUpdate = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    _extractRestaurantIdAndFetch();
    _setupExternalCartSyncListener();
  }

  @override
  void onClose() {
    _quantityDebounceTimer?.cancel();
    super.onClose();
  }

  void _setupExternalCartSyncListener() {
    final cartService = Get.find<CartService>();

    ever(cartService.cartItems, (_) {
      final timeSinceLastUpdate = DateTime.now().difference(_lastLocalApiUpdate);

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

        final hasCustomizations = item['customizations'] != null && (item['customizations'] as List).isNotEmpty;

        if (!hasCustomizations) {
          cartFoodQuantity[foodId] = item['quantity'] ?? 0;

          if (item['addOns'] != null && (item['addOns'] as List).isNotEmpty) {
            cartAddOnQuantity[foodId] = {};
            for (var addOn in item['addOns'] as List) {
              cartAddOnQuantity[foodId]![addOn['addOnId']] = addOn['quantity'] ?? 0;
            }
          }
        } else {
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

      lastCartItemResponse = {
        'items': cartService.cartItems.toList(),
        'totals': {'itemCount': cartService.itemCount.value, 'grandTotal': cartService.totalPrice.value},
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
        endpoint: "${Urls.getRestaurantDetailsUrl}$restaurantId/foods?service=$serviceType",
      );

      if (response != null && response is Map<String, dynamic>) {
        restaurantDetailsModel = RestuarantDetailsModel.fromJson(response);

        if (restaurantDetailsModel?.status == true && restaurantDetailsModel?.data != null) {
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
          errorMessage = restaurantDetailsModel?.message ?? 'Failed to load restaurant details';
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

              if (hasCustomizations) {
                List<Map<String, dynamic>> customizationsList = [];

                for (var customization in food.customizations!) {
                  if (customization.cartCount != null && customization.cartCount! > 0) {
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
                    cartAddOnQuantity[foodId]![addOn.addOnId!] = addOn.cartCount!.toInt();

                    totalPrice += (addOn.price ?? 0).toDouble() * addOn.cartCount!;
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
          final addOnId = addOn['addOnId'] ?? '';
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
          final customId = customization['customizationId'] ?? '';
          final customQty = customization['quantity'] ?? 0;
          if (customId.isNotEmpty) {
            bsCustomizationQuantity[customId] = customQty;
          }
        }
      }

      if (currentCartItem['addOns'] != null) {
        final addOns = currentCartItem['addOns'] as List;
        for (var addOn in addOns) {
          final addOnId = addOn['addOnId'] ?? '';
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

      update(['customization_widget', 'addons_list', 'bottom_sheet_content', 'total_price']);
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
    }
  }

  int getAddOnCount(String addOnId) {
    return bsAddOnQuantity[addOnId] ?? 0;
  }

  void increaseScenario1Quantity(String foodId) {
    final currentQty = cartFoodQuantity[foodId] ?? 0;
    cartFoodQuantity[foodId] = currentQty + 1;

    _debouncedUpdateQuantity(foodId, cartFoodQuantity[foodId]!);
  }

  void decreaseScenario1Quantity(String foodId) {
    final currentQty = cartFoodQuantity[foodId] ?? 0;

    if (currentQty > 1) {
      cartFoodQuantity[foodId] = currentQty - 1;
      _debouncedUpdateQuantity(foodId, cartFoodQuantity[foodId]!);
    } else if (currentQty == 1) {
      cartFoodQuantity.remove(foodId);
      _callScenario1UpdateQuantityApi(foodId, 0);
    }
  }

  void _debouncedUpdateQuantity(String foodId, int quantity) {
    _quantityDebounceTimer?.cancel();
    _quantityDebounceTimer = Timer(_debounceDuration, () {
      _callScenario1UpdateQuantityApi(foodId, quantity);
    });
  }

  Future<void> _callScenario1UpdateQuantityApi(String foodId, int quantity) async {
    try {
      _lastLocalApiUpdate = DateTime.now();

      final requestBody = {
        'foodId': foodId,
        'quantity': quantity,
        'serviceType': _getCleanServiceType(Store.deliveryPreference),
      };

      final response = await _apiClient.post(endpoint: Urls.addOrUpdateCartUrl, data: requestBody);

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          final cartData = response['data'];

          _mergeScenario1Update(cartData, updatingFoodId: foodId, quantity: quantity);

          final cartService = Get.find<CartService>();
          cartService.updateCartFromApi(cartData);
        } else {
          _revertScenario1Change(foodId);
          Get.snackbar('Error', response['message'] ?? 'Failed to update quantity');
        }
      }
    } catch (e) {
      _revertScenario1Change(foodId);
      Get.snackbar('Error', 'Failed to update quantity');
    }
  }

  void _mergeScenario1Update(Map<String, dynamic> cartData, {required String updatingFoodId, required int quantity}) {
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

        if (itemInResponse['addOns'] != null && (itemInResponse['addOns'] as List).isNotEmpty) {
          cartAddOnQuantity[updatingFoodId] = {};
          for (var addOn in itemInResponse['addOns'] as List) {
            cartAddOnQuantity[updatingFoodId]![addOn['addOnId']] = addOn['quantity'] ?? 0;
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
  }

  Future<void> addOrUpdateItemToCart() async {
    if (selectedFoodItem?.foodId == null) return;

    try {
      final foodId = selectedFoodItem!.foodId!;
      final hasCustomizations = _isScenario3And4(selectedFoodItem!);
      final hasAddOns = selectedFoodItem?.addOns != null && selectedFoodItem!.addOns!.isNotEmpty;

      // if (isEditMode && hasCustomizations && getTotalCustomizationQuantity() == 0) {
      //   await _callRemoveItemWithQtyZero(foodId);
      //   return;
      // }

      final requestBody = _buildAddToCartRequestBody();

      if (requestBody == null) {
        return;
      }

      final response = await _apiClient.post(endpoint: Urls.addOrUpdateCartUrl, data: requestBody);

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          final cartData = response['data'];

          if (!hasCustomizations && !hasAddOns) {
            _mergeScenario1Update(cartData, updatingFoodId: foodId, quantity: getBottomSheetItemQuantity());
          } else {
            _updateCartFromApiResponse(cartData);
          }

          final cartService = Get.find<CartService>();
          cartService.updateCartFromApi(cartData);

          resetBottomSheetState();
          Navigator.pop(Get.context!);
        } else {
          Get.snackbar('Error', response['message'] ?? 'Failed to add item to cart');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add item to cart');
    }
  }

  Future<void> _callRemoveItemWithQtyZero(String foodId) async {
    try {
      final requestBody = _buildRemoveItemRequestBody(foodId);

      final response = await _apiClient.post(endpoint: Urls.addOrUpdateCartUrl, data: requestBody);

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          final cartData = response['data'];
          _updateCartFromApiResponse(cartData);

          final cartService = Get.find<CartService>();
          cartService.updateCartFromApi(cartData);

          resetBottomSheetState();
          Navigator.pop(Get.context!);
        } else {
          _showSafeSnackbar('Error', response['message'] ?? 'Failed to remove item');
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
        bsCustomizationQuantity.isNotEmpty && bsCustomizationQuantity.values.any((qty) => qty > 0);

    final foodQuantity = hasCustomizations ? 1 : 0;

    final requestBody = {'foodId': foodId, 'quantity': foodQuantity, 'serviceType': serviceType};

    if (!hasCustomizations) {
      if (bsAddOnQuantity.isNotEmpty) {
        final addOnsToSend = bsAddOnQuantity.entries.map((e) => {'addOnId': e.key, 'quantity': e.value}).toList();

        if (addOnsToSend.isNotEmpty) {
          requestBody['addOns'] = addOnsToSend;
        }
      }
    } else {
      if (bsCustomizationQuantity.isNotEmpty) {
        final customizationsToSend =
            bsCustomizationQuantity.entries.map((e) => {'customizationId': e.key, 'quantity': e.value}).toList();

        if (customizationsToSend.isNotEmpty) {
          requestBody['customizations'] = customizationsToSend;
        }
      }

      if (bsAddOnQuantity.isNotEmpty) {
        final addOnsToSend = bsAddOnQuantity.entries.map((e) => {'addOnId': e.key, 'quantity': e.value}).toList();

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

        final hasCustomizations = item['customizations'] != null && (item['customizations'] as List).isNotEmpty;

        if (!hasCustomizations) {
          cartFoodQuantity[foodId] = item['quantity'] ?? 1;

          if (item['addOns'] != null && (item['addOns'] as List).isNotEmpty) {
            cartAddOnQuantity[foodId] = {};
            for (var addOn in item['addOns'] as List) {
              cartAddOnQuantity[foodId]![addOn['addOnId']] = addOn['quantity'] ?? 0;
            }
          }
        } else {
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
      // ✅ SCENARIO 1 & 2: Food without customizations
      final quantity = getBottomSheetItemQuantity();
      final requestBody = {'foodId': foodId, 'quantity': quantity, 'serviceType': serviceType};

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
      // ✅ SCENARIO 3 & 4: Food with customizations
      // Always send quantity: 1 for customization scenarios
      final requestBody = {'foodId': foodId, 'quantity': 1, 'serviceType': serviceType};

      // ✅ CRITICAL FIX: Always send customizations array in edit mode
      // Even if ALL customizations are zero (user removed everything)
      // This tells the API to update/remove all customizations
      if (bsCustomizationQuantity.isNotEmpty) {
        final customizationsToSend =
            isEditMode
                ? bsCustomizationQuantity.entries.map((e) => {'customizationId': e.key, 'quantity': e.value}).toList()
                : bsCustomizationQuantity.entries
                    .where((e) => e.value > 0)
                    .map((e) => {'customizationId': e.key, 'quantity': e.value})
                    .toList();

        // ✅ IMPORTANT: Send customizations if:
        // - Add mode: At least one customization selected (qty > 0)
        // - Edit mode: ALWAYS send (even if all are zero)
        if (customizationsToSend.isNotEmpty || isEditMode) {
          requestBody['customizations'] = customizationsToSend;
        }
      }

      // ✅ Send add-ons with same logic as customizations
      if (bsAddOnQuantity.isNotEmpty) {
        final addOnsToSend =
            isEditMode
                ? bsAddOnQuantity.entries.map((e) => {'addOnId': e.key, 'quantity': e.value}).toList()
                : bsAddOnQuantity.entries
                    .where((e) => e.value > 0)
                    .map((e) => {'addOnId': e.key, 'quantity': e.value})
                    .toList();

        // ✅ IMPORTANT: Send add-ons if:
        // - Add mode: At least one add-on selected (qty > 0)
        // - Edit mode: ALWAYS send (even if all are zero)
        if (addOnsToSend.isNotEmpty || isEditMode) {
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

  double getTotalBottomSheetPrice() {
    final basePrice = getBasePrice();
    final addOnsPrice = getAddOnsPrice();
    final customizationPrice = getCustomizationPrice();

    if (selectedFoodItem?.customizations != null && selectedFoodItem!.customizations!.isNotEmpty) {
      int customQtyTotal = getTotalCustomizationQuantity();
      if (customQtyTotal == 0) return 0;
      return customizationPrice + addOnsPrice;
    }

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
    return cartFoodQuantity.containsKey(foodId) && cartFoodQuantity[foodId]! > 0;
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
