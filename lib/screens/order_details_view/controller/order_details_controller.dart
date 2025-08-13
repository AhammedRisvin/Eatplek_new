import 'package:eatplek_app/screens/order_details_view/model/order_details_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../order_confirmation_view/controller/order_confirmation_controller.dart';

class OrderDetailsController extends GetxController {
  OrderDetailsModel? _order;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  OrderDetailsModel? get order => _order;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  @override
  void onInit() {
    super.onInit();
    loadOrderDetails();
  }

  // Load order details (mock data for now)
  void loadOrderDetails() {
    _isLoading = true;
    update(['loading']);

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _order = _getMockOrder();
      _isLoading = false;
      _errorMessage = '';
      update(['order_details', 'loading']);
    });
  }

  // Get formatted order date and time
  String getFormattedOrderDateTime() {
    if (_order?.orderDateTime == null) return '';
    final DateFormat formatter = DateFormat('dd-MM-yyyy , hh:mm a');
    return formatter.format(_order!.orderDateTime);
  }

  // Get main dishes list
  List<OrderItem> getMainDishes() {
    return _order?.mainDishes ?? [];
  }

  // Get add-ons list
  List<OrderItem> getAddOns() {
    return _order?.addOns ?? [];
  }

  // Get total amount from pricing details
  double getTotalPrice() {
    return _order?.pricingDetails.totalAmount ?? 0.0;
  }

  // Handle phone call
  Future<void> makePhoneCall() async {
    if (_order?.restaurant.phoneNumber == null || _order!.restaurant.phoneNumber.isEmpty) {
      Get.snackbar('Error', 'Phone number not available');
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: _order!.restaurant.phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar('Error', 'Could not open phone dialer');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not make phone call: ${e.toString()}');
    }
  }

  // Handle SMS
  Future<void> sendSMS() async {
    if (_order?.restaurant.phoneNumber == null || _order!.restaurant.phoneNumber.isEmpty) {
      Get.snackbar('Error', 'Phone number not available');
      return;
    }

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: _order!.restaurant.phoneNumber,
      queryParameters: {'body': 'Hello, I have a question about my order ${_order!.orderId}'},
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        Get.snackbar('Error', 'Could not open SMS app');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not send SMS: ${e.toString()}');
    }
  }

  // Handle track order
  void trackOrder() {
    // Implement tracking logic here
    Get.snackbar('Track Order', 'Opening tracking details...');
    // You can navigate to tracking page or show bottom sheet
  }

  // Handle cancel order
  Future<void> cancelOrder() async {
    if (_order?.canCancel != true) {
      Get.snackbar('Error', 'Order cannot be cancelled at this time');
      return;
    }

    // Show confirmation dialog
    final bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('No')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Yes, Cancel')),
        ],
      ),
    );

    if (confirm == true) {
      // Implement cancel order API call here
      Get.snackbar('Success', 'Order has been cancelled');
      // You might want to navigate back or refresh the order status
    }
  }

  // Open Google Maps for location
  Future<void> openGoogleMaps() async {
    if (_order?.restaurant.latitude == null || _order?.restaurant.longitude == null) {
      Get.snackbar('Error', 'Location not available');
      return;
    }

    final double lat = _order!.restaurant.latitude;
    final double lng = _order!.restaurant.longitude;

    final Uri googleMapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    try {
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Could not open Google Maps');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not open Google Maps: ${e.toString()}');
    }
  }

  // Mock order data
  OrderDetailsModel _getMockOrder() {
    return OrderDetailsModel(
      orderId: '123456789',
      orderStatus: 'Preparing',
      orderDateTime: DateTime(2025, 9, 21, 11, 30),
      estimatedDeliveryTime: 'Arriving in 25 mins',
      estimatedDeliveryMinutes: 25,
      restaurant: Restaurant(
        id: 'rest_001',
        name: 'Pizza Palace',
        address: 'Calicut, Kannur, Kerala',
        imageUrl: 'https://picsum.photos/250?image=30',
        phoneNumber: '+919876543210',
        email: 'info@pizzapalace.com',
        latitude: 11.2588,
        longitude: 75.7804,
        rating: 4.5,
        cuisine: 'Italian',
        isActive: true,
      ),
      mainDishes: [
        OrderItem(
          id: 'dish_001',
          name: 'Margherita Pizza',
          price: 299.0,
          quantity: 2,
          imageUrl: 'https://picsum.photos/250?image=31',
          isMainDish: true,
        ),
        OrderItem(
          id: 'dish_002',
          name: 'Chicken Supreme',
          price: 399.0,
          quantity: 1,
          imageUrl: 'https://picsum.photos/250?image=32',
          isMainDish: true,
        ),
      ],
      addOns: [
        OrderItem(
          id: 'addon_001',
          name: 'Extra Cheese',
          price: 50.0,
          quantity: 2,
          imageUrl: 'https://picsum.photos/250?image=33',
          isMainDish: false,
        ),
        OrderItem(
          id: 'addon_002',
          name: 'Garlic Bread',
          price: 120.0,
          quantity: 1,
          imageUrl: 'https://picsum.photos/250?image=34',
          isMainDish: false,
        ),
      ],
      pricingDetails: PricingDetails(
        subtotal: 1217.0,
        deliveryFee: 40.0,
        taxAmount: 121.7,
        taxPercentage: 10.0,
        packingCharge: 20.0,
        promoDiscount: 50.0,
        totalAmount: 1348.7,
        currency: 'INR',
      ),
      additionalNotes:
          'Additional note is the note of the order that the user can add to the order. Especially a additional preference of the user could be added here.',
      deliveryAddress: DeliveryAddress(
        id: 'addr_001',
        addressLine1: '123 Main Street',
        addressLine2: 'Apartment 4B',
        city: 'Kozhikode',
        state: 'Kerala',
        zipCode: '673001',
        country: 'India',
        latitude: 11.2588,
        longitude: 75.7804,
        addressType: 'Home',
        landmark: 'Near City Mall',
      ),
      promoCode: 'SAVE50',
      canCancel: true,
      paymentMethod: 'Credit Card',
      paymentStatus: 'Paid',
      trackingInfo: TrackingInfo(
        currentStatus: 'Preparing',
        orderPlacedAt: DateTime(2025, 9, 21, 11, 30),
        orderConfirmedAt: DateTime(2025, 9, 21, 11, 35),
        preparationStartedAt: DateTime(2025, 9, 21, 11, 40),
        readyForPickupAt: null,
        outForDeliveryAt: null,
        deliveredAt: null,
        driverName: null,
        driverPhone: null,
        vehicleNumber: null,
      ),
    );
  }

  // Refresh order data
  void refreshOrder() {
    loadOrderDetails();
  }
}
