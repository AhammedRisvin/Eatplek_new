class UserProfileModel {
  bool? success;
  String? message;
  UserData? data;

  UserProfileModel({this.success, this.message, this.data});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : UserData.fromJson(json["data"]),
      );
}

class UserData {
  String? id;
  String? name;
  String? dialCode;
  String? phone;
  String? profileImage;
  bool? profileComplete;
  String? district;
  String? state;
  String? place;
  Location? location;
  bool? isActive;
  DateTime? memberSince;

  UserData({
    this.id,
    this.name,
    this.dialCode,
    this.phone,
    this.profileImage,
    this.profileComplete,
    this.district,
    this.state,
    this.place,
    this.location,
    this.isActive,
    this.memberSince,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json["id"],
    name: json["name"],
    dialCode: json["dialCode"],
    phone: json["phone"],
    profileImage: json["profileImage"],
    profileComplete: json["profileComplete"],
    district: json["district"],
    state: json["state"],
    place: json["place"],
    location:
        json["location"] == null ? null : Location.fromJson(json["location"]),
    isActive: json["isActive"],
    memberSince:
        json["memberSince"] == null
            ? null
            : DateTime.parse(json["memberSince"]),
  );

  UserData copyWith({
    String? id,
    String? name,
    String? dialCode,
    String? phone,
    String? profileImage,
    bool? profileComplete,
    String? district,
    String? state,
    String? place,
    Location? location,
    bool? isActive,
    DateTime? memberSince,
  }) {
    return UserData(
      id: id ?? this.id,
      name: name ?? this.name,
      dialCode: dialCode ?? this.dialCode,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      profileComplete: profileComplete ?? this.profileComplete,
      district: district ?? this.district,
      state: state ?? this.state,
      place: place ?? this.place,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}

class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
  );
}
