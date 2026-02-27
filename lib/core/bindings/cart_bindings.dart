import 'package:eatplek_app/screens/cart/controller/cart_extra_controller.dart';
import 'package:eatplek_app/screens/cart/controller/cart_service.dart';
import 'package:get/instance_manager.dart';

import '../../screens/cart/controller/cart_controller.dart';

class CartBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<CartService>(() => CartService());
    Get.lazyPut<CartExtrasController>(() => CartExtrasController());
  }
}
