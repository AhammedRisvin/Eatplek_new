import 'package:eatplek_app/screens/cart/controller/cart_extra_controller.dart';
import 'package:get/instance_manager.dart';

import '../../screens/cart/controller/cart_controller.dart';

class CartBindings extends Bindings {
  @override
  void dependencies() {
    // CartService is registered permanently in main.dart — just find it here.
    // Do NOT lazyPut it again or it will be re-created and lose polling state.
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<CartExtrasController>(() => CartExtrasController());
  }
}
