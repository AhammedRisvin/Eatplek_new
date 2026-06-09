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
import 'package:eatplek_app/screens/pre_book_details_view/view/pre_book_details_view.dart';
import 'package:eatplek_app/screens/profile/view/profile_view.dart';
import 'package:eatplek_app/screens/restaurant_detail_view/view/restaurant_detail_view.dart';
import 'package:eatplek_app/screens/search/view/search_view.dart';
import 'package:get/get.dart';

import '../../screens/auth/view/login_view.dart';
import '../../screens/auth/view/profile_completion_view.dart';
import '../../screens/bottom_nav/view/bottom_nav_view.dart';
import '../../screens/coupons/view/coupons_view.dart';
import '../../screens/location_picker_view/view/location_picker_view.dart';
import '../../screens/notification/view/notification_view.dart';
import '../../screens/on_boarding_view/view/on_boarding_view.dart';
import '../../screens/refer_view/view/refer_view.dart';
import '../../screens/splash_view/view/splash_screen.dart';
import '../bindings/cart_bindings.dart';
import '../bindings/home_bindings.dart';
import '../bindings/location_picker_bindings.dart';
import '../bindings/notification_bindings.dart';
import '../bindings/order_confirmation_bindings.dart';
import '../bindings/orders_bindings.dart';
import '../bindings/pre_book_details_bindings.dart';
import '../bindings/profile_completion_bindings.dart';
import '../bindings/refer_bindings.dart';

class Routes {
  static const splash = '/';
  static const login = '/login';

  static const onBoardingView = '/onBoardingView';

  static const home = '/home';
  static const bottomNav = '/bottomNav';

  static const profileCompletion = '/profileCompletion';

  static const restaurantDetail = '/restaurantDetail';
  static const preBookDetailView = '/preBookDetailView';
  static const cartView = '/cartView';
  static const orderConfirmationView = '/orderConfirmationView';
  static const orderSuccessView = '/orderSuccessView';
  static const ordersView = '/ordersView';
  static const orderDetailsView = '/orderDetailsView';
  static const profileView = '/profileView';
  static const searchView = '/searchView';
  static const couponsView = '/couponsView';
  static const referScreen = '/referScreen';
  static const locationPickerView = '/locationPickerView';
  static const notificationView = '/notificationView';

  static const String initialRoute = splash;

  static final routes = [
    GetPage(
      name: initialRoute,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: login,
      page: () => const AuthView(),
      transition: Transition.fade,
      binding: AuthBindings(),
    ),
    GetPage(
      name: onBoardingView,
      page: () => const OnBoardingView(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: home,
      page: () => const HomeView(),
      transition: Transition.circularReveal,
      binding: HomeBindings(),
    ),

    // ── Profile completion — owns its own controller, fully independent
    //    of AuthController. No shared state, no lifecycle dependency.
    GetPage(
      name: profileCompletion,
      page: () => const ProfileCompletionScreen(),
      transition: Transition.fadeIn,
      binding: ProfileCompletionBinding(),
    ),

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
    GetPage(
      name: orderSuccessView,
      page: () => const OrderSuccessView(),
      transition: Transition.circularReveal,
    ),
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
    ),
    GetPage(
      name: searchView,
      page: () => const SearchVendorView(),
      transition: Transition.circularReveal,
      binding: SearchVendorBinding(),
    ),
    GetPage(
      name: preBookDetailView,
      page: () => const PrebookDetailView(),
      transition: Transition.circularReveal,
      binding: PreBookDetailsBindings(),
    ),
    GetPage(
      name: couponsView,
      page: () => const CouponsView(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: referScreen,
      page: () => ReferScreen(),
      transition: Transition.circularReveal,
      binding: ReferBindings(),
    ),
    GetPage(
      name: locationPickerView,
      page: () => const LocationPickerView(),
      transition: Transition.circularReveal,
      binding: LocationPickerBindings(),
    ),
    GetPage(
      name: notificationView,
      page: () => const NotificationView(),
      transition: Transition.circularReveal,
      binding: NotificationBinding(),
    ),
  ];
}
