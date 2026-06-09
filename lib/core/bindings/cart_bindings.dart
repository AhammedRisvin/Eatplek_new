import 'package:eatplek_app/screens/cart/controller/cart_extra_controller.dart';
import 'package:get/instance_manager.dart';

import '../../screens/cart/controller/cart_controller.dart';

class CartBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CartController>()) {
      Get.put<CartController>(CartController(), permanent: true);
    }
    Get.put<CartExtrasController>(CartExtrasController());
  }
}
