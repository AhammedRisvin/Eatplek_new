import 'package:eatplek_app/screens/restaurant_detail_view/controller/restaurant_detail_view_controller.dart';
import 'package:get/get.dart';

import '../../screens/cart/controller/cart_service.dart';

class RestaurantDetailViewBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RestaurantDetailViewController>(() => RestaurantDetailViewController());
    Get.lazyPut<CartService>(() => CartService());
  }
}
