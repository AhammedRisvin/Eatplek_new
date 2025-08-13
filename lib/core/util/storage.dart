import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static const _userToken = "userToken";

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

  static String get userToken => _preference.getString(_userToken) ?? '';
  static set userToken(String value) =>
      _preference.setString(_userToken, value);

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
}
