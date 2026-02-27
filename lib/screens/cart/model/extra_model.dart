// To parse this JSON data, do
//
//     final extraModel = extraModelFromJson(jsonString);

import 'dart:convert';

ExtraModel extraModelFromJson(String str) =>
    ExtraModel.fromJson(json.decode(str));

String extraModelToJson(ExtraModel data) => json.encode(data.toJson());

class ExtraModel {
  bool? success;
  String? message;
  ExtraData? data;

  ExtraModel({this.success, this.message, this.data});

  factory ExtraModel.fromJson(Map<String, dynamic> json) => ExtraModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : ExtraData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class ExtraData {
  String? foodId;
  String? foodName;
  List<ExtraItem>? addOns;
  List<ExtraItem>? customizations;

  ExtraData({this.foodId, this.foodName, this.addOns, this.customizations});

  factory ExtraData.fromJson(Map<String, dynamic> json) => ExtraData(
    foodId: json["foodId"],
    foodName: json["foodName"],
    addOns:
        json["addOns"] == null
            ? []
            : List<ExtraItem>.from(
              json["addOns"]!.map((x) => ExtraItem.fromJson(x)),
            ),
    customizations:
        json["customizations"] == null
            ? []
            : List<ExtraItem>.from(
              json["customizations"]!.map((x) => ExtraItem.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "foodId": foodId,
    "foodName": foodName,
    "addOns":
        addOns == null
            ? []
            : List<dynamic>.from(addOns!.map((x) => x.toJson())),
    "customizations":
        customizations == null
            ? []
            : List<dynamic>.from(customizations!.map((x) => x.toJson())),
  };

  bool get isEmpty =>
      (addOns == null || addOns!.isEmpty) &&
      (customizations == null || customizations!.isEmpty);
}

class ExtraItem {
  String? id;
  String? name;
  int? price;
  String? image;

  ExtraItem({this.id, this.name, this.price, this.image});

  factory ExtraItem.fromJson(Map<String, dynamic> json) => ExtraItem(
    id: json["id"],
    name: json["name"],
    price: json["price"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "image": image,
  };
}
