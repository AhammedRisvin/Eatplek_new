import 'package:eatplek_app/screens/cart/controller/cart_controller.dart';
import 'package:eatplek_app/screens/cart/controller/cart_service.dart';
import 'package:eatplek_app/screens/offer_view/controller/offer_controller.dart';
import 'package:eatplek_app/screens/orders/controller/orders_controller.dart';
import 'package:eatplek_app/screens/profile/controller/profile_controller.dart';
import 'package:get/get.dart';

class BottomNavController extends GetxController {
  int currentIndex = 0;

  static const int _ordersTabIndex = 1;
  static const int _offerTabIndex = 2;
  static const int _cartTabIndex = 3;
  static const int _profileTabIndex = 4;

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
        Get.find<OrdersController>().startPolling();
      }
    } else if (index != _ordersTabIndex && previousIndex == _ordersTabIndex) {
      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().stopPolling();
      }
    }

    if (index == _offerTabIndex) {
      if (Get.isRegistered<OfferController>()) {
        Get.find<OfferController>().refreshFromHome();
      }
    }

    if (index == _profileTabIndex && previousIndex != _profileTabIndex) {
      try {
        Get.find<ProfileController>().fetchProfile();
      } catch (_) {}
    }
  }
}
