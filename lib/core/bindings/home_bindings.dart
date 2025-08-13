import 'package:eatplek_app/core/bindings/orders_bindings.dart';
import 'package:eatplek_app/screens/bottom_nav/controller/bottom_nav_controller.dart';
import 'package:eatplek_app/screens/home/controller/home_controller.dart';
import 'package:eatplek_app/screens/profile/controller/profile_controller.dart';
import 'package:get/get.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<OrdersBindings>(() => OrdersBindings());
    Get.lazyPut<BottomNavController>(() => BottomNavController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
