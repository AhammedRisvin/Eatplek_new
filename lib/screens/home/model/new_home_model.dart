class NewHomeModel {
  bool? success;
  String? message;
  Data? data;

  NewHomeModel({this.success, this.message, this.data});

  factory NewHomeModel.fromJson(Map<String, dynamic> json) => NewHomeModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );
}

class Data {
  List<String>? availableServices;
  List<BannerData>? banners;
  List<Vendor>? vendors;
  List<PrebookList>? prebookList;
  List<dynamic>? todayOfferFoods;

  Data({
    this.availableServices,
    this.banners,
    this.vendors,
    this.prebookList,
    this.todayOfferFoods,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    availableServices:
        json["availableServices"] == null
            ? []
            : List<String>.from(json["availableServices"]!.map((x) => x)),
    banners:
        json["banners"] == null
            ? []
            : List<BannerData>.from(
              json["banners"]!.map((x) => BannerData.fromJson(x)),
            ),
    vendors:
        json["vendors"] == null
            ? []
            : List<Vendor>.from(
              json["vendors"]!.map((x) => Vendor.fromJson(x)),
            ),
    prebookList:
        json["prebookList"] == null
            ? []
            : List<PrebookList>.from(
              json["prebookList"]!.map((x) => PrebookList.fromJson(x)),
            ),
    todayOfferFoods:
        json["todayOfferFoods"] == null
            ? []
            : List<dynamic>.from(json["todayOfferFoods"]!.map((x) => x)),
  );
}

class BannerData {
  String? bannerId;
  String? bannerImage;
  bool? isPrebookRelated;
  Hotel? hotel;
  Prebook? prebook;

  BannerData({
    this.bannerId,
    this.bannerImage,
    this.isPrebookRelated,
    this.hotel,
    this.prebook,
  });

  factory BannerData.fromJson(Map<String, dynamic> json) => BannerData(
    bannerId: json["bannerId"],
    bannerImage: json["bannerImage"],
    isPrebookRelated: json["isPrebookRelated"],
    hotel: json["hotel"] == null ? null : Hotel.fromJson(json["hotel"]),
    prebook: json["prebook"] == null ? null : Prebook.fromJson(json["prebook"]),
  );
}

class Hotel {
  String? hotelId;
  String? hotelName;
  String? profileImage;
  String? coverImage;
  String? place;

  Hotel({
    this.hotelId,
    this.hotelName,
    this.profileImage,
    this.coverImage,
    this.place,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) => Hotel(
    hotelId: json["hotelId"],
    hotelName: json["hotelName"],
    profileImage: json["profileImage"],
    coverImage: json["coverImage"],
    place: json["place"],
  );
}

class Prebook {
  String? foodId;
  String? foodName;
  String? foodImage;
  double? basePrice;
  double? discountPrice;
  double? effectivePrice;
  DateTime? prebookStartDate;
  DateTime? prebookEndDate;

  Prebook({
    this.foodId,
    this.foodName,
    this.foodImage,
    this.basePrice,
    this.discountPrice,
    this.effectivePrice,
    this.prebookStartDate,
    this.prebookEndDate,
  });

  factory Prebook.fromJson(Map<String, dynamic> json) => Prebook(
    foodId: json["foodId"],
    foodName: json["foodName"],
    foodImage: json["foodImage"],
    basePrice: json["basePrice"]?.toDouble(),
    discountPrice: json["discountPrice"]?.toDouble(),
    effectivePrice: json["effectivePrice"]?.toDouble(),
    prebookStartDate:
        json["prebookStartDate"] == null
            ? null
            : DateTime.parse(json["prebookStartDate"]),
    prebookEndDate:
        json["prebookEndDate"] == null
            ? null
            : DateTime.parse(json["prebookEndDate"]),
  );
}

class Vendor {
  String? hotelId;
  String? hotelName;
  String? profileImage;
  String? coverImage;
  String? place;
  Location? location;
  bool? isOpenNow;
  Schedule? schedule;
  int? averageRating;
  int? reviewCount;
  List<Vendor>? branchList;

  Vendor({
    this.hotelId,
    this.hotelName,
    this.profileImage,
    this.coverImage,
    this.place,
    this.location,
    this.isOpenNow,
    this.schedule,
    this.averageRating,
    this.reviewCount,
    this.branchList,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
    hotelId: json["restaurantId"], // ← was "hotelId"
    hotelName: json["restaurantName"], // ← was "hotelName"
    profileImage: json["profileImage"],
    coverImage: json["coverImage"],
    place: json["place"],
    isOpenNow: json["isOpenNow"],
    location:
        json["location"] == null ? null : Location.fromJson(json["location"]),
    schedule:
        json["schedule"] == null ? null : Schedule.fromJson(json["schedule"]),
    averageRating: json["averageRating"],
    reviewCount: json["reviewCount"],
    branchList:
        json["branchList"] == null
            ? []
            : List<Vendor>.from(
              json["branchList"]!.map((x) => Vendor.fromJson(x)),
            ),
  );
}

class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}

class PrebookList {
  String? foodId;
  String? foodName;
  String? foodImage;
  String? description;
  double? basePrice;
  double? discountPrice;
  double? effectivePrice;
  DateTime? prebookStartDate;
  DateTime? prebookEndDate;
  String? category;
  Vendor? vendor;

  PrebookList({
    this.foodId,
    this.foodName,
    this.foodImage,
    this.description,
    this.basePrice,
    this.discountPrice,
    this.effectivePrice,
    this.prebookStartDate,
    this.prebookEndDate,
    this.category,
    this.vendor,
  });

  factory PrebookList.fromJson(Map<String, dynamic> json) => PrebookList(
    foodId: json["foodId"],
    foodName: json["foodName"],
    foodImage: json["foodImage"],
    description: json["description"],
    basePrice: json["basePrice"]?.toDouble(),
    discountPrice: json["discountPrice"]?.toDouble(),
    effectivePrice: json["effectivePrice"]?.toDouble(),
    prebookStartDate:
        json["prebookStartDate"] == null
            ? null
            : DateTime.parse(json["prebookStartDate"]),
    prebookEndDate:
        json["prebookEndDate"] == null
            ? null
            : DateTime.parse(json["prebookEndDate"]),
    category: json["category"],
    vendor: json["vendor"] == null ? null : Vendor.fromJson(json["vendor"]),
  );
}

class Schedule {
  String? openTime;
  String? closeTime;
  bool? isClosed;

  Schedule({this.openTime, this.closeTime, this.isClosed});

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    openTime: json["openTime"],
    closeTime: json["closeTime"],
    isClosed: json["isClosed"],
  );

  Map<String, dynamic> toJson() => {
    "openTime": openTime,
    "closeTime": closeTime,
    "isClosed": isClosed,
  };
}
