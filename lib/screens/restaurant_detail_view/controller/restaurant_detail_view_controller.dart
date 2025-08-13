import 'package:eatplek_app/core/routes/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../model/food_add_on_model.dart';

class RestaurantDetailViewController extends GetxController {
  // Category management
  int selectedCategoryIndex = 0;
  List<String> categories = ['Burger', 'Pizza', 'Pasta', 'Dessert', 'Drinks', 'Salad', 'Chicken', 'Seafood'];

  // Food items and filtering
  List<FoodItem> allFoodItems = [];
  List<FoodItem> filteredFoodItems = [];

  // Bottom sheet management
  FoodItem? selectedFoodItem;
  List<AddOn> availableAddOns = [];
  int currentQuantity = 1;

  @override
  void onInit() {
    super.onInit();
    _initializeMockData();
    filterFoodByCategory(categories[selectedCategoryIndex]);
  }

  // Initialize mock data
  void _initializeMockData() {
    allFoodItems = [
      FoodItem(
        id: '1',
        name: 'Classic Chicken Burger',
        price: 120,
        originalPrice: 180,
        imageUrl: 'https://picsum.photos/250?image=30',
        category: 'Burger',
        description: 'Juicy chicken patty with fresh lettuce, tomato, and our special sauce',
      ),
      FoodItem(
        id: '2',
        name: 'Margherita Pizza',
        price: 200,
        originalPrice: 250,
        imageUrl: 'https://picsum.photos/250?image=31',
        category: 'Pizza',
        description: 'Classic Italian pizza with fresh mozzarella and basil',
      ),
      FoodItem(
        id: '3',
        name: 'Chicken Alfredo Pasta',
        price: 180,
        originalPrice: 220,
        imageUrl: 'https://picsum.photos/250?image=32',
        category: 'Pasta',
        description: 'Creamy alfredo sauce with grilled chicken and pasta',
      ),
      FoodItem(
        id: '4',
        name: 'Chocolate Brownie',
        price: 80,
        originalPrice: 100,
        imageUrl: 'https://picsum.photos/250?image=33',
        category: 'Dessert',
        description: 'Rich chocolate brownie with vanilla ice cream',
      ),
      FoodItem(
        id: '5',
        name: 'Fresh Orange Juice',
        price: 60,
        originalPrice: 80,
        imageUrl: 'https://picsum.photos/250?image=34',
        category: 'Drinks',
        description: 'Freshly squeezed orange juice',
      ),
      // Add more items for other categories...
    ];

    availableAddOns = [
      AddOn(id: '1', name: 'Extra Cheese', price: 30, imageUrl: 'https://picsum.photos/250?image=40'),
      AddOn(id: '2', name: 'Bacon', price: 50, imageUrl: 'https://picsum.photos/250?image=41'),
      AddOn(id: '3', name: 'Mushrooms', price: 25, imageUrl: 'https://picsum.photos/250?image=42'),
      AddOn(id: '4', name: 'Jalapenos', price: 20, imageUrl: 'https://picsum.photos/250?image=43'),
      AddOn(id: '5', name: 'Onion Rings', price: 40, imageUrl: 'https://picsum.photos/250?image=44'),
    ];
  }

  // Category management
  void onCategoryTapped(int index) {
    if (selectedCategoryIndex != index) {
      selectedCategoryIndex = index;
      update(['category_tabs']);
      filterFoodByCategory(categories[index]);
    }
  }

  void filterFoodByCategory(String category) {
    filteredFoodItems = allFoodItems.where((food) => food.category.toLowerCase() == category.toLowerCase()).toList();
    update(['food_grid']);
  }

  // Food item selection for bottom sheet
  void selectFoodItem(FoodItem foodItem) {
    selectedFoodItem = foodItem;
    currentQuantity = 1;
    // Reset add-ons selection
    for (var addOn in availableAddOns) {
      addOn.isSelected = false;
    }
    update(['bottom_sheet_content']);
  }

  // Quantity management
  void increaseQuantity() {
    currentQuantity++;
    update(['quantity_controls', 'total_price']);
  }

  void decreaseQuantity() {
    if (currentQuantity > 1) {
      currentQuantity--;
      update(['quantity_controls', 'total_price']);
    } else {
      // Close bottom sheet when quantity becomes 0
      Get.back();
    }
  }

  // Add-on management
  void toggleAddOn(String addOnId) {
    final addOn = availableAddOns.firstWhere((addon) => addon.id == addOnId);
    addOn.isSelected = !addOn.isSelected;
    update(['addon_$addOnId', 'total_price']);
  }

  // Price calculations
  double get selectedAddOnsPrice {
    return availableAddOns.where((addOn) => addOn.isSelected).fold(0, (sum, addOn) => sum + addOn.price);
  }

  double get totalPrice {
    if (selectedFoodItem == null) return 0;
    return (selectedFoodItem!.price + selectedAddOnsPrice) * currentQuantity;
  }

  List<AddOn> get selectedAddOns {
    return availableAddOns.where((addOn) => addOn.isSelected).toList();
  }

  // Navigation methods
  void navigateToFoodDetail(FoodItem foodItem) {
    Get.toNamed(
      Routes.foodDetailsView,
      //  arguments: foodItem
    );
  }

  void navigateToCart() {
    Get.toNamed(Routes.cartView);
    debugPrint('Navigate to cart screen');
    Get.back();
  }

  // Add to cart functionality
  void addToCart() {
    if (selectedFoodItem != null) {
      // Here you would typically add to cart controller
      // For now, just print the selection
      debugPrint('Adding to cart:');
      debugPrint('Food: ${selectedFoodItem!.name}');
      debugPrint('Quantity: $currentQuantity');
      debugPrint('Selected Add-ons: ${selectedAddOns.map((e) => e.name).join(', ')}');
      debugPrint('Total Price: ₹${totalPrice.toStringAsFixed(2)}');

      navigateToCart();
    }
  }

  // Getters
  String get selectedCategoryName => categories[selectedCategoryIndex];
  int get foodItemsCount => filteredFoodItems.length;
}
