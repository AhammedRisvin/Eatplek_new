class RestuarantDetailsModel {
  bool? status;
  String? message;
  String? service;
  List<RestuarantDetailsData>? data;
  List<String>? banners;

  RestuarantDetailsModel({this.status, this.message, this.service, this.data, this.banners});

  factory RestuarantDetailsModel.fromJson(Map<String, dynamic> json) => RestuarantDetailsModel(
    status: json["status"],
    message: json["message"],
    service: json["service"],
    data:
        json["data"] == null
            ? []
            : List<RestuarantDetailsData>.from(json["data"]!.map((x) => RestuarantDetailsData.fromJson(x))),
    banners: json["banners"] == null ? [] : List<String>.from(json["banners"]!.map((x) => x)),
  );
}

class RestuarantDetailsData {
  String? category;
  List<Food>? foods;

  RestuarantDetailsData({this.category, this.foods});

  factory RestuarantDetailsData.fromJson(Map<String, dynamic> json) => RestuarantDetailsData(
    category: json["category"],
    foods: json["foods"] == null ? [] : List<Food>.from(json["foods"]!.map((x) => Food.fromJson(x))),
  );
}

class Food {
  String? foodName;
  String? foodId;
  String? foodImage;
  num? actualPrice;
  num? discountPrice;
  dynamic specialOfferPrice;
  num? foodPrice;
  num? cartCount;
  List<Customization>? customizations;
  List<AddOn>? addOns;

  Food({
    this.foodName,
    this.foodId,
    this.foodImage,
    this.actualPrice,
    this.discountPrice,
    this.specialOfferPrice,
    this.foodPrice,
    this.cartCount,
    this.customizations,
    this.addOns,
  });

  factory Food.fromJson(Map<String, dynamic> json) => Food(
    foodName: json["foodName"],
    foodId: json["foodId"],
    foodImage: json["foodImage"],
    actualPrice: json["actualPrice"],
    discountPrice: json["discountPrice"],
    specialOfferPrice: json["specialOfferPrice"],
    foodPrice: json["foodPrice"],
    cartCount: json["cartCount"],
    customizations:
        json["customizations"] == null
            ? []
            : List<Customization>.from(json["customizations"]!.map((x) => Customization.fromJson(x))),
    addOns: json["addOns"] == null ? [] : List<AddOn>.from(json["addOns"]!.map((x) => AddOn.fromJson(x))),
  );
}

class AddOn {
  String? addOnId;
  String? id;
  String? name;
  num? price;
  String? image;
  dynamic imageKitFileId;

  AddOn({this.addOnId, this.id, this.name, this.price, this.image, this.imageKitFileId});

  factory AddOn.fromJson(Map<String, dynamic> json) => AddOn(
    addOnId: json["addOnId"],
    id: json["id"],
    name: json["name"],
    price: json["price"],
    image: json["image"],
    imageKitFileId: json["imageKitFileId"],
  );
}

class Customization {
  String? customizationId;
  String? id;
  String? name;
  num? price;

  Customization({this.customizationId, this.id, this.name, this.price});

  factory Customization.fromJson(Map<String, dynamic> json) =>
      Customization(customizationId: json["customizationId"], id: json["id"], name: json["name"], price: json["price"]);
}
