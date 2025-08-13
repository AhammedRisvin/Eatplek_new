import 'package:get/get.dart';

import '../model/country_model.dart';

class CountryController extends GetxController {
  String india = "India";

  Map<String, Object> country = {};

  void countryChanged(
    Map<String, Object> country,
    String filteredCountryNam,
  ) async {
    this.country = country;
    india = filteredCountryNam;
    update();
  }

  int numberValidate() {
    if (country["numberLength"] == null) {
      return 10;
    }
    return int.tryParse("${country["numberLength"]}") ?? 1;
  }

  @override
  void onInit() {
    super.onInit();
    country = countryMap[india] ?? {};
  }
}
