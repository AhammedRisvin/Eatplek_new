import 'package:get/get.dart';

import '../../screens/food_details_view.dart/controller/food_details_view_controller.dart';

class FoodDetailsBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FoodDetailsViewController());
  }
}
