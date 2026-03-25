class NotificationModel {
  bool? success;
  List<Notification>? data;
  bool? hasMore;
  String? nextCursor;

  NotificationModel({this.success, this.data, this.hasMore, this.nextCursor});

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        success: json["success"],
        data:
            json["data"] == null
                ? []
                : List<Notification>.from(
                  json["data"]!.map((x) => Notification.fromJson(x)),
                ),
        hasMore: json["hasMore"],
        nextCursor: json["nextCursor"],
      );
}

class Notification {
  String? id;
  String? userId;
  String? title;
  String? body;
  String? imageUrl;
  NotificationData? data;
  bool? isRead;
  DateTime? createdAt;

  Notification({
    this.id,
    this.userId,
    this.title,
    this.body,
    this.imageUrl,
    this.data,
    this.isRead,
    this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    id: json["_id"],
    userId: json["userId"],
    title: json["title"],
    body: json["body"],
    imageUrl: json["imageUrl"],
    data: json["data"] == null ? null : NotificationData.fromJson(json["data"]),
    isRead: json["isRead"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );
}

class NotificationData {
  String? type;
  String? discount;

  NotificationData({this.type, this.discount});

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(type: json["type"], discount: json["discount"]);
}
