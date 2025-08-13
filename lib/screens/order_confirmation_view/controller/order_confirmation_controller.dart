import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/util/app_color.dart';
import '../view/widget/custom_calender_widget.dart';
import '../view/widget/payment_bottom_sheet.dart';

class OrderConfirmationController extends GetxController {
  // Form Controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final guestCountController = TextEditingController(text: '1');
  final deliveryDateController = TextEditingController();

  // Form Keys for validation
  final formKey = GlobalKey<FormState>();

  // Date variables
  DateTime? selectedDate;

  // Time variables
  int selectedHour = 12;
  int selectedMinute = 0;
  String selectedPeriod = 'PM'; // AM or PM

  // Error message for time validation
  String? timeErrorMessage;

  // Restaurant operating hours (24-hour format)
  static const int restaurantOpenHour = 9; // 9 AM
  static const int restaurantCloseHour = 23; // 11 PM

  // Guest count constraints
  static const int minGuests = 1;
  static const int maxGuests = 30;
  int guestCount = 1;

  // Calendar Controller
  late CalendarController calendarController;

  // Sample order data - replace with your actual data structure
  List<OrderItem> orderItems = [
    OrderItem(
      id: '1',
      name: 'Chicken Biriyani',
      price: 250.0,
      quantity: 2,
      isMainDish: true,
      imageUrl: 'https://picsum.photos/250?image=30',
    ),
    OrderItem(
      id: '2',
      name: 'Extra Raita',
      price: 50.0,
      quantity: 0, // Add-ons don't have quantity
      isMainDish: false,
      imageUrl: 'https://picsum.photos/250?image=31',
    ),
    OrderItem(
      id: '3',
      name: 'Fish Curry',
      price: 180.0,
      quantity: 1,
      isMainDish: true,
      imageUrl: 'https://picsum.photos/250?image=32',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    calendarController = Get.put(CalendarController());
    _setDefaultTime();
    _setDefaultDate();
  }

  void _setDefaultDate() {
    // Set default date to today
    selectedDate = DateTime.now();
    deliveryDateController.text = _formatDate(selectedDate!);
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Date selection method for calendar
  bool isDateSelectable(DateTime date) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final twoMonthsFromToday = DateTime(today.year, today.month + 2, today.day);

    // Allow selection from today up to 2 months from today
    return (dateOnly.isAfter(todayOnly) || dateOnly.isAtSameMomentAs(todayOnly)) &&
        dateOnly.isBefore(twoMonthsFromToday);
  }

  void showCalendarDialog() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: CustomCalendarWidget(
            onDateSelected: (date) {
              selectedDate = date;
              deliveryDateController.text = _formatDate(date);
              Navigator.of(context).pop();
              update(['date_field']);
            },
            primaryColor: AppColor.appPrimary,
            backgroundColor: Colors.grey[100],
          ),
        );
      },
    );
  }

  void _setDefaultTime() {
    final now = DateTime.now();
    final minimum30MinLater = now.add(const Duration(minutes: 30));
    // Check if 30 minutes from now is still within restaurant hours
    if (minimum30MinLater.hour >= restaurantOpenHour && minimum30MinLater.hour < restaurantCloseHour) {
      // Set to 30 minutes from now, rounded to nearest 15 minutes
      final futureHour = minimum30MinLater.hour;
      final futureMinute = minimum30MinLater.minute;
      selectedHour = futureHour > 12 ? futureHour - 12 : (futureHour == 0 ? 12 : futureHour);
      selectedMinute = ((futureMinute + 14) ~/ 15) * 15; // Round up to nearest 15 minutes
      // Handle minute overflow
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
      // Restaurant is closed for the rest of the day, set to opening time
      selectedHour = 9;
      selectedMinute = 0;
      selectedPeriod = 'AM';
    }
    _validateTime();
  }

  // Time manipulation methods
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
      return; // Skip validation here as incrementHour already calls it
    }
    _validateTime();
    update(['time_widget']);
  }

  void decrementMinute() {
    selectedMinute -= 15;
    if (selectedMinute < 0) {
      selectedMinute = 45;
      decrementHour();
      return; // Skip validation here as decrementHour already calls it
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
    // First check if restaurant is closed at selected time
    if (selectedHour24 < restaurantOpenHour || selectedHour24 >= restaurantCloseHour) {
      timeErrorMessage = 'Restaurant is closed. Restaurant hours: 9:00 AM - 11:00 PM';
      return;
    }
    // Then check if selected time is at least 30 minutes from now
    if (selectedDateTime.isBefore(minimumTime)) {
      timeErrorMessage = 'Please select a time at least 30 minutes from current time';
      return;
    }
    // If we reach here, time is valid
    timeErrorMessage = null;
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
    // Always use today's date for the selected time
    return DateTime(now.year, now.month, now.day, _convertTo24Hour(), selectedMinute);
  }

  String getFormattedTime() {
    return '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')} $selectedPeriod';
  }

  bool isTimeValid() {
    _validateTime();
    return timeErrorMessage == null;
  }

  // Guest count methods
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

  // Validation methods
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
    // Remove any spaces or special characters
    final cleanedPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    // Check if it's a valid Indian phone number
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
      return 'Please enter a complete address';
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

  String? validateDeliveryDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a delivery date';
    }
    return null;
  }

  // Calculate total price
  double getTotalPrice() {
    return orderItems.fold(0.0, (sum, item) {
      if (item.isMainDish) {
        return sum + (item.price * item.quantity);
      } else {
        return sum + item.price; // Add-ons have fixed price
      }
    });
  }

  // Get main dishes
  List<OrderItem> getMainDishes() {
    return orderItems.where((item) => item.isMainDish).toList();
  }

  // Get add-ons
  List<OrderItem> getAddOns() {
    return orderItems.where((item) => !item.isMainDish).toList();
  }

  // Confirm order
  void confirmOrder() {
    // Validate time before proceeding
    if (!isTimeValid()) {
      Get.snackbar(
        'Invalid Time',
        timeErrorMessage ?? 'Please select a valid time',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (formKey.currentState?.validate() ?? false) {
      // Process the order
      Get.snackbar('Success', 'Order confirmed successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      // Add your order processing logic here
      _processOrder();
    } else {
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields correctly',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _processOrder() {
    final orderData = {
      'customer': {
        'name': fullNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
      },
      'delivery_date': selectedDate?.toIso8601String(),
      'dining_time': getFormattedTime(),
      'guest_count': guestCount,
      'items': orderItems,
      'total_price': getTotalPrice(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: AppColor.scaffoldColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))),
      builder: (context) {
        return PaymentBottomSheet(controller: this);
      },
    );
    // Send to your backend API
  }

  //Payment Selection
  List paymentMethods = [
    {
      'id': '1',
      'name': 'Credit/Debit Card',
      'imageUrl': 'https://picsum.photos/50?image=10',
      'Description': 'Pay securely with your card',
    },
    {
      'id': '2',
      'name': 'UPI',
      'imageUrl': 'https://picsum.photos/50?image=11',
      'Description': 'Pay instantly using UPI',
    },
    {
      'id': '3',
      'name': 'Net Banking',
      'imageUrl': 'https://picsum.photos/50?image=12',
      'Description': 'Secure online banking payment',
    },
  ];
  int selectedPaymentMethodIndex = 0;
  void selectPaymentMethod(int index) {
    selectedPaymentMethodIndex = index;
    update(['payment_method']);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    guestCountController.dispose();
    deliveryDateController.dispose();
    Get.delete<CalendarController>();
    super.onClose();
  }
}

// Order Item Model
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
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      isMainDish: json['is_main_dish'],
      imageUrl: json['image_url'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'is_main_dash': isMainDish,
      'image_url': imageUrl,
    };
  }
}
