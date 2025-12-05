mixin Urls {
  static const String baseUrl = 'https://api-dev.eatplek.com/';

  // Auth
  static const String login = 'api/users/send-otp';
  static const String verifyOtp = 'api/users/verify-otp';
  static const String addUserDetails = 'api/users/profile';

  //Home
  static const String getHomeUrl = 'api/users/app/home';
  static const String getRestaurantDetailsUrl = 'api/vendors/';

  //Cart
  static const String getCartUrl = 'api/cart';
  static const String addOrUpdateCartUrl = 'api/cart/items';
  static const String deleteCartItemUrl = 'api/cart/items/';
  static const String placeOrderUrl = 'api/bookings';

  //removeFromCartUrl

  //
}
