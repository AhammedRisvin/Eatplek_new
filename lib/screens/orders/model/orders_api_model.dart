class OrdersApiModel {
  bool? success;
  String? message;
  OrderData? data;

  OrdersApiModel({this.success, this.message, this.data});

  factory OrdersApiModel.fromJson(Map<String, dynamic> json) => OrdersApiModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : OrderData.fromJson(json["data"]),
  );
}

class OrderData {
  List<SingleOrder>? orders;
  Pagination? pagination;

  OrderData({this.orders, this.pagination});

  factory OrderData.fromJson(Map<String, dynamic> json) => OrderData(
    orders:
        json["orders"] == null
            ? []
            : List<SingleOrder>.from(
              json["orders"]!.map((x) => SingleOrder.fromJson(x)),
            ),
    pagination:
        json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
  );
}

class SingleOrder {
  String? id;
  String? orderStatus;
  String? serviceType;
  bool? isPrebook;
  ServiceDetails? serviceDetails;
  dynamic notes;
  User? user;
  Vendor? vendor;
  CartSnapshot? cartSnapshot;
  AmountSummary? amountSummary;
  DateTime? vendorResponseAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? paymentStatus;
  PaymentDetails? paymentDetails;
  List<TrackingStep>? trackingSteps;
  RejectionDetails? rejectionDetails;

  SingleOrder({
    this.id,
    this.orderStatus,
    this.serviceType,
    this.isPrebook,
    this.serviceDetails,
    this.notes,
    this.user,
    this.vendor,
    this.cartSnapshot,
    this.amountSummary,
    this.vendorResponseAt,
    this.createdAt,
    this.updatedAt,
    this.paymentStatus,
    this.paymentDetails,
    this.trackingSteps,
    this.rejectionDetails,
  });

  factory SingleOrder.fromJson(Map<String, dynamic> json) => SingleOrder(
    id: json["id"],
    orderStatus: json["orderStatus"],
    serviceType: json["serviceType"],
    isPrebook: json["isPrebook"],
    serviceDetails:
        json["serviceDetails"] == null
            ? null
            : ServiceDetails.fromJson(json["serviceDetails"]),
    notes: json["notes"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    vendor: json["vendor"] == null ? null : Vendor.fromJson(json["vendor"]),
    cartSnapshot:
        json["cartSnapshot"] == null
            ? null
            : CartSnapshot.fromJson(json["cartSnapshot"]),
    amountSummary:
        json["amountSummary"] == null
            ? null
            : AmountSummary.fromJson(json["amountSummary"]),
    vendorResponseAt:
        json["vendorResponseAt"] == null
            ? null
            : DateTime.parse(json["vendorResponseAt"]),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    paymentStatus: json["paymentStatus"],
    paymentDetails:
        json["paymentDetails"] == null
            ? null
            : PaymentDetails.fromJson(json["paymentDetails"]),
    trackingSteps:
        json["trackingSteps"] == null
            ? []
            : List<TrackingStep>.from(
              json["trackingSteps"]!.map((x) => TrackingStep.fromJson(x)),
            ),
    rejectionDetails:
        json["rejectionDetails"] == null
            ? null
            : RejectionDetails.fromJson(json["rejectionDetails"]),
  );
}

class AmountSummary {
  int? subTotal;
  int? addOnTotal;
  int? customizationTotal;
  int? packingChargeTotal;
  int? discountTotal;
  int? couponDiscount;
  int? taxAmount;
  int? taxPercentage;
  int? grandTotal;
  int? itemCount;

  AmountSummary({
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

  factory AmountSummary.fromJson(Map<String, dynamic> json) => AmountSummary(
    subTotal: json["subTotal"],
    addOnTotal: json["addOnTotal"],
    customizationTotal: json["customizationTotal"],
    packingChargeTotal: json["packingChargeTotal"],
    discountTotal: json["discountTotal"],
    couponDiscount: json["couponDiscount"],
    taxAmount: json["taxAmount"],
    taxPercentage: json["taxPercentage"],
    grandTotal: json["grandTotal"],
    itemCount: json["itemCount"],
  );
}

class CartSnapshot {
  String? cartId;
  List<Item>? items;
  AmountSummary? totals;

  CartSnapshot({this.cartId, this.items, this.totals});

  factory CartSnapshot.fromJson(Map<String, dynamic> json) => CartSnapshot(
    cartId: json["cartId"],
    items:
        json["items"] == null
            ? []
            : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    totals:
        json["totals"] == null ? null : AmountSummary.fromJson(json["totals"]),
  );
}

class Item {
  Food? food;
  String? foodName;
  String? foodImage;
  String? foodType;
  int? quantity;
  int? basePrice;
  int? discountPrice;
  int? effectivePrice;
  List<AddOn>? customizations;
  List<AddOn>? addOns;
  bool? isPrebook;
  int? packingCharge;
  int? itemTotal;
  dynamic notes;

  Item({
    this.food,
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

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    food: json["food"] == null ? null : Food.fromJson(json["food"]),
    foodName: json["foodName"],
    foodImage: json["foodImage"],
    foodType: json["foodType"],
    quantity: json["quantity"],
    basePrice: json["basePrice"],
    discountPrice: json["discountPrice"],
    effectivePrice: json["effectivePrice"],
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
    itemTotal: json["itemTotal"],
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

class Food {
  String? id;
  String? foodName;
  String? type;
  String? foodImage;
  dynamic discountPercentage;
  String? foodId;

  Food({
    this.id,
    this.foodName,
    this.type,
    this.foodImage,
    this.discountPercentage,
    this.foodId,
  });

  factory Food.fromJson(Map<String, dynamic> json) => Food(
    id: json["_id"],
    foodName: json["foodName"],
    type: json["type"],
    foodImage: json["foodImage"],
    discountPercentage: json["discountPercentage"],
    foodId: json["id"],
  );
}

class PaymentDetails {
  dynamic transactionId;
  dynamic providerReferenceId;
  int? amount;
  dynamic paymentMethod;
  dynamic paidAt;

  PaymentDetails({
    this.transactionId,
    this.providerReferenceId,
    this.amount,
    this.paymentMethod,
    this.paidAt,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) => PaymentDetails(
    transactionId: json["transactionId"],
    providerReferenceId: json["providerReferenceId"],
    amount: json["amount"],
    paymentMethod: json["paymentMethod"],
    paidAt: json["paidAt"],
  );
}

class RejectionDetails {
  String? rejectionReason;
  DateTime? suggestedTime;
  List<dynamic>? modifiedItems;
  bool? hasPartialRejection;
  bool? hasTimeSuggestion;

  RejectionDetails({
    this.rejectionReason,
    this.suggestedTime,
    this.modifiedItems,
    this.hasPartialRejection,
    this.hasTimeSuggestion,
  });

  factory RejectionDetails.fromJson(Map<String, dynamic> json) =>
      RejectionDetails(
        rejectionReason: json["rejectionReason"],
        suggestedTime:
            json["suggestedTime"] == null
                ? null
                : DateTime.parse(json["suggestedTime"]),
        modifiedItems:
            json["modifiedItems"] == null
                ? []
                : List<dynamic>.from(json["modifiedItems"]!.map((x) => x)),
        hasPartialRejection: json["hasPartialRejection"],
        hasTimeSuggestion: json["hasTimeSuggestion"],
      );
}

class ServiceDetails {
  dynamic address;
  dynamic latitude;
  dynamic longitude;
  dynamic name;
  dynamic phoneNumber;
  dynamic personCount;
  DateTime? reachTime;
  dynamic vehicleDetails;

  ServiceDetails({
    this.address,
    this.latitude,
    this.longitude,
    this.name,
    this.phoneNumber,
    this.personCount,
    this.reachTime,
    this.vehicleDetails,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) => ServiceDetails(
    address: json["address"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    name: json["name"],
    phoneNumber: json["phoneNumber"],
    personCount: json["personCount"],
    reachTime:
        json["reachTime"] == null ? null : DateTime.parse(json["reachTime"]),
    vehicleDetails: json["vehicleDetails"],
  );
}

class TrackingStep {
  String? status;
  String? label;
  String? description;
  bool? completed;
  bool? active;

  TrackingStep({
    this.status,
    this.label,
    this.description,
    this.completed,
    this.active,
  });

  factory TrackingStep.fromJson(Map<String, dynamic> json) => TrackingStep(
    status: json["status"],
    label: json["label"],
    description: json["description"],
    completed: json["completed"],
    active: json["active"],
  );
}

class User {
  String? id;
  dynamic name;
  dynamic phone;
  dynamic dialCode;
  dynamic userCode;

  User({this.id, this.name, this.phone, this.dialCode, this.userCode});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    dialCode: json["dialCode"],
    userCode: json["userCode"],
  );
}

class Vendor {
  String? id;
  String? name;
  int? gstPercentage;

  Vendor({this.id, this.name, this.gstPercentage});

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
    id: json["id"],
    name: json["name"],
    gstPercentage: json["gstPercentage"],
  );
}

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json["total"],
    page: json["page"],
    limit: json["limit"],
    totalPages: json["totalPages"],
  );
}
