import '../../restaurant_detail_view/model/restaurent_details_model.dart';

class TodayOffersModel {
  final bool success;
  final String message;
  final TodayOffersData? data;

  TodayOffersModel({required this.success, required this.message, this.data});

  factory TodayOffersModel.fromJson(Map<String, dynamic> json) {
    return TodayOffersModel(
      success: json['success'] == true || json['status'] == true,
      message: json['message']?.toString() ?? '',
      data:
          json['data'] is Map<String, dynamic>
              ? TodayOffersData.fromJson(json['data'] as Map<String, dynamic>)
              : null,
    );
  }
}

class TodayOffersData {
  final List<String> availableServices;
  final List<OfferFood> offers;
  final OfferPagination pagination;

  TodayOffersData({
    required this.availableServices,
    required this.offers,
    required this.pagination,
  });

  factory TodayOffersData.fromJson(Map<String, dynamic> json) {
    final rawOffers = json['offers'] ?? json['foods'] ?? json['items'];
    final rawServices =
        json['availableServices'] ?? json['services'] ?? json['serviceTypes'];

    return TodayOffersData(
      availableServices:
          rawServices is List
              ? rawServices.map((item) => item.toString()).toList()
              : [],
      offers:
          rawOffers is List
              ? rawOffers
                  .whereType<Map<String, dynamic>>()
                  .map(OfferFood.fromJson)
                  .toList()
              : [],
      pagination:
          json['pagination'] is Map<String, dynamic>
              ? OfferPagination.fromJson(
                json['pagination'] as Map<String, dynamic>,
              )
              : OfferPagination.empty(),
    );
  }
}

class OfferFood {
  final String id;
  final Food food;
  final String? category;
  final String? vendorId;
  final String? vendorName;
  final String? vendorPlace;
  final double? distanceKm;
  final String? offerLabel;

  OfferFood({
    required this.id,
    required this.food,
    this.category,
    this.vendorId,
    this.vendorName,
    this.vendorPlace,
    this.distanceKm,
    this.offerLabel,
  });

  factory OfferFood.fromJson(Map<String, dynamic> json) {
    final foodJson = _readMap(json['food']) ?? _readMap(json['menuItem']);
    final vendorJson =
        _readMap(json['vendor']) ??
        _readMap(json['restaurant']) ??
        _readMap(json['hotel']);

    final source = <String, dynamic>{
      ...json,
      if (foodJson != null) ...foodJson,
    };
    source['foodId'] ??= source['_id'] ?? source['id'];
    source['foodName'] ??= source['name'] ?? source['title'];
    source['foodImage'] ??= source['image'] ?? source['imageUrl'];
    source['foodPrice'] ??= source['price'];
    source['actualPrice'] ??= source['mrp'] ?? source['originalPrice'];
    source['discountPrice'] ??= source['offerPrice'] ?? source['salePrice'];

    return OfferFood(
      id:
          source['offerId']?.toString() ??
          source['_id']?.toString() ??
          source['id']?.toString() ??
          source['foodId']?.toString() ??
          '',
      food: Food.fromJson(source),
      category: source['category']?.toString(),
      vendorId:
          source['vendorId']?.toString() ??
          vendorJson?['_id']?.toString() ??
          vendorJson?['id']?.toString() ??
          vendorJson?['hotelId']?.toString(),
      vendorName:
          source['vendorName']?.toString() ??
          source['hotelName']?.toString() ??
          source['restaurantName']?.toString() ??
          vendorJson?['hotelName']?.toString() ??
          vendorJson?['restaurantName']?.toString() ??
          vendorJson?['name']?.toString(),
      vendorPlace:
          source['place']?.toString() ??
          source['vendorPlace']?.toString() ??
          vendorJson?['place']?.toString(),
      distanceKm:
          _readDouble(source['distanceKm']) ??
          _readDouble(source['distance']) ??
          _readDouble(source['distanceInKm']) ??
          _readDouble(vendorJson?['distanceKm']) ??
          _readDouble(vendorJson?['distance']) ??
          _readDouble(vendorJson?['distanceInKm']),
      offerLabel:
          source['offerLabel']?.toString() ??
          source['offerTitle']?.toString() ??
          source['title']?.toString() ??
          source['offerType']?.toString(),
    );
  }

  static Map<String, dynamic>? _readMap(dynamic value) {
    return value is Map<String, dynamic> ? value : null;
  }

  static double? _readDouble(dynamic value) {
    if (value is num) return value.toDouble();

    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return null;

    final match = RegExp(r'[\d.]+').firstMatch(raw);
    return double.tryParse(match?.group(0) ?? '');
  }
}

class OfferPagination {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  OfferPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory OfferPagination.fromJson(Map<String, dynamic> json) {
    return OfferPagination(
      currentPage: _toInt(json['currentPage'] ?? json['page'], fallback: 1),
      totalPages: _toInt(json['totalPages']),
      totalCount: _toInt(json['totalCount'] ?? json['total']),
      limit: _toInt(json['limit'], fallback: 20),
      hasNextPage: json['hasNextPage'] == true,
      hasPrevPage: json['hasPrevPage'] == true,
    );
  }

  factory OfferPagination.empty() {
    return OfferPagination(
      currentPage: 1,
      totalPages: 0,
      totalCount: 0,
      limit: 20,
      hasNextPage: false,
      hasPrevPage: false,
    );
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
