import 'package:get/get.dart';

class OfferController extends GetxController {
  // Offer categories
  final List<String> offerCategories = ['Dining', 'Take Away', 'Delivery'];
  int selectedCategoryIndex = 0; // Default selected index

  // Mock restaurant data

  final List<RestaurantOffer> restaurants = [
    RestaurantOffer(
      id: 1,
      name: 'Nibraz Restaurant Poonoor',
      location: 'Calicut, Kannur, Kerala',
      rating: 4.5,
      imageUrl: 'https://picsum.photos/400/200?random=30',
      offerType: 'Delivery',
    ),
    RestaurantOffer(
      id: 2,
      name: 'Spice Garden Restaurant',
      location: 'Kozhikode, Kerala',
      rating: 4.2,
      imageUrl: 'https://picsum.photos/400/200?random=31',
      offerType: 'Dining',
    ),
    RestaurantOffer(
      id: 3,
      name: 'Ocean View Cafe',
      location: 'Malappuram, Kerala',
      rating: 4.7,
      imageUrl: 'https://picsum.photos/400/200?random=32',
      offerType: 'Take Away',
    ),
  ];

  // Filter restaurants based on selected category
  List<RestaurantOffer> get filteredRestaurants {
    final selectedCategory = offerCategories[selectedCategoryIndex];
    return restaurants.where((restaurant) => restaurant.offerType == selectedCategory).toList();
  }

  // Update selected category
  void updateSelectedCategory(int index) {
    selectedCategoryIndex = index;
    update(['category_list', 'restaurant_list']);
  }
}

// Model class for restaurant offers
class RestaurantOffer {
  final int id;
  final String name;
  final String location;
  final double rating;
  final String imageUrl;
  final String offerType;

  RestaurantOffer({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.imageUrl,
    required this.offerType,
  });
}
