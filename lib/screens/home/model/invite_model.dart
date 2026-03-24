class InviteModel {
  final bool? success;
  final String? message;
  final List<InviteData>? data;

  InviteModel({this.success, this.message, this.data});

  factory InviteModel.fromJson(Map<String, dynamic> json) {
    return InviteModel(
      success: json['success'],
      message: json['message'],
      data:
          json['data'] != null
              ? (json['data'] as List)
                  .map((e) => InviteData.fromJson(e))
                  .toList()
              : [],
    );
  }
}

class InviteData {
  final String? inviteId;
  final String? cartCode;
  final String? status;
  final String? expiresAt;
  final InviteInviter? inviter;
  final InviteVendor? vendor;
  final InviteCart? cart;

  InviteData({
    this.inviteId,
    this.cartCode,
    this.status,
    this.expiresAt,
    this.inviter,
    this.vendor,
    this.cart,
  });

  factory InviteData.fromJson(Map<String, dynamic> json) {
    return InviteData(
      inviteId: json['inviteId'],
      cartCode: json['cartCode'],
      status: json['status'],
      expiresAt: json['expiresAt'],
      inviter:
          json['inviter'] != null
              ? InviteInviter.fromJson(json['inviter'])
              : null,
      vendor:
          json['vendor'] != null ? InviteVendor.fromJson(json['vendor']) : null,
      cart: json['cart'] != null ? InviteCart.fromJson(json['cart']) : null,
    );
  }
}

class InviteInviter {
  final String? id;
  final String? name;
  final String? phone;
  final String? profileImage;

  InviteInviter({this.id, this.name, this.phone, this.profileImage});

  factory InviteInviter.fromJson(Map<String, dynamic> json) {
    return InviteInviter(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      profileImage: json['profileImage'],
    );
  }
}

class InviteVendor {
  final String? id;
  final String? name;
  final String? address;

  InviteVendor({this.id, this.name, this.address});

  factory InviteVendor.fromJson(Map<String, dynamic> json) {
    return InviteVendor(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }
}

class InviteCart {
  final String? cartCode;
  final String? serviceType;
  final int? itemCount;
  final num? grandTotal;

  InviteCart({
    this.cartCode,
    this.serviceType,
    this.itemCount,
    this.grandTotal,
  });

  factory InviteCart.fromJson(Map<String, dynamic> json) {
    return InviteCart(
      cartCode: json['cartCode'],
      serviceType: json['serviceType'],
      itemCount: json['itemCount'],
      grandTotal: json['grandTotal'],
    );
  }
}
