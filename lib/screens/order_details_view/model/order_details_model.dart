import '../../order_confirmation_view/controller/order_confirmation_controller.dart';

class OrderDetailsModel {
  final String orderId;
  final String orderStatus;
  final DateTime orderDateTime;
  final String estimatedDeliveryTime;
  final int estimatedDeliveryMinutes;
  final Restaurant restaurant;
  final List<OrderItem> mainDishes;
  final List<OrderItem> addOns;
  final PricingDetails pricingDetails;
  final String? additionalNotes;
  final DeliveryAddress deliveryAddress;
  final String? promoCode;
  final bool canCancel;
  final String paymentMethod;
  final String paymentStatus;
  final TrackingInfo trackingInfo;

  OrderDetailsModel({
    required this.orderId,
    required this.orderStatus,
    required this.orderDateTime,
    required this.estimatedDeliveryTime,
    required this.estimatedDeliveryMinutes,
    required this.restaurant,
    required this.mainDishes,
    required this.addOns,
    required this.pricingDetails,
    this.additionalNotes,
    required this.deliveryAddress,
    this.promoCode,
    required this.canCancel,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.trackingInfo,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsModel(
      orderId: json['orderId'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      orderDateTime: DateTime.parse(json['orderDateTime'] ?? DateTime.now().toIso8601String()),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] ?? '',
      estimatedDeliveryMinutes: json['estimatedDeliveryMinutes'] ?? 0,
      restaurant: Restaurant.fromJson(json['restaurant'] ?? {}),
      mainDishes: (json['mainDishes'] as List? ?? []).map((item) => OrderItem.fromJson(item)).toList(),
      addOns: (json['addOns'] as List? ?? []).map((item) => OrderItem.fromJson(item)).toList(),
      pricingDetails: PricingDetails.fromJson(json['pricingDetails'] ?? {}),
      additionalNotes: json['additionalNotes'],
      deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress'] ?? {}),
      promoCode: json['promoCode'],
      canCancel: json['canCancel'] ?? false,
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      trackingInfo: TrackingInfo.fromJson(json['trackingInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderStatus': orderStatus,
      'orderDateTime': orderDateTime.toIso8601String(),
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'estimatedDeliveryMinutes': estimatedDeliveryMinutes,
      'restaurant': restaurant.toJson(),
      'mainDishes': mainDishes.map((item) => item.toJson()).toList(),
      'addOns': addOns.map((item) => item.toJson()).toList(),
      'pricingDetails': pricingDetails.toJson(),
      'additionalNotes': additionalNotes,
      'deliveryAddress': deliveryAddress.toJson(),
      'promoCode': promoCode,
      'canCancel': canCancel,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'trackingInfo': trackingInfo.toJson(),
    };
  }
}

class Restaurant {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final String phoneNumber;
  final String email;
  final double latitude;
  final double longitude;
  final double rating;
  final String cuisine;
  final bool isActive;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.phoneNumber,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.cuisine,
    required this.isActive,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      cuisine: json['cuisine'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'cuisine': cuisine,
      'isActive': isActive,
    };
  }
}

class PricingDetails {
  final double subtotal;
  final double deliveryFee;
  final double taxAmount;
  final double taxPercentage;
  final double packingCharge;
  final double promoDiscount;
  final double totalAmount;
  final String currency;

  PricingDetails({
    required this.subtotal,
    required this.deliveryFee,
    required this.taxAmount,
    required this.taxPercentage,
    required this.packingCharge,
    required this.promoDiscount,
    required this.totalAmount,
    required this.currency,
  });

  factory PricingDetails.fromJson(Map<String, dynamic> json) {
    return PricingDetails(
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0.0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0.0).toDouble(),
      taxPercentage: (json['taxPercentage'] ?? 0.0).toDouble(),
      packingCharge: (json['packingCharge'] ?? 0.0).toDouble(),
      promoDiscount: (json['promoDiscount'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'taxAmount': taxAmount,
      'taxPercentage': taxPercentage,
      'packingCharge': packingCharge,
      'promoDiscount': promoDiscount,
      'totalAmount': totalAmount,
      'currency': currency,
    };
  }
}

class DeliveryAddress {
  final String id;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final double latitude;
  final double longitude;
  final String addressType; // Home, Work, Other
  final String? landmark;

  DeliveryAddress({
    required this.id,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.addressType,
    this.landmark,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      addressType: json['addressType'] ?? 'Home',
      landmark: json['landmark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'addressType': addressType,
      'landmark': landmark,
    };
  }

  String get fullAddress {
    return [addressLine1, addressLine2, city, state, zipCode, country].where((part) => part.isNotEmpty).join(', ');
  }
}

class TrackingInfo {
  final String currentStatus;
  final DateTime? orderPlacedAt;
  final DateTime? orderConfirmedAt;
  final DateTime? preparationStartedAt;
  final DateTime? readyForPickupAt;
  final DateTime? outForDeliveryAt;
  final DateTime? deliveredAt;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleNumber;

  TrackingInfo({
    required this.currentStatus,
    this.orderPlacedAt,
    this.orderConfirmedAt,
    this.preparationStartedAt,
    this.readyForPickupAt,
    this.outForDeliveryAt,
    this.deliveredAt,
    this.driverName,
    this.driverPhone,
    this.vehicleNumber,
  });

  factory TrackingInfo.fromJson(Map<String, dynamic> json) {
    return TrackingInfo(
      currentStatus: json['currentStatus'] ?? 'Order Placed',
      orderPlacedAt: json['orderPlacedAt'] != null ? DateTime.parse(json['orderPlacedAt']) : null,
      orderConfirmedAt: json['orderConfirmedAt'] != null ? DateTime.parse(json['orderConfirmedAt']) : null,
      preparationStartedAt: json['preparationStartedAt'] != null ? DateTime.parse(json['preparationStartedAt']) : null,
      readyForPickupAt: json['readyForPickupAt'] != null ? DateTime.parse(json['readyForPickupAt']) : null,
      outForDeliveryAt: json['outForDeliveryAt'] != null ? DateTime.parse(json['outForDeliveryAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      vehicleNumber: json['vehicleNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStatus': currentStatus,
      'orderPlacedAt': orderPlacedAt?.toIso8601String(),
      'orderConfirmedAt': orderConfirmedAt?.toIso8601String(),
      'preparationStartedAt': preparationStartedAt?.toIso8601String(),
      'readyForPickupAt': readyForPickupAt?.toIso8601String(),
      'outForDeliveryAt': outForDeliveryAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleNumber': vehicleNumber,
    };
  }
}
