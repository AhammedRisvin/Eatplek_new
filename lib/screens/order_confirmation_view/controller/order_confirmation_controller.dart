import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../cart/model/cart_api_model.dart';
import '../view/widget/order_accepted_sheet.dart';
import '../view/widget/order_rejected_sheet.dart';
import '../view/widget/payment_bottom_sheet.dart';
import '../view/widget/time_suggest_bottom_sheet.dart';
import '../view/widget/waiting_confirmation_sheet.dart';

class OrderConfirmationController extends GetxController {
  // ========== FORM CONTROLLERS ==========
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final guestCountController = TextEditingController(text: '1');
  final vehicleDetailsController = TextEditingController();
  final deliveryDateController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  // ========== CART DATA FROM PREVIOUS SCREEN ==========
  List<CartItem>? cartItems;
  Vendor? vendor;
  double subtotal = 0.0;
  double taxAmount = 0.0;
  double packingCharge = 0.0;
  double totalAmount = 0.0;
  String instructions = '';
  String appliedPromoCode = '';
  double promoDiscount = 0.0;

  // ========== ORDER ITEMS FOR SUMMARY ==========
  List<OrderItem> mainDishes = [];
  List<OrderItem> addOns = [];

  // ========== API & LOADING STATES ==========
  final FittorConnect _apiClient = FittorConnect();
  bool isLoading = false;
  String errorMessage = '';

  // ========== GUEST COUNT ==========
  static const int minGuests = 1;
  static const int maxGuests = 30;
  int guestCount = 1;

  // ========== TIME VARIABLES ==========
  static const int restaurantOpenHour = 9; // 9 AM
  static const int restaurantCloseHour = 23; // 11 PM

  int selectedHour = 12;
  int selectedMinute = 0;
  String selectedPeriod = 'PM'; // AM or PM
  String? timeErrorMessage;

  // ========== DATE VARIABLES ==========
  DateTime? selectedDate;

  // ========== RESTAURANT RESPONSE HANDLING ==========
  String? orderStatus; // null, 'accepted', 'rejected', 'time_suggestion'
  String? rejectionReason;
  String? suggestedTime; // ISO 8601 format from restaurant
  int? suggestedHour; // 12-hour format
  int? suggestedMinute;
  String? suggestedPeriod;
  bool isTimeSuggestionTimePickerVisible = false; // Toggle time picker visibility in suggestion sheet

  // ========== SERVICE TYPE CHECKING METHODS ==========

  /// ✅ Check if service type is DELIVERY
  bool isDelivery() {
    final cleanedType = _cleanServiceType(Store.deliveryPreference);
    return cleanedType.toLowerCase() == 'delivery';
  }

  /// ✅ Check if service type is TAKEAWAY
  bool isTakeaway() {
    final cleanedType = _cleanServiceType(Store.deliveryPreference);
    final type = cleanedType.toLowerCase();
    return type == 'takeaway' || type == 'take away';
  }

  /// ✅ Check if service type is DINE-IN
  bool isDineIn() {
    final cleanedType = _cleanServiceType(Store.deliveryPreference);
    final type = cleanedType.toLowerCase();
    return (type.contains('dine') && type.contains('in') && !type.contains('car'));
  }

  /// ✅ Check if service type is CAR DINE-IN
  bool isCarDineIn() {
    final cleanedType = _cleanServiceType(Store.deliveryPreference);
    final type = cleanedType.toLowerCase();
    return type.contains('car') && type.contains('dine');
  }

  // ========== PAYMENT VARIABLES ==========
  List<Map<String, dynamic>> paymentMethods = [
    {
      'id': '1',
      'name': 'Credit/Debit Card',
      'imageUrl': 'https://picsum.photos/50?image=10',
      'description': 'Pay securely with your card',
    },
    {
      'id': '2',
      'name': 'UPI',
      'imageUrl': 'https://picsum.photos/50?image=11',
      'description': 'Pay instantly using UPI',
    },
    {
      'id': '3',
      'name': 'Net Banking',
      'imageUrl': 'https://picsum.photos/50?image=12',
      'description': 'Secure online banking payment',
    },
  ];
  int selectedPaymentMethodIndex = 0;

  @override
  void onInit() {
    super.onInit();
    _initializeCartData();
    _setDefaultTime();
    _setDefaultDate();
    _setupFormFieldListeners();
  }

  /// ✅ Setup listeners on all form fields to update button state dynamically
  void _setupFormFieldListeners() {
    fullNameController.addListener(() {
      update(['place_order_button']);
    });

    phoneController.addListener(() {
      update(['place_order_button']);
    });

    addressController.addListener(() {
      update(['place_order_button']);
    });

    guestCountController.addListener(() {
      update(['place_order_button']);
    });

    vehicleDetailsController.addListener(() {
      update(['place_order_button']);
    });
  }

  /// ✅ Initialize cart data from arguments passed from CartView
  void _initializeCartData() {
    try {
      final arguments = Get.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        // Extract cart items
        final itemsList = arguments['cartItems'] as List<CartItem>?;
        cartItems = itemsList ?? [];

        // ✅ FIX: Extract vendor data properly
        vendor = arguments['vendor'] as Vendor?;

        // Extract totals
        subtotal = arguments['subtotal'] as double? ?? 0.0;
        taxAmount = arguments['taxAmount'] as double? ?? 0.0;
        packingCharge = arguments['packingCharge'] as double? ?? 0.0;
        totalAmount = arguments['totalAmount'] as double? ?? 0.0;

        // Extract instructions and promo
        instructions = arguments['instructions'] as String? ?? '';
        appliedPromoCode = arguments['appliedPromoCode'] as String? ?? '';
        promoDiscount = arguments['promoDiscount'] as double? ?? 0.0;

        // ✅ DEBUG LOGS
        debugPrint('═══════════════════════════════════════════');
        debugPrint('✅ Order Data Initialized Successfully');
        debugPrint('═══════════════════════════════════════════');
        debugPrint('📦 Cart Items: ${cartItems?.length}');
        debugPrint('🏪 Vendor: ${vendor?.name}');
        debugPrint('🏪 Vendor ID: ${vendor?.id}');
        debugPrint('💵 Total Amount: $totalAmount');
        debugPrint('Service Type: ${Store.deliveryPreference}');
        debugPrint('═══════════════════════════════════════════');

        // Convert cart items to order items for UI display
        _convertCartToOrderItems();

        update(['restaurant_widget', 'order_summary', 'service_type_layout']);
      }
    } catch (e) {
      debugPrint('❌ Error initializing cart data: $e');
      errorMessage = 'Failed to load order data';
    }
  }

  /// ✅ Convert CartItem to OrderItem for display
  void _convertCartToOrderItems() {
    mainDishes.clear();
    addOns.clear();

    if (cartItems == null) return;

    for (var cartItem in cartItems!) {
      // Main dish
      mainDishes.add(
        OrderItem(
          id: cartItem.id ?? cartItem.foodId ?? '',
          name: cartItem.foodName ?? 'Unknown Item',
          price: cartItem.effectivePrice ?? cartItem.basePrice ?? 0,
          quantity: cartItem.quantity ?? 1,
          isMainDish: true,
          imageUrl: cartItem.foodImage ?? 'https://picsum.photos/250?image=30',
        ),
      );

      // Add customizations as separate items if they exist
      if (cartItem.customizations != null && cartItem.customizations!.isNotEmpty) {
        for (var custom in cartItem.customizations!) {
          addOns.add(
            OrderItem(
              id: custom.customizationId ?? '',
              name: custom.name ?? 'Customization',
              price: (custom.price ?? 0).toDouble(),
              quantity: custom.quantity ?? 0,
              isMainDish: false,
              imageUrl: 'https://picsum.photos/250?image=31',
            ),
          );
        }
      }

      // Add add-ons if they exist
      if (cartItem.addOns != null && cartItem.addOns!.isNotEmpty) {
        for (var addOn in cartItem.addOns!) {
          addOns.add(
            OrderItem(
              id: addOn.addOnId ?? '',
              name: addOn.name ?? 'Add-on',
              price: (addOn.price ?? 0).toDouble(),
              quantity: addOn.quantity ?? 0,
              isMainDish: false,
              imageUrl: 'https://picsum.photos/250?image=32',
            ),
          );
        }
      }
    }

    debugPrint('📊 Main Dishes: ${mainDishes.length}, Add-ons: ${addOns.length}');
  }

  // ========== VALIDATION METHODS ==========

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleanedPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleanedPhone)) {
      return 'Please enter a valid 10-digit Indian phone number';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 10) {
      return 'Please enter a complete address (minimum 10 characters)';
    }
    return null;
  }

  String? validateGuestCount(String? value) {
    final count = int.tryParse(value ?? '');
    if (count == null) {
      return 'Please enter a valid number';
    }
    if (count < minGuests) {
      return 'Minimum $minGuests guest required';
    }
    if (count > maxGuests) {
      return 'Maximum $maxGuests guests allowed';
    }
    return null;
  }

  String? validateVehicleDetails(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vehicle details are required';
    }
    if (value.trim().length < 5) {
      return 'Please enter valid vehicle details (e.g., KL-07-AB-1234 White Swift)';
    }
    return null;
  }

  // ========== TIME METHODS ==========

  void _setDefaultTime() {
    final now = DateTime.now();
    final minimum30MinLater = now.add(const Duration(minutes: 30));

    if (minimum30MinLater.hour >= restaurantOpenHour && minimum30MinLater.hour < restaurantCloseHour) {
      final futureHour = minimum30MinLater.hour;
      final futureMinute = minimum30MinLater.minute;
      selectedHour = futureHour > 12 ? futureHour - 12 : (futureHour == 0 ? 12 : futureHour);
      selectedMinute = ((futureMinute + 14) ~/ 15) * 15;

      if (selectedMinute >= 60) {
        selectedMinute = 0;
        if (selectedHour == 12) {
          selectedHour = 1;
          selectedPeriod = selectedPeriod == 'AM' ? 'PM' : 'AM';
        } else {
          selectedHour++;
        }
      } else {
        selectedPeriod = futureHour >= 12 ? 'PM' : 'AM';
      }
    } else {
      selectedHour = 9;
      selectedMinute = 0;
      selectedPeriod = 'AM';
    }
    _validateTime();
  }

  void _setDefaultDate() {
    selectedDate = DateTime.now();
    deliveryDateController.text = _formatDate(selectedDate!);
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void incrementHour() {
    if (selectedHour == 12) {
      selectedHour = 1;
    } else {
      selectedHour++;
    }
    _validateTime();
    update(['time_widget']);
  }

  void decrementHour() {
    if (selectedHour == 1) {
      selectedHour = 12;
    } else {
      selectedHour--;
    }
    _validateTime();
    update(['time_widget']);
  }

  void incrementMinute() {
    selectedMinute += 15;
    if (selectedMinute >= 60) {
      selectedMinute = 0;
      incrementHour();
      return;
    }
    _validateTime();
    update(['time_widget']);
  }

  void decrementMinute() {
    selectedMinute -= 15;
    if (selectedMinute < 0) {
      selectedMinute = 45;
      decrementHour();
      return;
    }
    _validateTime();
    update(['time_widget']);
  }

  void togglePeriod() {
    selectedPeriod = selectedPeriod == 'AM' ? 'PM' : 'AM';
    _validateTime();
    update(['time_widget']);
  }

  void _validateTime() {
    final currentTime = DateTime.now();
    final selectedDateTime = _getSelectedDateTime();
    final minimumTime = currentTime.add(const Duration(minutes: 30));
    final selectedHour24 = _convertTo24Hour();

    timeErrorMessage = null;

    if (selectedHour24 < restaurantOpenHour || selectedHour24 >= restaurantCloseHour) {
      timeErrorMessage = 'Restaurant is closed. Restaurant hours: 9:00 AM - 11:00 PM';
    } else if (selectedDateTime.isBefore(minimumTime)) {
      timeErrorMessage = 'Please select a time at least 30 minutes from current time';
    } else {
      timeErrorMessage = null;
    }

    // ✅ Update button state when time validation changes
    update(['place_order_button']);
  }

  int _convertTo24Hour() {
    if (selectedPeriod == 'AM') {
      return selectedHour == 12 ? 0 : selectedHour;
    } else {
      return selectedHour == 12 ? 12 : selectedHour + 12;
    }
  }

  DateTime _getSelectedDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, _convertTo24Hour(), selectedMinute);
  }

  String getFormattedTime() {
    return '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')} $selectedPeriod';
  }

  bool isTimeValid() {
    _validateTime();
    return timeErrorMessage == null;
  }

  // ========== TIME CONVERSION TO ISO 8601 ==========

  /// ✅ Convert 12-hour time to ISO 8601 datetime string with Z suffix
  String _convertTimeToISO8601() {
    final hour24 = _convertTo24Hour();
    final now = DateTime.now();

    final selectedDateTime = DateTime(now.year, now.month, now.day, hour24, selectedMinute, 0);
    final isoString = '${selectedDateTime.toIso8601String()}Z';

    debugPrint('⏰ TIME CONVERSION TO ISO 8601:');
    debugPrint('   12-hour format: ${getFormattedTime()}');
    debugPrint('   24-hour format: ${hour24.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}');
    debugPrint('   ISO 8601 format (with Z): $isoString');
    debugPrint('   ✅ READY FOR API');

    return isoString;
  }

  // ========== RESTAURANT SUGGESTED TIME CONVERSION ==========

  /// ✅ Parse ISO 8601 time from restaurant to 12-hour format
  void _parseSuggestedTime(String isoTimeString) {
    try {
      debugPrint('⏰ PARSING RESTAURANT SUGGESTED TIME:');
      debugPrint('   ISO String: $isoTimeString');

      final dateTime = DateTime.parse(isoTimeString);
      final hour24 = dateTime.hour;
      final minute = dateTime.minute;

      // Convert to 12-hour format
      suggestedHour = hour24 > 12 ? hour24 - 12 : (hour24 == 0 ? 12 : hour24);
      suggestedMinute = minute;
      suggestedPeriod = hour24 >= 12 ? 'PM' : 'AM';

      debugPrint('   Parsed Hour: $suggestedHour');
      debugPrint('   Parsed Minute: $suggestedMinute');
      debugPrint('   Parsed Period: $suggestedPeriod');
      debugPrint('   ✅ PARSING COMPLETE');
    } catch (e) {
      debugPrint('❌ Error parsing suggested time: $e');
      suggestedHour = null;
      suggestedMinute = null;
      suggestedPeriod = null;
    }
  }

  /// ✅ Format suggested time for display
  String getFormattedSuggestedTime() {
    if (suggestedHour == null || suggestedMinute == null || suggestedPeriod == null) {
      return '--:-- --';
    }
    return '${suggestedHour.toString().padLeft(2, '0')}:${suggestedMinute.toString().padLeft(2, '0')} $suggestedPeriod';
  }

  // ========== GUEST COUNT METHODS ==========

  void updateGuestCount(String value) {
    final count = int.tryParse(value) ?? minGuests;
    if (count >= minGuests && count <= maxGuests) {
      guestCount = count;
    } else if (count > maxGuests) {
      guestCount = maxGuests;
      guestCountController.text = guestCount.toString();
    } else if (count < minGuests && value.isNotEmpty) {
      guestCount = minGuests;
      guestCountController.text = guestCount.toString();
    }
  }

  // ========== PAYMENT METHODS ==========

  void selectPaymentMethod(int index) {
    selectedPaymentMethodIndex = index;
    update(['payment_method']);
  }

  // ========== TIME SUGGESTION SHEET METHODS ==========

  /// ✅ Toggle time picker visibility in suggestion sheet
  void toggleTimeSuggestionTimePicker() {
    isTimeSuggestionTimePickerVisible = !isTimeSuggestionTimePickerVisible;
    update(['time_suggestion_sheet']);
  }

  /// ✅ Reset time selection to user's original selected time when toggling time picker
  void resetTimeToOriginalSelection() {
    isTimeSuggestionTimePickerVisible = false;
    update(['time_suggestion_sheet']);
  }

  // ========== ORDER CONFIRMATION ==========

  /// ✅ Validate all fields based on service type
  Future<void> confirmOrder() async {
    // Validate required fields based on service type
    if (!_validateServiceTypeFields()) {
      return;
    }

    // ✅ SHOW WAITING SHEET IMMEDIATELY AFTER VALIDATION
    debugPrint('═════════════════════════════════════════════');
    debugPrint('📋 SHOWING WAITING SHEET');
    debugPrint('═════════════════════════════════════════════');
    _showWaitingBottomSheet();

    // Then place the order
    await _placeOrder();
  }

  /// ✅ Validate fields based on service type AND API body requirements
  bool _validateServiceTypeFields() {
    // ✅ DELIVERY
    if (isDelivery()) {
      if (fullNameController.text.trim().isEmpty) {
        _showErrorMessage('Validation Error', 'Full name is required');
        return false;
      }

      if (phoneController.text.trim().isEmpty) {
        _showErrorMessage('Validation Error', 'Phone number is required');
        return false;
      }

      if (addressController.text.trim().isEmpty) {
        _showErrorMessage('Validation Error', 'Delivery address is required');
        return false;
      }

      return true;
    }

    // ✅ DINE-IN
    if (isDineIn()) {
      if (guestCountController.text.trim().isEmpty) {
        _showErrorMessage('Validation Error', 'Number of guests is required');
        return false;
      }

      final guestCount = int.tryParse(guestCountController.text.trim());
      if (guestCount == null || guestCount < minGuests || guestCount > maxGuests) {
        _showErrorMessage('Validation Error', 'Please enter valid number of guests (1-30)');
        return false;
      }

      if (!isTimeValid()) {
        _showErrorMessage('Invalid Time', timeErrorMessage ?? 'Please select a valid time');
        return false;
      }

      return true;
    }

    // ✅ TAKEAWAY
    if (isTakeaway()) {
      if (!isTimeValid()) {
        _showErrorMessage('Invalid Time', timeErrorMessage ?? 'Please select a valid pickup time');
        return false;
      }

      return true;
    }

    // ✅ CAR DINE-IN
    if (isCarDineIn()) {
      if (!isTimeValid()) {
        _showErrorMessage('Invalid Time', timeErrorMessage ?? 'Please select a valid time');
        return false;
      }

      if (vehicleDetailsController.text.trim().isEmpty) {
        _showErrorMessage('Validation Error', 'Vehicle details are required');
        return false;
      }

      return true;
    }

    return true;
  }

  /// ✅ Build dynamic request body based on serviceType
  Map<String, dynamic> _buildOrderRequestBody() {
    final cleanedServiceType = _cleanServiceType(Store.deliveryPreference);

    debugPrint('═════════════════════════════════════════════════════════');
    debugPrint('📤 BUILDING ORDER REQUEST BODY');
    debugPrint('═════════════════════════════════════════════════════════');
    debugPrint('Service Type: $cleanedServiceType');

    final baseOrderData = <String, dynamic>{};

    // Handle different service types
    switch (cleanedServiceType.toLowerCase()) {
      case 'delivery':
        baseOrderData.addAll({
          "serviceType": "Delivery",
          "address": addressController.text.trim(),
          "latitude": 10.0181,
          "longitude": 76.3051,
          "name": fullNameController.text.trim(),
          "phoneNumber": "+91${phoneController.text.trim()}",
        });

        if (instructions.isNotEmpty && instructions.trim().isNotEmpty) {
          baseOrderData['notes'] = instructions.trim();
        }

        debugPrint('✅ Delivery Request:');
        debugPrint('  serviceType: ${baseOrderData["serviceType"]}');
        debugPrint('  address: ${baseOrderData["address"]}');
        debugPrint('  name: ${baseOrderData["name"]}');
        debugPrint('  phoneNumber: ${baseOrderData["phoneNumber"]}');
        break;

      case 'dine-in':
      case 'dine_in':
        final reachTimeISO = _convertTimeToISO8601();
        baseOrderData.addAll({"serviceType": "Dine in", "personCount": guestCount, "reachTime": reachTimeISO});

        debugPrint('✅ Dine-in Request:');
        debugPrint('  serviceType: ${baseOrderData["serviceType"]}');
        debugPrint('  personCount: ${baseOrderData["personCount"]}');
        debugPrint('  reachTime: ${baseOrderData["reachTime"]}');
        break;

      case 'takeaway':
        final reachTimeISO = _convertTimeToISO8601();
        baseOrderData.addAll({"serviceType": "Takeaway", "reachTime": reachTimeISO});

        if (instructions.isNotEmpty && instructions.trim().isNotEmpty) {
          baseOrderData['notes'] = instructions.trim();
        }

        debugPrint('✅ Takeaway Request:');
        debugPrint('  serviceType: ${baseOrderData["serviceType"]}');
        debugPrint('  reachTime: ${baseOrderData["reachTime"]}');
        break;

      case 'car-dine-in':
      case 'car_dine_in':
        final reachTimeISO = _convertTimeToISO8601();
        baseOrderData.addAll({
          "serviceType": "Car Dine in",
          "reachTime": reachTimeISO,
          "vehicleDetails": vehicleDetailsController.text.trim(),
        });

        debugPrint('✅ Car Dine-in Request:');
        debugPrint('  serviceType: ${baseOrderData["serviceType"]}');
        debugPrint('  reachTime: ${baseOrderData["reachTime"]}');
        debugPrint('  vehicleDetails: ${baseOrderData["vehicleDetails"]}');
        break;

      default:
        baseOrderData.addAll({"serviceType": cleanedServiceType});
    }

    debugPrint('═════════════════════════════════════════════════════════');
    return baseOrderData;
  }

  /// ✅ Clean serviceType by removing emojis and extra spaces
  String _cleanServiceType(String serviceType) {
    String cleaned = serviceType.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    cleaned = cleaned.toLowerCase();

    debugPrint('🧹 Cleaned serviceType: "$serviceType" → "$cleaned"');

    if (cleaned.isEmpty) {
      return 'delivery';
    }

    if (cleaned.contains('takeaway') || cleaned.contains('take away')) {
      return 'takeaway';
    } else if (cleaned.contains('dine') && cleaned.contains('in')) {
      return 'dine-in';
    } else if (cleaned.contains('car') && cleaned.contains('dine')) {
      return 'car-dine-in';
    } else if (cleaned.contains('delivery')) {
      return 'delivery';
    }

    return cleaned.length > 50 ? 'delivery' : cleaned;
  }

  /// ✅ Place order API call with dynamic request body
  Future<void> _placeOrder() async {
    try {
      isLoading = true;
      update(['place_order_button']);

      final orderData = _buildOrderRequestBody();

      debugPrint('═════════════════════════════════════════════════════════');
      debugPrint('🚀 SENDING ORDER TO API');
      debugPrint('═════════════════════════════════════════════════════════');
      debugPrint('Full Body: $orderData');
      debugPrint('═════════════════════════════════════════════════════════');

      // Make API call
      final response = await _apiClient.post(
        endpoint: Urls.placeOrderUrl,
        data: orderData,
        timeout: const Duration(seconds: 120),
      );

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true) {
          debugPrint('✅ ORDER PLACED SUCCESSFULLY');

          // ✅ WAITING SHEET ALREADY SHOWN IN confirmOrder()
          // ✅ START POLLING FOR RESTAURANT RESPONSE (2 minutes timeout)
          await _waitForRestaurantResponse();
        } else {
          errorMessage = response['message'] ?? 'Failed to place order';

          // ✅ DISMISS WAITING SHEET ON ERROR
          _dismissWaitingSheet();

          if (response['errors'] != null && response['errors'] is List) {
            final errors = response['errors'] as List;
            String errorDetails = errors
                .map((e) {
                  if (e is Map<String, dynamic>) {
                    return e['msg'] ?? 'Unknown error';
                  }
                  return e.toString();
                })
                .join('\n');

            debugPrint('❌ VALIDATION ERRORS: $errorDetails');
            _showErrorMessage('Validation Error', errorDetails);
          } else {
            _showErrorMessage('Error', errorMessage);
          }
        }
      } else {
        errorMessage = 'Invalid response from server';
        // ✅ DISMISS WAITING SHEET ON ERROR
        _dismissWaitingSheet();
        _showErrorMessage('Error', errorMessage);
      }
    } catch (e) {
      errorMessage = 'Error placing order: $e';
      debugPrint('❌ EXCEPTION: $e');
      // ✅ DISMISS WAITING SHEET ON EXCEPTION
      _dismissWaitingSheet();
      _showErrorMessage('Error', 'Failed to place order. Please try again.');
    } finally {
      isLoading = false;
      update(['place_order_button']);
    }
  }

  // ========== RESTAURANT RESPONSE POLLING ==========

  /// ✅ Wait for restaurant response with 2-minute timeout
  Future<void> _waitForRestaurantResponse() async {
    const maxWaitTime = Duration(minutes: 2);
    const pollInterval = Duration(seconds: 3);
    final startTime = DateTime.now();

    debugPrint('═════════════════════════════════════════════════════════');
    debugPrint('⏳ WAITING FOR RESTAURANT RESPONSE (Max 2 minutes)');
    debugPrint('═════════════════════════════════════════════════════════');

    while (true) {
      final elapsedTime = DateTime.now().difference(startTime);

      // ✅ Check timeout
      if (elapsedTime > maxWaitTime) {
        debugPrint('⏰ TIMEOUT: No response from restaurant after 2 minutes');
        _handleRestaurantTimeout();
        break;
      }

      // ✅ Simulate polling (in real app, call API to check order status)
      // For now, this is a placeholder - replace with actual API call
      await Future.delayed(pollInterval);

      // ✅ In production, make an API call here to check order status
      // Example: final status = await _apiClient.get(endpoint: Urls.getOrderStatusUrl);
      // Then handle the response accordingly

      debugPrint('🔄 Polling... (${elapsedTime.inSeconds}s elapsed)');
    }
  }

  /// ✅ Handle restaurant timeout (no response after 2 minutes)
  void _handleRestaurantTimeout() {
    debugPrint('❌ RESTAURANT RESPONSE TIMEOUT');
    _dismissWaitingSheet();
    _showErrorMessage('Timeout', 'Restaurant did not respond within 2 minutes. Please contact support.');
  }

  /// ✅ Handle restaurant response (to be called from API polling)
  void handleRestaurantResponse(Map<String, dynamic> response) {
    try {
      debugPrint('═════════════════════════════════════════════════════════');
      debugPrint('🎯 RESTAURANT RESPONSE RECEIVED');
      debugPrint('═════════════════════════════════════════════════════════');

      if (response['success'] != true) {
        _handleRestaurantTimeout();
        return;
      }

      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        _handleRestaurantTimeout();
        return;
      }

      final status = data['orderStatus'] as String?;
      final rejectionDetails = data['rejectionDetails'] as Map<String, dynamic>?;

      debugPrint('Order Status: $status');

      switch (status?.toLowerCase()) {
        case 'accepted':
          _handleOrderAccepted(data);
          break;

        case 'rejected':
          if (rejectionDetails?['hasTimeSuggestion'] == true) {
            _handleTimeSuggestion(rejectionDetails!);
          } else {
            _handleOrderRejected(rejectionDetails);
          }
          break;

        default:
          _handleRestaurantTimeout();
      }
    } catch (e) {
      debugPrint('❌ Error handling restaurant response: $e');
      _handleRestaurantTimeout();
    }
  }

  /// ✅ Handle order accepted by restaurant
  void _handleOrderAccepted(Map<String, dynamic> data) {
    debugPrint('✅ ORDER ACCEPTED BY RESTAURANT');

    orderStatus = 'accepted';
    _dismissWaitingSheet();

    // ✅ Show accepted sheet for 2 seconds
    _showAcceptedBottomSheet();

    Future.delayed(const Duration(seconds: 2), () {
      _dismissAcceptedSheet();
      // ✅ Then show payment sheet
      _showPaymentBottomSheet();
    });
  }

  /// ✅ Handle order rejected by restaurant
  void _handleOrderRejected(Map<String, dynamic>? rejectionDetails) {
    debugPrint('❌ ORDER REJECTED BY RESTAURANT');

    orderStatus = 'rejected';
    rejectionReason = rejectionDetails?['rejectionReason'] as String? ?? 'Order rejected by restaurant';

    _dismissWaitingSheet();
    _showRejectedBottomSheet();
  }

  /// ✅ Handle time suggestion from restaurant
  void _handleTimeSuggestion(Map<String, dynamic> rejectionDetails) {
    debugPrint('⏰ TIME SUGGESTION FROM RESTAURANT');

    orderStatus = 'time_suggestion';
    rejectionReason = rejectionDetails['rejectionReason'] as String?;
    suggestedTime = rejectionDetails['suggestedTime'] as String?;

    // Parse suggested time
    if (suggestedTime != null) {
      _parseSuggestedTime(suggestedTime!);
    }

    // Reset UI state
    isTimeSuggestionTimePickerVisible = false;

    _dismissWaitingSheet();
    _showTimeSuggestionBottomSheet();
  }

  /// ✅ Accept restaurant's suggested time
  Future<void> acceptSuggestedTime() async {
    debugPrint('═════════════════════════════════════════════════════════');
    debugPrint('✅ ACCEPTING RESTAURANT SUGGESTED TIME');
    debugPrint('═════════════════════════════════════════════════════════');
    debugPrint('Suggested Time: ${getFormattedSuggestedTime()}');
    debugPrint('═════════════════════════════════════════════════════════');

    // Update user's selected time to suggested time
    if (suggestedHour != null && suggestedMinute != null && suggestedPeriod != null) {
      selectedHour = suggestedHour!;
      selectedMinute = suggestedMinute!;
      selectedPeriod = suggestedPeriod!;
    }

    _dismissTimeSuggestionSheet();

    // ✅ Show waiting sheet again and wait for confirmation
    _showWaitingBottomSheet();
    await _waitForRestaurantResponse();
  }

  /// ✅ Submit custom time selection from time picker
  Future<void> submitCustomTimeSelection() async {
    debugPrint('═════════════════════════════════════════════════════════');
    debugPrint('📤 SUBMITTING CUSTOM TIME SELECTION');
    debugPrint('═════════════════════════════════════════════════════════');
    debugPrint('Selected Time: ${getFormattedTime()}');
    debugPrint('═════════════════════════════════════════════════════════');

    if (!isTimeValid()) {
      _showErrorMessage('Invalid Time', timeErrorMessage ?? 'Please select a valid time');
      return;
    }

    _dismissTimeSuggestionSheet();

    // ✅ Show waiting sheet and place order with new time
    _showWaitingBottomSheet();
    await _placeOrder();
  }

  // ========== BOTTOM SHEET MANAGEMENT ==========

  /// ✅ Show waiting bottom sheet (non-dismissible)
  void _showWaitingBottomSheet() {
    debugPrint('📋 Showing waiting bottom sheet...');

    Get.bottomSheet(
      WillPopScope(
        onWillPop: () async => false, // Prevent dismissal
        child: const ResponsiveWaitingFormConfirmationSheet(),
      ),
      isScrollControlled: true,
      isDismissible: false, // Non-dismissible
      enableDrag: false, // Prevent swipe down
      backgroundColor: Colors.transparent,
    );
  }

  /// ✅ Dismiss waiting bottom sheet
  void _dismissWaitingSheet() {
    debugPrint('❌ Dismissing waiting sheet...');

    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
  }

  /// ✅ Show accepted bottom sheet
  void _showAcceptedBottomSheet() {
    debugPrint('✅ Showing accepted bottom sheet...');

    Get.bottomSheet(
      ResponsiveOrderAcceptedSheet(selectedPaymentMethod: paymentMethods[selectedPaymentMethodIndex]),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
    );
  }

  /// ✅ Dismiss accepted bottom sheet
  void _dismissAcceptedSheet() {
    debugPrint('❌ Dismissing accepted sheet...');

    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
  }

  /// ✅ Show rejected bottom sheet
  void _showRejectedBottomSheet() {
    debugPrint('❌ Showing rejected bottom sheet...');

    Get.bottomSheet(
      ResponsiveOrderRejectedSheet(
        selectedPaymentMethod: paymentMethods[selectedPaymentMethodIndex],
        rejectionReason: rejectionReason,
      ),
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// ✅ Show time suggestion bottom sheet
  void _showTimeSuggestionBottomSheet() {
    debugPrint('⏰ Showing time suggestion bottom sheet...');

    Get.bottomSheet(
      TimeSuggestBottomSheet(controller: this),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
    );
  }

  /// ✅ Dismiss time suggestion bottom sheet
  void _dismissTimeSuggestionSheet() {
    debugPrint('❌ Dismissing time suggestion sheet...');

    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
  }

  /// ✅ Show payment bottom sheet
  void _showPaymentBottomSheet() {
    debugPrint('💳 Showing payment bottom sheet...');

    Get.bottomSheet(
      ResponsivePaymentBottomSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// ✅ Show error message
  void _showErrorMessage(String title, String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.withOpacity(0.8),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      try {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } catch (e) {
        debugPrint('⚠️ Could not show snackbar: $message');
      }
    }
  }

  /// ✅ Show success message
  void _showSuccessMessage(String title, String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.withOpacity(0.8),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      try {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        debugPrint('⚠️ Could not show snackbar: $message');
      }
    }
  }

  // ========== UTILITY METHODS ==========

  double getTotalPrice() {
    return totalAmount;
  }

  List<OrderItem> getMainDishes() {
    return mainDishes;
  }

  List<OrderItem> getAddOns() {
    return addOns;
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    guestCountController.dispose();
    vehicleDetailsController.dispose();
    deliveryDateController.dispose();
    super.onClose();
  }
}

// ========== ORDER ITEM MODEL ==========
class OrderItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final bool isMainDish;
  final String imageUrl;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.isMainDish,
    required this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      isMainDish: json['is_main_dish'] ?? true,
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'is_main_dish': isMainDish,
      'image_url': imageUrl,
    };
  }
}
