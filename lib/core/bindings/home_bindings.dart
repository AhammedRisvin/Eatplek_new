import 'package:eatplek_app/screens/bottom_nav/controller/bottom_nav_controller.dart';
import 'package:eatplek_app/screens/cart/controller/cart_controller.dart';
import 'package:eatplek_app/screens/cart/controller/cart_extra_controller.dart';
import 'package:eatplek_app/screens/home/controller/home_controller.dart';
import 'package:eatplek_app/screens/orders/controller/orders_controller.dart';
import 'package:get/get.dart';

import '../../screens/notification/cotroller/notification_controller.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<BottomNavController>(() => BottomNavController());
    Get.lazyPut<OrdersController>(() => OrdersController());
    Get.put<CartController>(CartController());
    Get.put<CartExtrasController>(CartExtrasController());
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
