import 'package:get/get.dart';

import '../../screens/search/controller/search_controller.dart';

class SearchBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchController());
  }
}
