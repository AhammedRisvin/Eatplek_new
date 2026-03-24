class CartModel {
  bool? success;
  String? message;
  CartData? data;

  CartModel({this.success, this.message, this.data});

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : CartData.fromJson(json["data"]),
  );
}

class CartData {
  String? id;
  String? cartCode;
  String? user;
  String? serviceType;
  bool? isPrebookCart;
  Vendor? vendor;
  List<CartItem>? items;
  String? couponCode;
  Totals? totals;
  DateTime? lastUpdatedAt;
  bool? isCartOwner;
  List<FriendInvitation>? friendInvitations;

  CartData({
    this.id,
    this.cartCode,
    this.user,
    this.serviceType,
    this.isPrebookCart,
    this.vendor,
    this.items,
    this.couponCode,
    this.totals,
    this.lastUpdatedAt,
    this.isCartOwner,
    this.friendInvitations,
  });

  factory CartData.fromJson(Map<String, dynamic> json) => CartData(
    id: json["id"],
    cartCode: json["cartCode"],
    user: json["user"],
    serviceType: json["serviceType"],
    isPrebookCart: json["isPrebookCart"],
    vendor: json["vendor"] == null ? null : Vendor.fromJson(json["vendor"]),
    items:
        json["items"] == null
            ? []
            : List<CartItem>.from(
              json["items"]!.map((x) => CartItem.fromJson(x)),
            ),
    couponCode: json["couponCode"],
    totals: json["totals"] == null ? null : Totals.fromJson(json["totals"]),
    lastUpdatedAt:
        json["lastUpdatedAt"] == null
            ? null
            : DateTime.parse(json["lastUpdatedAt"]),
    isCartOwner: json["isCartOwner"],
    friendInvitations:
        json["friendInvitations"] == null
            ? []
            : List<FriendInvitation>.from(
              json["friendInvitations"]!.map(
                (x) => FriendInvitation.fromJson(x),
              ),
            ),
  );
}

class CartItem {
  String? id;
  String? foodId;
  String? foodName;
  String? foodImage;
  String? foodType;
  int? quantity;
  double? basePrice;
  double? discountPrice;
  double? effectivePrice;
  List<AddOn>? customizations;
  List<AddOn>? addOns;
  bool? isPrebook;
  int? packingCharge;
  double? itemTotal;
  dynamic notes;

  CartItem({
    this.id,
    this.foodId,
    this.foodName,
    this.foodImage,
    this.foodType,
    this.quantity,
    this.basePrice,
    this.discountPrice,
    this.effectivePrice,
    this.customizations,
    this.addOns,
    this.isPrebook,
    this.packingCharge,
    this.itemTotal,
    this.notes,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json["id"],
    foodId: json["foodId"],
    foodName: json["foodName"],
    foodImage: json["foodImage"],
    foodType: json["foodType"],
    quantity: json["quantity"],
    basePrice: json["basePrice"]?.toDouble(),
    discountPrice: json["discountPrice"]?.toDouble(),
    effectivePrice: json["effectivePrice"]?.toDouble(),
    customizations:
        json["customizations"] == null
            ? []
            : List<AddOn>.from(
              json["customizations"]!.map((x) => AddOn.fromJson(x)),
            ),
    addOns:
        json["addOns"] == null
            ? []
            : List<AddOn>.from(json["addOns"]!.map((x) => AddOn.fromJson(x))),
    isPrebook: json["isPrebook"],
    packingCharge: json["packingCharge"],
    itemTotal: json["itemTotal"]?.toDouble(),
    notes: json["notes"],
  );
}

class AddOn {
  String? addOnId;
  String? name;
  int? price;
  int? quantity;
  String? customizationId;

  AddOn({
    this.addOnId,
    this.name,
    this.price,
    this.quantity,
    this.customizationId,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) => AddOn(
    addOnId: json["addOnId"],
    name: json["name"],
    price: json["price"],
    quantity: json["quantity"],
    customizationId: json["customizationId"],
  );
}

class Totals {
  double? subTotal;
  int? addOnTotal;
  int? customizationTotal;
  int? packingChargeTotal;
  int? discountTotal;
  int? couponDiscount;
  double? taxAmount;
  int? taxPercentage;
  double? grandTotal;
  int? itemCount;

  Totals({
    this.subTotal,
    this.addOnTotal,
    this.customizationTotal,
    this.packingChargeTotal,
    this.discountTotal,
    this.couponDiscount,
    this.taxAmount,
    this.taxPercentage,
    this.grandTotal,
    this.itemCount,
  });

  factory Totals.fromJson(Map<String, dynamic> json) => Totals(
    subTotal: json["subTotal"]?.toDouble(),
    addOnTotal: json["addOnTotal"],
    customizationTotal: json["customizationTotal"],
    packingChargeTotal: json["packingChargeTotal"],
    discountTotal: json["discountTotal"],
    couponDiscount: json["couponDiscount"],
    taxAmount: json["taxAmount"]?.toDouble(),
    taxPercentage: json["taxPercentage"],
    grandTotal: json["grandTotal"]?.toDouble(),
    itemCount: json["itemCount"],
  );
}

class Vendor {
  String? id;
  String? name;
  String? profileImage;
  String? place;
  int? gstPercentage;

  Vendor({
    this.id,
    this.name,
    this.profileImage,
    this.place,
    this.gstPercentage,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
    id: json["id"],
    name: json["name"],
    profileImage: json["profileImage"],
    place: json["place"],
    gstPercentage: json["gstPercentage"],
  );
}

class FriendInvitation {
  String? inviteId;
  String? inviteeName;
  String? inviteePhone;
  String? inviteeProfileImage;
  String? status;
  DateTime? expiresAt;

  FriendInvitation({
    this.inviteId,
    this.inviteeName,
    this.inviteePhone,
    this.inviteeProfileImage,
    this.status,
    this.expiresAt,
  });

  factory FriendInvitation.fromJson(Map<String, dynamic> json) =>
      FriendInvitation(
        inviteId: json["inviteId"],
        inviteeName: json["inviteeName"],
        inviteePhone: json["inviteePhone"],
        inviteeProfileImage: json["inviteeProfileImage"],
        status: json["status"],
        expiresAt:
            json["expiresAt"] == null
                ? null
                : DateTime.parse(json["expiresAt"]),
      );
}
