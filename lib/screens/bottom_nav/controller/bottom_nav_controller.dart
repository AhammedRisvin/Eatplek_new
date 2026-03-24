import 'package:eatplek_app/screens/cart/controller/cart_controller.dart';
import 'package:eatplek_app/screens/cart/controller/cart_service.dart';
import 'package:eatplek_app/screens/orders/controller/orders_controller.dart';
import 'package:eatplek_app/screens/profile/controller/profile_controller.dart';
import 'package:get/get.dart';

class BottomNavController extends GetxController {
  int currentIndex = 0;

  static const int _ordersTabIndex = 1;
  static const int _cartTabIndex = 2;
  static const int _profileTabIndex = 3;

  void setBottomBarIndex(int index) {
    final previousIndex = currentIndex;
    currentIndex = index;
    update(['currentIndex']);

    if (index == _cartTabIndex && previousIndex != _cartTabIndex) {
      Get.find<CartService>().onCartViewEntered();
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().fetchCartData();
      }
    } else if (index != _cartTabIndex && previousIndex == _cartTabIndex) {
      Get.find<CartService>().onCartViewExited();
    }
    if (index == _ordersTabIndex && previousIndex != _ordersTabIndex) {
      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().fetchFirstTabIfNeeded();
      }
    }

    if (index == _profileTabIndex && previousIndex != _profileTabIndex) {
      try {
        Get.find<ProfileController>().fetchProfile();
      } catch (_) {}
    }
  }
}
