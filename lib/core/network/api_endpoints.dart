mixin Urls {
  static const String baseUrl = 'https://api-v1.findzzy.com';

  // Auth
  static const String login = '/user/send-otp';
  static const String verifyOtp = '/user/verify-otp';
  static const String register = '/user/register';

  //Home
  static const String home = '/user/get-home';

  // Calender
  static const String getEvents = '/vendor/get-event';
  static const String deleteEvents = '/vendor/deleteEvent';
  static const String createEvent = '/vendor/add-event';
  static const String editEventUrl = '/vendor/update-event';
  static const String offEvents = "/vendor/off-full-day";

  // Categories
  static const String getSubCategoryUrl = '/user/get-sub-categories';

  //view all
  static const String getGadgetsUrl = '/user/get-gadget';
  static const String getRentalServicesUrl = '/user/get-rental-services';

  // Profile
  static const String getProfileUrl = '/user/get-profile';
  static const String editProfileUrl = '/user/update-profile';

  // Help Desk
  static const String createHelpDesk = '/vendor/create-help-desk';
  static const String getHelpDesk = '/vendor/get-help-desk';
  static const String deleteHelpDesk = '/vendor/deleteEvent';
  static const String updateHelpDesk = '/vendor/change-help-desk-status';

  // Share Availability

  static const String createShareAvailability = '/vendor/create-share-and-availability';
  static const String getShareAvailability = '/vendor/get-share-and-availability';
  static const String updateShareAvailability = "/vendor/change-share-and-availability-status";

  // Renatal And Gadgets
  static const String getRentalAndGadgetCategories = "/user/get-rentalAndGadget-categories";
  static const createGadgeOrRental = "/user/create-ad";

  //Get Vendors and filter
  static const String getVendorsUrl = '/user/get-vendors';
  static const String getCategoriesUrl = '/user/get-categories';
  static const String getCameraBrandUrl = '/user/get-all-cameras';
  static const String getMyAds = '/user/get-my-ads';
  static const String onOrOffAds = '/user/addAvailability-rental-service';
  static const String deleteAds = '/user/delete-ad';
  static const String markAsSold = '/user/mark-as-gadgetSold';

  // Add Vendor Details
  static const String saveVendorDetailsUrl = '/vendor/add-details';

  //Plans and Payment
  static const String getPlansUrl = '/user/get-artist-plans';
  static const String payNowUrl = '/user/purchase-artist-plan';

  //Add Album
  static const String addAlbumUrl = '/vendor/create-album';
  static const String getAlbumUrl = '/vendor/get-my-album';

  // Get Seller Details
  static const String getSellerDetailsUrl = '/user/get-seller-details';

  // Whislist
  static const String getWhislistUrl = '/user/get-wish-list';

  static const String getWishlistUrl = '/user/get-wish-list';
  static const String addOrRemoveWhislistUrl = '/user/wishlist';

  // Get Vendor Details
  static const String getVendorDetailsUrl = '/user/get-vendor-details';

  // Notification url
  static const String getNotificationUrl = '/user/get-notification';

  // Get Sub Category For Filter
  static const String getSubCategoryForFilter = '/user/get-all-subCategories-based-on-multiple-category';
}
