class GetCouponsModel {
  bool? success;
  String? message;
  List<CouponData>? data;

  GetCouponsModel({this.success, this.message, this.data});

  factory GetCouponsModel.fromJson(Map<String, dynamic> json) =>
      GetCouponsModel(
        success: json["success"],
        message: json["message"],
        data:
            json["data"] == null
                ? []
                : List<CouponData>.from(
                  json["data"]!.map((x) => CouponData.fromJson(x)),
                ),
      );
}

class CouponData {
  String? id;
  String? code;
  String? createdBy;
  String? createdByAdmin;
  String? createdByVendor;
  String? vendor;
  VendorDetails? vendorDetails;
  String? discountType;
  int? discountValue;
  int? maxDiscountAmount;
  int? minOrderAmount;
  bool? isOneTimeUse;
  int? usageLimit;
  int? usedCount;
  DateTime? expiresAt;
  bool? isActive;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;

  CouponData({
    this.id,
    this.code,
    this.createdBy,
    this.createdByAdmin,
    this.createdByVendor,
    this.vendor,
    this.vendorDetails,
    this.discountType,
    this.discountValue,
    this.maxDiscountAmount,
    this.minOrderAmount,
    this.isOneTimeUse,
    this.usageLimit,
    this.usedCount,
    this.expiresAt,
    this.isActive,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory CouponData.fromJson(Map<String, dynamic> json) => CouponData(
    id: json["id"],
    code: json["code"],
    createdBy: json["createdBy"],
    createdByAdmin: json["createdByAdmin"],
    createdByVendor: json["createdByVendor"],
    vendor: json["vendor"],
    vendorDetails:
        json["vendorDetails"] == null
            ? null
            : VendorDetails.fromJson(json["vendorDetails"]),
    discountType: json["discountType"],
    discountValue: json["discountValue"],
    maxDiscountAmount: json["maxDiscountAmount"],
    minOrderAmount: json["minOrderAmount"],
    isOneTimeUse: json["isOneTimeUse"],
    usageLimit: json["usageLimit"],
    usedCount: json["usedCount"],
    expiresAt:
        json["expiresAt"] == null ? null : DateTime.parse(json["expiresAt"]),
    isActive: json["isActive"],
    description: json["description"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );
}

class VendorDetails {
  String? id;
  String? name;

  VendorDetails({this.id, this.name});

  factory VendorDetails.fromJson(Map<String, dynamic> json) =>
      VendorDetails(id: json["id"], name: json["name"]);
}
