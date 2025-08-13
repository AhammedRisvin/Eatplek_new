class RestaurantModel {
  final String id;
  final String name;
  final String location;
  final double rating;
  final String imageUrl;
  final bool isOpen;
  final String openingTime;
  final String closingTime;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.imageUrl,
    required this.isOpen,
    required this.openingTime,
    required this.closingTime,
  });
}
