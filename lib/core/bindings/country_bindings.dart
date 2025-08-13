import 'package:get/get.dart';

import '../../core/util/country_picker/controller/country_controller.dart';

class CountryBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CountryController>(() => CountryController());
  }
}
