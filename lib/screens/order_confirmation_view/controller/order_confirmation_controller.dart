import 'dart:developer';

import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../cart/controller/cart_service.dart';
import '../../cart/model/cart_api_model.dart';
import '../service/phonepay_service.dart';
import '../view/widget/order_accepted_sheet.dart';
import '../view/widget/order_rejected_sheet.dart';
import '../view/widget/payment_result_bottom_sheet.dart';
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
  final PhonePeService _phonePeService = PhonePeService();
  bool isLoading = false;
  bool isPaymentLoading = false;
  String errorMessage = '';

  // ========== PLACED ORDER DATA ==========
  // Populated once vendor accepts. Used for payment initiation.
  String? placedOrderId;
  String? placedOrderUserPhone;

  // ========== GUEST COUNT ==========
  static const int minGuests = 1;
  static const int maxGuests = 30;
  int guestCount = 1;

  // ========== TIME VARIABLES ==========
  static const int restaurantOpenHour = 9;
  static const int restaurantCloseHour = 23;

  int selectedHour = 12;
  int selectedMinute = 0;
  String selectedPeriod = 'PM';
  String? timeErrorMessage;

  // ========== DATE VARIABLES ==========
  DateTime? selectedDate;

  // ========== RESTAURANT RESPONSE HANDLING ==========
  String? orderStatus;
  String? rejectionReason;
  String? suggestedTime;
  int? suggestedHour;
  int? suggestedMinute;
  String? suggestedPeriod;
  DateTime? _suggestedDateTime;
  bool isTimeSuggestionTimePickerVisible = false;

  // ========== PAYMENT UI (kept for rejected sheet display) ==========
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

  // ========== LIFECYCLE ==========

  @override
  void onInit() {
    super.onInit();
    _initializeCartData();
    _setDefaultTime();
    _setDefaultDate();
    _setupFormFieldListeners();
  }

  void _setupFormFieldListeners() {
    fullNameController.addListener(() => update(['place_order_button']));
    phoneController.addListener(() => update(['place_order_button']));
    addressController.addListener(() => update(['place_order_button']));
    guestCountController.addListener(() => update(['place_order_button']));
    vehicleDetailsController.addListener(() => update(['place_order_button']));
  }

  void _initializeCartData() {
    try {
      final arguments = Get.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        cartItems = arguments['cartItems'] as List<CartItem>? ?? [];
        vendor = arguments['vendor'] as Vendor?;
        subtotal = arguments['subtotal'] as double? ?? 0.0;
        taxAmount = arguments['taxAmount'] as double? ?? 0.0;
        packingCharge = arguments['packingCharge'] as double? ?? 0.0;
        totalAmount = arguments['totalAmount'] as double? ?? 0.0;
        instructions = arguments['instructions'] as String? ?? '';
        appliedPromoCode = arguments['appliedPromoCode'] as String? ?? '';
        promoDiscount = arguments['promoDiscount'] as double? ?? 0.0;

        debugPrint('═══════════════════════════════════════════');
        debugPrint('✅ Order Data Initialized');
        debugPrint('📦 Cart Items: ${cartItems?.length}');
        debugPrint('🏪 Vendor: ${vendor?.name} (${vendor?.id})');
        debugPrint('💵 Total: $totalAmount');
        debugPrint('🚗 Service: ${Store.deliveryPreference}');
        debugPrint('═══════════════════════════════════════════');

        _convertCartToOrderItems();
        update(['restaurant_widget', 'order_summary', 'service_type_layout']);
      }
    } catch (e) {
      debugPrint('❌ Error initializing cart data: $e');
      errorMessage = 'Failed to load order data';
    }
  }

  void _convertCartToOrderItems() {
    mainDishes.clear();
    addOns.clear();

    if (cartItems == null) return;

    for (var cartItem in cartItems!) {
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

      if (cartItem.customizations != null &&
          cartItem.customizations!.isNotEmpty) {
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
  }

  // ========== VALIDATION METHODS ==========

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2)
      return 'Full name must be at least 2 characters';
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Phone number is required';
    final cleanedPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleanedPhone)) {
      return 'Please enter a valid 10-digit Indian phone number';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return 'Address is required';
    if (value.trim().length < 10) {
      return 'Please enter a complete address (minimum 10 characters)';
    }
    return null;
  }

  String? validateGuestCount(String? value) {
    final count = int.tryParse(value ?? '');
    if (count == null) return 'Please enter a valid number';
    if (count < minGuests) return 'Minimum $minGuests guest required';
    if (count > maxGuests) return 'Maximum $maxGuests guests allowed';
    return null;
  }

  String? validateVehicleDetails(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Vehicle details are required';
    if (value.trim().length < 5) {
      return 'Please enter valid vehicle details (e.g., KL-07-AB-1234 White Swift)';
    }
    return null;
  }

  // ========== TIME METHODS ==========

  void _setDefaultTime() {
    final now = DateTime.now();
    final minimum30MinLater = now.add(const Duration(minutes: 30));

    if (minimum30MinLater.hour >= restaurantOpenHour &&
        minimum30MinLater.hour < restaurantCloseHour) {
      final futureHour = minimum30MinLater.hour;
      final futureMinute = minimum30MinLater.minute;
      selectedHour =
          futureHour > 12
              ? futureHour - 12
              : (futureHour == 0 ? 12 : futureHour);
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
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void incrementHour() {
    selectedHour = selectedHour == 12 ? 1 : selectedHour + 1;
    _validateTime();
    update(['time_widget']);
  }

  void decrementHour() {
    selectedHour = selectedHour == 1 ? 12 : selectedHour - 1;
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

  // ========== TIME VALIDATION ==========

  void _validateTime() => _validateTimeWithMinimum(minimumDateTime: null);

  void _validateTimeForSuggestionFlow() =>
      _validateTimeWithMinimum(minimumDateTime: _suggestedDateTime);

  void _validateTimeWithMinimum({DateTime? minimumDateTime}) {
    final currentTime = DateTime.now();
    final selectedDateTime = _getSelectedDateTime();
    final minimumBy30Min = currentTime.add(const Duration(minutes: 30));
    final selectedHour24 = _convertTo24Hour();

    if (selectedHour24 < restaurantOpenHour ||
        selectedHour24 >= restaurantCloseHour) {
      timeErrorMessage =
          'Restaurant is closed. Restaurant hours: 9:00 AM - 11:00 PM';
    } else if (selectedDateTime.isBefore(minimumBy30Min)) {
      timeErrorMessage =
          'Please select a time at least 30 minutes from current time';
    } else if (minimumDateTime != null &&
        selectedDateTime.isBefore(minimumDateTime)) {
      timeErrorMessage =
          "Please select a time after the restaurant's suggested time (${getFormattedSuggestedTime()})";
    } else {
      timeErrorMessage = null;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      update(['time_widget', 'place_order_button']);
    });
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
    return DateTime(
      now.year,
      now.month,
      now.day,
      _convertTo24Hour(),
      selectedMinute,
    );
  }

  String getFormattedTime() =>
      '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')} $selectedPeriod';

  bool isTimeValid() {
    _validateTime();
    return timeErrorMessage == null;
  }

  bool isTimeValidForSuggestionFlow() {
    _validateTimeForSuggestionFlow();
    return timeErrorMessage == null;
  }

  String _convertTimeToISO8601() {
    final now = DateTime.now();
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
      _convertTo24Hour(),
      selectedMinute,
      0,
    );
    return '${dt.toIso8601String()}Z';
  }

  // ========== SUGGESTED TIME PARSING ==========

  void _parseSuggestedTime(String isoTimeString) {
    try {
      final dateTime = DateTime.parse(isoTimeString);
      final hour24 = dateTime.hour;
      final minute = dateTime.minute;

      suggestedHour = hour24 > 12 ? hour24 - 12 : (hour24 == 0 ? 12 : hour24);
      suggestedMinute = minute;
      suggestedPeriod = hour24 >= 12 ? 'PM' : 'AM';

      final now = DateTime.now();
      _suggestedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour24,
        minute,
      );
    } catch (e) {
      debugPrint('❌ Error parsing suggested time: $e');
      suggestedHour = null;
      suggestedMinute = null;
      suggestedPeriod = null;
      _suggestedDateTime = null;
    }
  }

  String getFormattedSuggestedTime() {
    if (suggestedHour == null ||
        suggestedMinute == null ||
        suggestedPeriod == null) {
      return '--:-- --';
    }
    return '${suggestedHour.toString().padLeft(2, '0')}:${suggestedMinute.toString().padLeft(2, '0')} $suggestedPeriod';
  }

  // ========== GUEST COUNT ==========

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

  // ========== PAYMENT METHOD SELECTION ==========

  void selectPaymentMethod(int index) {
    selectedPaymentMethodIndex = index;
    update(['payment_method']);
  }

  // ========== TIME SUGGESTION SHEET ==========

  void toggleTimeSuggestionTimePicker() {
    isTimeSuggestionTimePickerVisible = !isTimeSuggestionTimePickerVisible;
    if (isTimeSuggestionTimePickerVisible) _validateTimeForSuggestionFlow();
    update(['time_suggestion_sheet']);
  }

  void resetTimeToOriginalSelection() {
    isTimeSuggestionTimePickerVisible = false;
    _validateTime();
    update(['time_suggestion_sheet']);
  }

  // ========== ORDER CONFIRMATION ENTRY POINT ==========

  Future<void> confirmOrder() async {
    if (!_validateServiceTypeFields()) return;
    _showWaitingBottomSheet();
    await _placeOrder();
  }

  bool _validateServiceTypeFields() {
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
    if (isDineIn()) {
      if (guestCountController.text.trim().isEmpty) {
        _showErrorMessage('Validation Error', 'Number of guests is required');
        return false;
      }
      final count = int.tryParse(guestCountController.text.trim());
      if (count == null || count < minGuests || count > maxGuests) {
        _showErrorMessage(
          'Validation Error',
          'Please enter valid number of guests (1-30)',
        );
        return false;
      }
      if (!isTimeValid()) {
        _showErrorMessage(
          'Invalid Time',
          timeErrorMessage ?? 'Please select a valid time',
        );
        return false;
      }
      return true;
    }
    if (isTakeaway()) {
      if (!isTimeValid()) {
        _showErrorMessage(
          'Invalid Time',
          timeErrorMessage ?? 'Please select a valid pickup time',
        );
        return false;
      }
      return true;
    }
    if (isCarDineIn()) {
      if (!isTimeValid()) {
        _showErrorMessage(
          'Invalid Time',
          timeErrorMessage ?? 'Please select a valid time',
        );
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

  // ========== SERVICE TYPE METHODS ==========

  bool isDelivery() {
    final cleanedType = _cleanServiceType(Store.deliveryPreference);
    return cleanedType.toLowerCase() == 'delivery';
  }

  bool isTakeaway() {
    final cleanedType = _cleanServiceType(Store.deliveryPreference);
    final type = cleanedType.toLowerCase();
    return type == 'takeaway' || type == 'take away';
  }

  bool isDineIn() {
    final cleanedType = _cleanServiceType(Store.deliveryPreference);
    final type = cleanedType.toLowerCase();
    return type.contains('dine') &&
        type.contains('in') &&
        !type.contains('car');
  }

  bool isCarDineIn() {
    final cleanedType = _cleanServiceType(Store.deliveryPreference);
    final type = cleanedType.toLowerCase();
    return type.contains('car') && type.contains('dine');
  }

  Map<String, dynamic> _buildOrderRequestBody() {
    final cleanedServiceType = _cleanServiceType(Store.deliveryPreference);
    final baseOrderData = <String, dynamic>{};

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
        if (instructions.trim().isNotEmpty) {
          baseOrderData['notes'] = instructions.trim();
        }
        break;
      case 'dine-in':
      case 'dine_in':
        baseOrderData.addAll({
          "serviceType": "Dine in",
          "personCount": guestCount,
          "reachTime": _convertTimeToISO8601(),
        });
        break;
      case 'takeaway':
        baseOrderData.addAll({
          "serviceType": "Takeaway",
          "reachTime": _convertTimeToISO8601(),
        });
        if (instructions.trim().isNotEmpty) {
          baseOrderData['notes'] = instructions.trim();
        }
        break;
      case 'car-dine-in':
      case 'car_dine_in':
        baseOrderData.addAll({
          "serviceType": "Car Dine in",
          "reachTime": _convertTimeToISO8601(),
          "vehicleDetails": vehicleDetailsController.text.trim(),
        });
        break;
      default:
        baseOrderData['serviceType'] = cleanedServiceType;
    }

    return baseOrderData;
  }

  String _cleanServiceType(String serviceType) {
    String cleaned = serviceType.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

    if (cleaned.isEmpty) return 'delivery';
    if (cleaned.contains('takeaway') || cleaned.contains('take away'))
      return 'takeaway';
    if (cleaned.contains('car') && cleaned.contains('dine'))
      return 'car-dine-in';
    if (cleaned.contains('dine') && cleaned.contains('in')) return 'dine-in';
    if (cleaned.contains('delivery')) return 'delivery';
    return cleaned.length > 50 ? 'delivery' : cleaned;
  }

  // ========== PLACE ORDER ==========

  Future<void> _placeOrder() async {
    try {
      isLoading = true;
      update(['place_order_button']);

      final response = await _apiClient.post(
        endpoint: Urls.placeOrderUrl,
        data: _buildOrderRequestBody(),
        timeout: const Duration(seconds: 120),
      );

      log('Place order response: $response');

      if (response != null && response is Map<String, dynamic>) {
        _handleApiResponse(response);
      } else {
        _dismissWaitingSheet();
        _showErrorMessage('Error', 'Invalid response from server');
      }
    } catch (e) {
      debugPrint('❌ Exception placing order: $e');
      _dismissWaitingSheet();
      _showErrorMessage('Error', 'Failed to place order. Please try again.');
    } finally {
      isLoading = false;
      update(['place_order_button']);
    }
  }

  // ========== API RESPONSE HANDLER ==========

  void _handleApiResponse(Map<String, dynamic> response) {
    if (response['success'] != true) {
      final msg = response['message'] ?? 'Failed to place order';
      if (response['errors'] != null && response['errors'] is List) {
        final errors = response['errors'] as List;
        final errorDetails = errors
            .map(
              (e) =>
                  e is Map<String, dynamic>
                      ? e['msg'] ?? 'Unknown error'
                      : e.toString(),
            )
            .join('\n');
        _dismissWaitingSheet();
        _showErrorMessage('Validation Error', errorDetails);
      } else {
        _dismissWaitingSheet();
        _showErrorMessage('Error', msg);
      }
      return;
    }

    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      _dismissWaitingSheet();
      _showErrorMessage('Error', 'Unexpected response format from server');
      return;
    }

    // ── Store order data for payment ──
    _storeAcceptedOrderData(data);

    final orderStatusRaw = data['orderStatus'] as String? ?? '';
    debugPrint('📋 orderStatus: $orderStatusRaw');

    switch (orderStatusRaw.toLowerCase()) {
      case 'accepted':
        _handleOrderAccepted(data);
        break;
      case 'rejected':
        final rejectionDetails =
            data['rejectionDetails'] as Map<String, dynamic>?;
        final hasTimeSuggestion =
            rejectionDetails?['hasTimeSuggestion'] == true;
        if (hasTimeSuggestion) {
          _handleTimeSuggestion(rejectionDetails!);
        } else {
          _handleOrderRejected(rejectionDetails);
        }
        break;
      default:
        debugPrint('⚠️ Unknown orderStatus: $orderStatusRaw');
        _dismissWaitingSheet();
        _showErrorMessage(
          'Unexpected Status',
          'Received unexpected order status: $orderStatusRaw',
        );
    }
  }

  /// ✅ Store orderId and user phone from the accepted response.
  void _storeAcceptedOrderData(Map<String, dynamic> data) {
    placedOrderId = data['id'] as String?;

    // Phone priority:
    // 1. user.phone from response (backend may not always populate this)
    // 2. Store.phone — saved at login, always available as fallback
    final user = data['user'] as Map<String, dynamic>?;
    final phoneFromResponse = user?['phone'] as String?;
    final rawPhone =
        (phoneFromResponse != null && phoneFromResponse.isNotEmpty)
            ? phoneFromResponse
            : Store.phone;

    // Strip country code — PhonePe wants plain 10-digit number
    String cleaned = rawPhone.replaceAll(RegExp(r'^\+?91'), '').trim();
    if (cleaned.length > 10) {
      cleaned = cleaned.substring(cleaned.length - 10);
    }
    placedOrderUserPhone = cleaned;

    debugPrint('📋 Accepted order — id: $placedOrderId');
    debugPrint('   phone raw: $rawPhone → cleaned: $placedOrderUserPhone');
  }

  // ========== ACCEPTED ==========

  void _handleOrderAccepted(Map<String, dynamic> data) {
    debugPrint('✅ Order ACCEPTED — id: $placedOrderId');
    orderStatus = 'accepted';

    _dismissWaitingSheet();

    // Show accepted animation for 2s, then go straight to PhonePe
    _showAcceptedBottomSheet();
    Future.delayed(const Duration(seconds: 2), () {
      _dismissAcceptedSheet();
      _startPhonePePayment();
    });
  }

  // ========== REJECTED ==========

  void _handleOrderRejected(Map<String, dynamic>? rejectionDetails) {
    debugPrint('❌ Order REJECTED');
    orderStatus = 'rejected';
    rejectionReason =
        rejectionDetails?['rejectionReason'] as String? ??
        'Order rejected by restaurant';

    _dismissWaitingSheet();
    _showRejectedBottomSheet();
  }

  // ========== TIME SUGGESTION ==========

  void _handleTimeSuggestion(Map<String, dynamic> rejectionDetails) {
    debugPrint('⏰ TIME SUGGESTION received');
    orderStatus = 'time_suggestion';
    rejectionReason = rejectionDetails['rejectionReason'] as String?;
    suggestedTime = rejectionDetails['suggestedTime'] as String?;

    if (suggestedTime != null) _parseSuggestedTime(suggestedTime!);
    isTimeSuggestionTimePickerVisible = false;

    _dismissWaitingSheet();
    _showTimeSuggestionBottomSheet();
  }

  Future<void> acceptSuggestedTime() async {
    if (suggestedHour != null &&
        suggestedMinute != null &&
        suggestedPeriod != null) {
      selectedHour = suggestedHour!;
      selectedMinute = suggestedMinute!;
      selectedPeriod = suggestedPeriod!;
    }
    _dismissTimeSuggestionSheet();
    _showWaitingBottomSheet();
    await _placeOrder();
  }

  Future<void> submitCustomTimeSelection() async {
    if (!isTimeValidForSuggestionFlow()) {
      _showErrorMessage(
        'Invalid Time',
        timeErrorMessage ?? 'Please select a valid time',
      );
      update(['time_suggestion_sheet']);
      return;
    }
    _dismissTimeSuggestionSheet();
    _showWaitingBottomSheet();
    await _placeOrder();
  }

  // ─────────────────────────────────────────────────────────────
  // PHONEPE PAYMENT FLOW
  // ─────────────────────────────────────────────────────────────

  Future<void> _startPhonePePayment() async {
    if (placedOrderId == null || placedOrderId!.isEmpty) {
      _showErrorMessage(
        'Payment Error',
        'Could not retrieve order details. Please check your orders.',
      );
      return;
    }

    try {
      isPaymentLoading = true;
      update(['place_order_button']);

      debugPrint(
        '💳 Starting PhonePe — orderId: $placedOrderId, amount: $totalAmount',
      );

      final result = await _phonePeService.startPayment(
        orderId: placedOrderId!,
        amount: totalAmount,
        mobileNumber: placedOrderUserPhone ?? '',
      );

      debugPrint('💳 Payment result: ${result.status}');
      _showPaymentResultSheet(result);
    } catch (e) {
      debugPrint('🔴 Payment exception: $e');
      _showErrorMessage(
        'Payment Error',
        'An unexpected error occurred. Please try again.',
      );
    } finally {
      isPaymentLoading = false;
      update(['place_order_button']);
    }
  }

  /// ✅ Called from PaymentResultBottomSheet retry button (failed state only)
  Future<void> retryPayment() async {
    await _startPhonePePayment();
  }

  /// ✅ Called from PaymentResultBottomSheet after successful payment
  Future<void> clearCartAfterPayment() async {
    try {
      debugPrint('🧹 Clearing cart...');
      Get.find<CartService>().clearCart();
      debugPrint('✅ Cart cleared');
    } catch (e) {
      // Non-fatal — don't block navigation on cart clear failure
      debugPrint('⚠️ Cart clear failed (non-fatal): $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // BOTTOM SHEET MANAGEMENT
  // ─────────────────────────────────────────────────────────────

  void _showWaitingBottomSheet() {
    Get.bottomSheet(
      WillPopScope(
        onWillPop: () async => false,
        child: const ResponsiveWaitingFormConfirmationSheet(),
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
    );
  }

  void _dismissWaitingSheet() {
    if (Get.isBottomSheetOpen ?? false) Get.back();
  }

  void _showAcceptedBottomSheet() {
    Get.bottomSheet(
      ResponsiveOrderAcceptedSheet(
        selectedPaymentMethod: paymentMethods[selectedPaymentMethodIndex],
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
    );
  }

  void _dismissAcceptedSheet() {
    if (Get.isBottomSheetOpen ?? false) Get.back();
  }

  void _showRejectedBottomSheet() {
    Get.bottomSheet(
      ResponsiveOrderRejectedSheet(
        selectedPaymentMethod: paymentMethods[selectedPaymentMethodIndex],
        rejectionReason: rejectionReason,
      ),
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.white,
    );
  }

  void _showTimeSuggestionBottomSheet() {
    Get.bottomSheet(
      TimeSuggestBottomSheet(controller: this),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
    );
  }

  void _dismissTimeSuggestionSheet() {
    if (Get.isBottomSheetOpen ?? false) Get.back();
  }

  /// ✅ Replaces the old static payment selection sheet.
  void _showPaymentResultSheet(PhonePePaymentResult result) {
    Get.bottomSheet(
      PaymentResultBottomSheet(result: result, controller: this),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SNACKBAR HELPERS
  // ─────────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────
  // UTILITY
  // ─────────────────────────────────────────────────────────────

  double getTotalPrice() => totalAmount;
  List<OrderItem> getMainDishes() => mainDishes;
  List<OrderItem> getAddOns() => addOns;

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
    'is_main_dish': isMainDish,
    'image_url': imageUrl,
  };
}
