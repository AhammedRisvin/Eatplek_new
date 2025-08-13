import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/app_color.dart';
import 'package:get/get.dart';

import '../model/restaurant_model.dart';
import '../view/widget/order_preference_dialog.dart';

class HomeController extends GetxController {
  // Carousel properties
  int currentCarouselIndex = 0;
  List<String> carouselImages = [
    'https://picsum.photos/400/180?random=1',
    'https://picsum.photos/400/180?random=2',
    'https://picsum.photos/400/180?random=3',
    'https://picsum.photos/400/180?random=4',
  ];

  // User data
  String userName = 'Ashkar';
  String userLocation = 'Caltex, Kannur, K..';
  String orderPreference = '🛵  Delivery';

  // Restaurant data
  List<RestaurantModel> restaurants = [];
  bool isLoadingRestaurants = false;

  // Update IDs for GetBuilder
  static const String carouselId = 'carousel';
  static const String userGreetingId = 'userGreeting';
  static const String orderPreferenceId = 'orderPreference';
  static const String restaurantsId = 'restaurants';

  @override
  void onInit() {
    super.onInit();
    _initializeRestaurants();
  }

  void updateCarouselIndex(int index) {
    currentCarouselIndex = index;
    update([carouselId]);
  }

  void onSearchTapped() {
    Get.toNamed(Routes.searchView);
  }

  void onNotificationTapped() {
    // Handle notification functionality
    Get.snackbar('Notifications', 'Notification panel opened');
  }

  void onLocationChangeTapped() {
    // Handle location change
    Get.snackbar('Location', 'Change location functionality');
  }

  void updateUserLocation(String newLocation) {
    userLocation = newLocation;
    update([userGreetingId]);
  }

  void updateUserName(String newName) {
    userName = newName;
    update([userGreetingId]);
  }

  void onOrderPreferenceChanged() {
    OrderPreferenceDialog.show(
      currentPreference: orderPreference,
      onPreferenceSelected: (String selectedPreference) {
        updateOrderPreference(selectedPreference);
      },
      title: 'How Would You Like to Order?',
      subtitle: 'Please choose your preferred service to continue.',
    );
  }

  void updateOrderPreference(String newPreference) {
    orderPreference = newPreference;
    Get.back();
    update([orderPreferenceId]);

    // Optional: Show success message
    Get.snackbar(
      'Preference Updated',
      'Your order preference has been changed to $newPreference',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColor.appPrimary.withOpacity(0.1),
      colorText: AppColor.appPrimary,
      duration: const Duration(seconds: 2),
    );
  }

  void onViewAllRestaurants() {
    // Navigate to restaurants list page
    Get.snackbar('Restaurants', 'Navigate to all restaurants');
  }

  void onRestaurantTapped(RestaurantModel restaurant) {
    Get.toNamed(Routes.restaurantDetail);
  }

  void _initializeRestaurants() {
    isLoadingRestaurants = true;
    update([restaurantsId]);

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 500), () {
      restaurants = List.generate(10, (index) {
        return RestaurantModel(
          id: index.toString(),
          name: 'Restaurant Name $index',
          location: 'Caltext, Kannur',
          rating: 4.5,
          imageUrl: 'https://picsum.photos/250?image=${index + 1}',
          isOpen: index != 1 && index != 3, // Close restaurants at index 1 and 3
          openingTime: '10:00 AM',
          closingTime: '10:00 PM',
        );
      });
      isLoadingRestaurants = false;
      update([restaurantsId]);
    });
  }

  void refreshRestaurants() {
    _initializeRestaurants();
  }

  void toggleRestaurantStatus(String restaurantId) {
    final index = restaurants.indexWhere((r) => r.id == restaurantId);
    if (index != -1) {
      restaurants[index] = RestaurantModel(
        id: restaurants[index].id,
        name: restaurants[index].name,
        location: restaurants[index].location,
        rating: restaurants[index].rating,
        imageUrl: restaurants[index].imageUrl,
        isOpen: !restaurants[index].isOpen,
        openingTime: restaurants[index].openingTime,
        closingTime: restaurants[index].closingTime,
      );
      update([restaurantsId]);
    }
  }

  void updateCarouselImages(List<String> newImages) {
    carouselImages = newImages;
    currentCarouselIndex = 0;
    update([carouselId]);
  }
}
