import 'package:get/get.dart';

import '../../screens/search/controller/search_controller.dart';

class SearchVendorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchVendorController>(() => SearchVendorController());
  }
}
