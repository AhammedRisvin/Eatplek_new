import 'package:eatplek_app/core/bindings/auth_bindings.dart';
import 'package:eatplek_app/core/bindings/order_details_bindings.dart';
import 'package:eatplek_app/core/bindings/restaurant_detail_view_bindings.dart';
import 'package:eatplek_app/core/bindings/search_bindings.dart';
import 'package:eatplek_app/screens/cart/view/cart_view.dart';
import 'package:eatplek_app/screens/home/view/home_view.dart';
import 'package:eatplek_app/screens/order_confirmation_view/view/order_confirmation_view.dart';
import 'package:eatplek_app/screens/order_details_view/view/order_details_view.dart';
import 'package:eatplek_app/screens/order_success_view.dart/view/order_success_view.dart';
import 'package:eatplek_app/screens/orders/view/orders_view.dart';
import 'package:eatplek_app/screens/profile/view/profile_view.dart';
import 'package:eatplek_app/screens/restaurant_detail_view/view/restaurant_detail_view.dart';
import 'package:eatplek_app/screens/search/view/search_view.dart';
import 'package:get/get.dart';

import '../../screens/auth/view/login_view.dart';
import '../../screens/bottom_nav/view/bottom_nav_view.dart';
import '../../screens/on_boarding_view/view/on_boarding_view.dart';
import '../../screens/splash_view/view/splash_screen.dart';
import '../bindings/cart_bindings.dart';
import '../bindings/home_bindings.dart';
import '../bindings/order_confirmation_bindings.dart';
import '../bindings/orders_bindings.dart';

class Routes {
  static const splash = '/';
  static const login = '/login';

  static const onBoardingView = '/onBoardingView';

  static const home = '/home';
  static const bottomNav = '/bottomNav';

  static const restaurantDetail = '/restaurantDetail';
  static const foodDetailsView = '/foodDetailsView';
  static const cartView = '/cartView';
  static const orderConfirmationView = '/orderConfirmationView';
  static const orderSuccessView = '/orderSuccessView';
  static const ordersView = '/ordersView';
  static const orderDetailsView = '/orderDetailsView';
  static const profileView = '/profileView';
  static const searchView = '/searchView';

  static const String initialRoute = splash;

  static final routes = [
    GetPage(name: initialRoute, page: () => const SplashScreen(), transition: Transition.fade),
    // GetPage(name: bottomNav, page: () => const Example(), transition: Transition.circularReveal),
    GetPage(name: login, page: () => const AuthView(), transition: Transition.fade, binding: AuthBindings()),
    GetPage(name: onBoardingView, page: () => const OnBoardingView(), transition: Transition.circularReveal),
    GetPage(name: home, page: () => const HomeView(), transition: Transition.circularReveal, binding: HomeBindings()),

    GetPage(
      name: restaurantDetail,
      page: () => const RestaurantDetailView(),
      transition: Transition.circularReveal,
      binding: RestaurantDetailViewBindings(),
    ),
    GetPage(
      name: bottomNav,
      page: () => const BottomNavView(),
      transition: Transition.circularReveal,
      binding: HomeBindings(),
    ),
    GetPage(
      name: cartView,
      page: () => const CartView(),
      transition: Transition.circularReveal,
      binding: CartBindings(),
    ),
    GetPage(
      name: orderConfirmationView,
      page: () => const OrderConfirmationView(),
      transition: Transition.circularReveal,
      binding: OrderConfirmationBindings(),
    ),
    GetPage(name: orderSuccessView, page: () => const OrderSuccessView(), transition: Transition.circularReveal),
    GetPage(
      name: ordersView,
      page: () => const OrdersView(),
      transition: Transition.circularReveal,
      binding: OrdersBindings(),
    ),
    GetPage(
      name: orderDetailsView,
      page: () => const OrderDetailsView(),
      transition: Transition.circularReveal,
      binding: OrderDetailsBindings(),
    ),
    GetPage(
      name: profileView,
      page: () => const ProfileView(),
      transition: Transition.circularReveal,
      binding: HomeBindings(),
    ),
    GetPage(
      name: searchView,
      page: () => const SearchView(),
      transition: Transition.circularReveal,
      binding: SearchBindings(),
    ),

    //OrderDetailsBindings
  ];
}
