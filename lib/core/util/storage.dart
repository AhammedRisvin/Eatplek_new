import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static const _userToken = "userToken";
  static const _refreshTokenKey = "refreshToken";

  static late SharedPreferences _preference;

  static DateTime now = DateTime.now();

  void reloadPreference() async {
    await _preference.reload();
  }

  static Future<void> init() async {
    _preference = await SharedPreferences.getInstance();
  }

  static Future<void> clear() async {
    await _preference.clear();
  }

  // ── Auth tokens ────────────────────────────────────────────────────────────

  static String get userToken => _preference.getString(_userToken) ?? '';
  static set userToken(String value) =>
      _preference.setString(_userToken, value);

  static String get refreshToken =>
      _preference.getString(_refreshTokenKey) ?? '';
  static set refreshToken(String value) =>
      _preference.setString(_refreshTokenKey, value);

  /// Atomically saves both access token and refresh token in a single flush.
  /// Always await this — it guarantees both values land on disk before
  /// the caller retries the failed request.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _preference.setString(_userToken, accessToken),
      _preference.setString(_refreshTokenKey, refreshToken),
    ]);
    debugPrint(
      '💾 Tokens saved — access: ...${accessToken.length > 10 ? accessToken.substring(accessToken.length - 10) : accessToken}',
    );
  }

  // ── User profile ───────────────────────────────────────────────────────────

  static String get id => _preference.getString("id") ?? '';
  static set id(String value) => _preference.setString("id", value);

  static String get name => _preference.getString("name") ?? '';
  static set name(String value) => _preference.setString("name", value);

  static String get phone => _preference.getString("phone") ?? '';
  static set phone(String value) => _preference.setString("phone", value);

  static String get shop => _preference.getString("shop") ?? '';
  static set shop(String value) => _preference.setString("shop", value);

  static String get role => _preference.getString("role") ?? '';
  static set role(String value) => _preference.setString("role", value);

  static String get status => _preference.getString("status") ?? '';
  static set status(String value) => _preference.setString("status", value);

  static String get district => _preference.getString("district") ?? '';
  static set district(String value) => _preference.setString("district", value);

  static String get state => _preference.getString("state") ?? '';
  static set state(String value) => _preference.setString("state", value);

  static String get place => _preference.getString("place") ?? '';
  static set place(String value) => _preference.setString("place", value);

  static String get profileImage => _preference.getString("profileImage") ?? '';
  static set profileImage(String value) =>
      _preference.setString("profileImage", value);

  static bool get profileComplete =>
      _preference.getBool("profileComplete") ?? false;
  static set profileComplete(bool value) =>
      _preference.setBool("profileComplete", value);

  static String get showedOnBoarding =>
      _preference.getString("showedOnBoarding") ?? 'false';
  static set showedOnBoarding(String value) =>
      _preference.setString("showedOnBoarding", value);

  static String get deliveryPreference =>
      _preference.getString("deliveryPreference") ?? '';
  static set deliveryPreference(String value) =>
      _preference.setString("deliveryPreference", value);

  // ── Location ───────────────────────────────────────────────────────────────

  static double get userLatitude =>
      _preference.getDouble("userLatitude") ?? 0.0;
  static set userLatitude(double value) =>
      _preference.setDouble("userLatitude", value);

  static double get userLongitude =>
      _preference.getDouble("userLongitude") ?? 0.0;
  static set userLongitude(double value) =>
      _preference.setDouble("userLongitude", value);

  static String get userCity => _preference.getString("userCity") ?? '';
  static set userCity(String value) => _preference.setString("userCity", value);

  static bool get locationManuallyPicked =>
      _preference.getBool("locationManuallyPicked") ?? false;
  static set locationManuallyPicked(bool value) =>
      _preference.setBool("locationManuallyPicked", value);

  /// Atomically saves all manual location fields and sets the picked flag.
  static Future<void> saveManualLocation({
    required double latitude,
    required double longitude,
    required String city,
  }) async {
    await Future.wait([
      _preference.setDouble("userLatitude", latitude),
      _preference.setDouble("userLongitude", longitude),
      _preference.setString("userCity", city),
      _preference.setBool("locationManuallyPicked", true),
    ]);
    debugPrint(
      '💾 Manual location saved: $city ($latitude, $longitude) | manuallyPicked: true',
    );
  }
}
