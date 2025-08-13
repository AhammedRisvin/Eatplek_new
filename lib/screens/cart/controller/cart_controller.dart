import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/screens/cart/model/cart_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  // Cart items
  List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  // Instructions
  final TextEditingController instructionsController = TextEditingController();
  String _instructionsError = '';
  String get instructionsError => _instructionsError;

  // Promo code
  final TextEditingController promoCodeController = TextEditingController();
  String _promoCodeError = '';
  String get promoCodeError => _promoCodeError;
  String _appliedPromoCode = '';
  String get appliedPromoCode => _appliedPromoCode;
  double _promoDiscount = 0.0;
  double get promoDiscount => _promoDiscount;

  // Price constants (can be made dynamic later)
  final double deliveryFee = 25.0;
  final double taxPercentage = 5.0; // 5%
  final double packingCharge = 10.0;

  @override
  void onInit() {
    super.onInit();
    _loadSampleData();
  }

  // Load sample cart data
  void _loadSampleData() {
    _cartItems = [
      CartItem(
        id: '1',
        name: 'Classic Chicken Burger',
        category: 'Burger',
        basePrice: 180.0,
        imageUrl: 'https://picsum.photos/250?image=30',
        quantity: 1,
        selectedAddOns: [
          AddOn(
            id: '1',
            name: 'Extra Cheese',
            price: 25.0,
            imageUrl: 'https://picsum.photos/100/100?random=1',
            isSelected: true,
          ),
          AddOn(
            id: '2',
            name: 'Crispy Bacon',
            price: 45.0,
            imageUrl: 'https://picsum.photos/100/100?random=2',
            isSelected: true,
          ),
        ],
      ),
      CartItem(
        id: '2',
        name: 'Margherita Pizza',
        category: 'Pizza',
        basePrice: 299.0,
        imageUrl: 'https://picsum.photos/250?image=31',
        quantity: 2,
        selectedAddOns: [
          AddOn(
            id: '3',
            name: 'Extra Toppings',
            price: 30.0,
            imageUrl: 'https://picsum.photos/100/100?random=3',
            isSelected: true,
          ),
        ],
      ),
    ];
    update(['cart_items', 'price_summary']);
  }

  // Quantity management
  void incrementQuantity(String itemId) {
    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1 && _cartItems[index].quantity < 10) {
      _cartItems[index].quantity++;
      update(['cart_items', 'price_summary']);
    }
  }

  void decrementQuantity(String itemId) {
    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
        update(['cart_items', 'price_summary']);
      } else {
        // Remove item completely when quantity reaches 0
        removeItem(itemId);
      }
    }
  }

  // Remove item from cart
  void removeItem(String itemId) {
    _cartItems.removeWhere((item) => item.id == itemId);
    update(['cart_items', 'price_summary', 'empty_cart']);
  }

  // Add-on management
  void toggleAddOn(String itemId, String addOnId) {
    final itemIndex = _cartItems.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      final addOnIndex = _cartItems[itemIndex].selectedAddOns.indexWhere((addOn) => addOn.id == addOnId);
      if (addOnIndex != -1) {
        _cartItems[itemIndex].selectedAddOns[addOnIndex].isSelected =
            !_cartItems[itemIndex].selectedAddOns[addOnIndex].isSelected;
        update(['cart_items', 'price_summary']);
      }
    }
  }

  // Price calculations
  double get subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalItemPrice);
  }

  double get taxAmount {
    return subtotal * taxPercentage / 100;
  }

  double get totalAmount {
    return subtotal + deliveryFee + taxAmount + packingCharge - _promoDiscount;
  }

  // Instructions validation
  bool validateInstructions() {
    final instructions = instructionsController.text.trim();

    if (instructions.isNotEmpty && instructions.length < 10) {
      _instructionsError = 'Instructions must be at least 10 characters';
      update(['instructions_validation']);
      return false;
    }

    if (instructions.length > 200) {
      _instructionsError = 'Instructions cannot exceed 200 characters';
      update(['instructions_validation']);
      return false;
    }

    _instructionsError = '';
    update(['instructions_validation']);
    return true;
  }

  // Clear instructions error
  void clearInstructionsError() {
    if (_instructionsError.isNotEmpty) {
      _instructionsError = '';
      update(['instructions_validation']);
    }
  }

  // Promo code management
  final List<PromoCode> _availablePromoCodes = [
    PromoCode(
      code: 'SAVE20',
      description: '20% off on orders above ₹300',
      discountAmount: 0,
      discountPercentage: 20,
      minimumOrderValue: 300,
      isActive: true,
      expiryDate: DateTime.now().add(Duration(days: 30)),
    ),
    PromoCode(
      code: 'FLAT50',
      description: 'Flat ₹50 off on orders above ₹200',
      discountAmount: 50,
      discountPercentage: 0,
      minimumOrderValue: 200,
      isActive: true,
      expiryDate: DateTime.now().add(Duration(days: 15)),
    ),
    PromoCode(
      code: 'NEWUSER',
      description: '30% off for new users',
      discountAmount: 0,
      discountPercentage: 30,
      minimumOrderValue: 100,
      isActive: true,
      expiryDate: DateTime.now().add(Duration(days: 60)),
    ),
  ];

  void applyPromoCode() {
    final code = promoCodeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _promoCodeError = 'Please enter a promo code';
      update(['promo_validation']);
      return;
    }

    final promoCode = _availablePromoCodes.firstWhereOrNull((promo) => promo.code == code);

    if (promoCode == null) {
      _promoCodeError = 'Invalid promo code';
      update(['promo_validation']);
      return;
    }

    if (!promoCode.isValid) {
      _promoCodeError = 'Promo code has expired';
      update(['promo_validation']);
      return;
    }

    if (subtotal < promoCode.minimumOrderValue) {
      _promoCodeError = 'Minimum order value ₹${promoCode.minimumOrderValue.toInt()} required';
      update(['promo_validation']);
      return;
    }

    // Apply discount
    if (promoCode.discountPercentage > 0) {
      _promoDiscount = subtotal * promoCode.discountPercentage / 100;
    } else {
      _promoDiscount = promoCode.discountAmount;
    }

    _appliedPromoCode = code;
    _promoCodeError = '';
    promoCodeController.text = code; // Show uppercase code

    update(['promo_validation', 'price_summary']);

    Get.snackbar(
      'Success',
      'Promo code applied! You saved ₹${_promoDiscount.toInt()}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.primaryColor,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  void removePromoCode() {
    _appliedPromoCode = '';
    _promoDiscount = 0.0;
    _promoCodeError = '';
    promoCodeController.clear();
    update(['promo_validation', 'price_summary']);
  }

  // Format promo code input to uppercase
  void formatPromoCode(String value) {
    final upperCaseValue = value.toUpperCase();
    if (promoCodeController.text != upperCaseValue) {
      promoCodeController.value = promoCodeController.value.copyWith(
        text: upperCaseValue,
        selection: TextSelection.collapsed(offset: upperCaseValue.length),
      );
    }
    clearPromoError();
  }

  void clearPromoError() {
    if (_promoCodeError.isNotEmpty) {
      _promoCodeError = '';
      update(['promo_validation']);
    }
  }

  // Check if cart is empty
  bool get isCartEmpty => _cartItems.isEmpty;

  // Place order
  void placeOrder() {
    // Validate instructions if provided
    if (!validateInstructions()) {
      return;
    }

    if (_cartItems.isEmpty) {
      Get.snackbar(
        'Empty Cart',
        'Please add items to cart before placing order',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    // Here you would typically send the order to your backend
    Get.snackbar(
      'Order Placed',
      'Your order has been placed successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.primaryColor,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: Duration(seconds: 3),
    );

    Get.toNamed(Routes.orderConfirmationView);

    // Navigate to order confirmation or clear cart
    // _cartItems.clear();
    // update(['cart_items', 'price_summary', 'empty_cart']);
  }

  @override
  void onClose() {
    instructionsController.dispose();
    promoCodeController.dispose();
    super.onClose();
  }
}
