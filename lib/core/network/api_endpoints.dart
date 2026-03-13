mixin Urls {
  static const String baseUrl =
      'https://eatplek-server-dev-production.up.railway.app/';

  // Auth
  static const String login = 'api/users/send-otp';
  static const String verifyOtp = 'api/users/verify-otp';
  static const String addUserDetails = 'api/users/profile';

  //Home
  static const String getHomeUrl = 'api/users/app/home';
  static const String getRestaurantDetailsUrl = 'api/vendors/';

  // Vendors (Search + View All)
  static const String getVendorsUrl = 'api/users/app/vendors';

  //Cart
  static const String getCartUrl = 'api/cart';
  static const String addOrUpdateCartUrl = 'api/cart/items';
  static const String deleteCartItemUrl = 'api/cart/items/';
  static const String placeOrderUrl = 'api/bookings';
  static const String fetchAddOnsUrl = 'api/cart/items/';
  static const String clearCartUrl = 'api/cart';

  //Coupons
  static const String getCouponsUrl = 'api/coupons/user/list';
  static const String validateCouponUrl = 'api/coupons/validate';
  static const String applyCouponUrl = 'api/coupons/apply';
  static const String removeCouponUrl = 'api/coupons/remove';

  // Orders
  static const String getordersUrl = 'api/bookings/my-orders';

  //Profile
  static const String getProfileUrl = 'api/users/me/profile';

  //referal
  static const String getReferralUrl = 'api/users/me/referral';
  //api/users/me/referral
}
