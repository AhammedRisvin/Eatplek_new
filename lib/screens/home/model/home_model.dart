class HomeModel {
  bool? success;
  String? message;
  HomeData? data;

  HomeModel({this.success, this.message, this.data});

  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : HomeData.fromJson(json["data"]),
  );
}

class HomeData {
  List<Vendor>? vendors;
  String? currentDay;
  DateTime? currentTime;
  Pagination? pagination;

  HomeData({this.vendors, this.currentDay, this.currentTime, this.pagination});

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
    vendors: json["vendors"] == null ? [] : List<Vendor>.from(json["vendors"]!.map((x) => Vendor.fromJson(x))),
    currentDay: json["currentDay"],
    currentTime: json["currentTime"] == null ? null : DateTime.parse(json["currentTime"]),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalCount;
  int? limit;
  bool? hasNextPage;
  bool? hasPrevPage;

  Pagination({this.currentPage, this.totalPages, this.totalCount, this.limit, this.hasNextPage, this.hasPrevPage});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["currentPage"],
    totalPages: json["totalPages"],
    totalCount: json["totalCount"],
    limit: json["limit"],
    hasNextPage: json["hasNextPage"],
    hasPrevPage: json["hasPrevPage"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "totalPages": totalPages,
    "totalCount": totalCount,
    "limit": limit,
    "hasNextPage": hasNextPage,
    "hasPrevPage": hasPrevPage,
  };
}

class Vendor {
  String? id;
  String? restaurantName;
  String? ownerName;
  String? profileImage;
  String? restaurantImage;
  Address? address;
  List<String>? serviceOffered;
  int? averageRating;
  int? reviewCount;
  dynamic distance;
  dynamic isOpen;
  OperatingHours? operatingHours;
  List<dynamic>? todayOffers;
  List<dynamic>? offerFoods;
  bool? hasTodayOffers;
  List<dynamic>? prebookFoods;

  Vendor({
    this.id,
    this.restaurantName,
    this.ownerName,
    this.profileImage,
    this.restaurantImage,
    this.address,
    this.serviceOffered,
    this.averageRating,
    this.reviewCount,
    this.distance,
    this.isOpen,
    this.operatingHours,
    this.todayOffers,
    this.offerFoods,
    this.hasTodayOffers,
    this.prebookFoods,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
    id: json["id"],
    restaurantName: json["restaurantName"],
    ownerName: json["ownerName"],
    profileImage: json["profileImage"],
    restaurantImage: json["restaurantImage"],
    address: json["address"] == null ? null : Address.fromJson(json["address"]),
    serviceOffered: json["serviceOffered"] == null ? [] : List<String>.from(json["serviceOffered"]!.map((x) => x)),
    averageRating: json["averageRating"],
    reviewCount: json["reviewCount"],
    distance: json["distance"],
    isOpen: json["isOpen"],
    operatingHours: json["operatingHours"] == null ? null : OperatingHours.fromJson(json["operatingHours"]),
    todayOffers: json["todayOffers"] == null ? [] : List<dynamic>.from(json["todayOffers"]!.map((x) => x)),
    offerFoods: json["offerFoods"] == null ? [] : List<dynamic>.from(json["offerFoods"]!.map((x) => x)),
    hasTodayOffers: json["hasTodayOffers"],
    prebookFoods: json["prebookFoods"] == null ? [] : List<dynamic>.from(json["prebookFoods"]!.map((x) => x)),
  );
}

class Address {
  Coordinates? coordinates;
  String? fullAddress;
  String? pincode;
  String? city;
  String? state;

  Address({this.coordinates, this.fullAddress, this.pincode, this.city, this.state});

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    coordinates: json["coordinates"] == null ? null : Coordinates.fromJson(json["coordinates"]),
    fullAddress: json["fullAddress"],
    pincode: json["pincode"],
    city: json["city"],
    state: json["state"],
  );
}

class Coordinates {
  String? type;
  List<double>? coordinates;

  Coordinates({this.type, this.coordinates});

  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
    type: json["type"],
    coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
  );
}

class OperatingHours {
  String? day;
  String? openTime;
  String? closeTime;
  bool? isClosed;

  OperatingHours({this.day, this.openTime, this.closeTime, this.isClosed});

  factory OperatingHours.fromJson(Map<String, dynamic> json) => OperatingHours(
    day: json["day"],
    openTime: json["openTime"],
    closeTime: json["closeTime"],
    isClosed: json["isClosed"],
  );
}
