import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/app_color.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../../core/util/storage.dart';
import '../model/home_model.dart';
import '../view/widget/order_preference_dialog.dart';

class HomeController extends GetxController {
  // Carousel properties - Static for now
  int currentCarouselIndex = 0;
  List<String> carouselImages = [
    'https://picsum.photos/400/180?random=1',
    'https://picsum.photos/400/180?random=2',
    'https://picsum.photos/400/180?random=3',
    'https://picsum.photos/400/180?random=4',
  ];

  // User data
  String userName = 'Ashkar'; // Static for now
  String userCity = 'Kannur'; // Will be updated with actual location
  double userLatitude = 0.0;
  double userLongitude = 0.0;
  String orderPreference = '';

  // Restaurant data from API
  List<Vendor> restaurants = [];
  bool isLoadingRestaurants = false;
  bool isLoadingMore = false;
  bool hasError = false;
  String errorMessage = '';

  // Pagination
  int currentPage = 1;
  int totalPages = 1;
  int limit = 10;
  bool hasNextPage = false;

  // Update IDs for GetBuilder
  static const String carouselId = 'carousel';
  static const String userGreetingId = 'userGreeting';
  static const String orderPreferenceId = 'orderPreference';
  static const String restaurantsId = 'restaurants';

  late FittorConnect _apiClient;
  late ScrollController scrollController;

  // Track if we're already fetching to prevent multiple simultaneous requests
  bool _isFetching = false;

  // Guard against double initialization
  bool _isInitialized = false;

  // Guard to ensure location is fetched before API calls
  bool _locationFetched = false;

  @override
  void onInit() {
    super.onInit();

    // Prevent double initialization
    if (_isInitialized) {
      debugPrint('⚠️ HomeController already initialized, skipping...');
      return;
    }
    _isInitialized = true;

    // Use singleton API client from Get.find() or create new one
    try {
      _apiClient = Get.find<FittorConnect>();
    } catch (e) {
      _apiClient = FittorConnect();
      Get.put<FittorConnect>(_apiClient);
    }

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    debugPrint('🚀 HomeController initialized');

    // Initialize the flow
    _initializeHomeScreen();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  // Initialize home screen - SEQUENTIAL: Location FIRST, then preference
  Future<void> _initializeHomeScreen() async {
    try {
      debugPrint('🔄 Starting initialization sequence...');

      // STEP 1: Fetch location FIRST (mandatory for API calls)
      await _fetchUserLocation();
      _locationFetched = true;
      debugPrint('✅ Location fetched, now checking preference...');

      // STEP 2: Check preference after location is ready
      await _checkAndShowOrderPreference();

      debugPrint('✅ Initialization complete');
    } catch (e) {
      debugPrint('❌ Initialization error: $e');
      _locationFetched = true; // Even if it fails, allow preference check
    }
  }

  // Fetch user's current location
  Future<void> _fetchUserLocation() async {
    try {
      debugPrint('📍 Starting location fetch...');

      // Check if permission was revoked
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

        userLatitude = position.latitude;
        userLongitude = position.longitude;

        debugPrint('✅ Location fetched: Lat=$userLatitude, Long=$userLongitude');

        // Get city name from coordinates (reverse geocoding)
        await _getCityFromCoordinates(position.latitude, position.longitude);

        update([userGreetingId]);
      } else {
        debugPrint('⚠️ Location permission denied - using default location');
        userCity = 'Unknown Location';
        userLatitude = 0.0;
        userLongitude = 0.0;
        update([userGreetingId]);
      }
    } catch (e) {
      debugPrint('❌ Error fetching location: $e');
      userCity = 'Unknown Location';
      update([userGreetingId]);
    }
  }

  // Get city name from latitude and longitude using geolocator
  Future<void> _getCityFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await GeocodingPlatform.instance!.placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        userCity = placemarks.first.locality ?? placemarks.first.administrativeArea ?? 'Unknown Location';
        debugPrint('✅ City resolved: $userCity');
        update([userGreetingId]);
      }
    } catch (e) {
      debugPrint('⚠️ Error getting city: $e');
    }
  }

  // Check if order preference is set, if not show dialog
  Future<void> _checkAndShowOrderPreference() async {
    // Wait until location is fetched
    int retries = 0;
    while (!_locationFetched && retries < 30) {
      await Future.delayed(const Duration(milliseconds: 100));
      retries++;
    }

    String? savedPreference = Store.deliveryPreference;

    debugPrint('🔍 Checking saved preference: "$savedPreference"');

    if (savedPreference.isEmpty) {
      debugPrint('📋 No preference saved - showing dialog');

      // Show dialog - it will be dismissed when user selects
      _showOrderPreferenceDialog();
    } else {
      orderPreference = savedPreference;
      debugPrint('✅ Using saved preference: $orderPreference');
      update([orderPreferenceId]);

      // Fetch restaurants immediately with valid location
      await _fetchRestaurants(isRefresh: true);
    }
  }

  // Show order preference dialog
  void _showOrderPreferenceDialog() {
    OrderPreferenceDialog.show(
      currentPreference: orderPreference,
      onPreferenceSelected: (String selectedPreference) {
        debugPrint('✅ Preference Selected: $selectedPreference');
        updateOrderPreference(selectedPreference);
      },
      title: 'How Would You Like to Order?',
      subtitle: 'Please choose your preferred service to continue.',
    );
  }

  // Update carousel index
  void updateCarouselIndex(int index) {
    currentCarouselIndex = index;
    update([carouselId]);
  }

  // Navigation methods
  void onSearchTapped() {
    Get.toNamed(Routes.searchView);
  }

  void onNotificationTapped() {
    Get.snackbar('Notifications', 'Notification panel opened');
  }

  void onLocationChangeTapped() {
    Get.snackbar('Location', 'Change location functionality');
  }

  // Update order preference and fetch restaurants immediately
  void updateOrderPreference(String newPreference) {
    debugPrint('🎯 Preference selected: $newPreference');

    orderPreference = newPreference;
    Store.deliveryPreference = newPreference;

    Get.back();

    update([orderPreferenceId]);

    // Show snackbar
    Get.snackbar(
      'Preference Updated',
      'Your order preference has been changed to $newPreference',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColor.appPrimary.withOpacity(0.1),
      colorText: AppColor.appPrimary,
      duration: const Duration(seconds: 2),
    );

    // 🆕 Close dialog first
    try {
      if (Get.isDialogOpen ?? false) {
        Get.back();
        debugPrint('✅ Dialog closed');
      }
    } catch (e) {
      debugPrint('⚠️ Error closing dialog: $e');
    }

    // Reset pagination and fetch new data
    currentPage = 1;
    restaurants.clear();
    _fetchRestaurants(isRefresh: true);
  }

  // Change order preference - show dialog
  void onOrderPreferenceChanged() {
    debugPrint('🔄 Change preference tapped');
    _showOrderPreferenceDialog();
  }

  void onViewAllRestaurants() {
    Get.snackbar('Restaurants', 'Navigate to all restaurants');
  }

  void onRestaurantTapped(Vendor restaurant) {
    Get.toNamed(Routes.restaurantDetail);
  }

  // Fetch restaurants from API with proper client handling
  Future<void> _fetchRestaurants({bool isRefresh = false}) async {
    // Prevent multiple simultaneous requests
    if (_isFetching) {
      debugPrint('⚠️ Already fetching - ignoring duplicate request');
      return;
    }

    // Ensure location is fetched before making API call
    if (!_locationFetched) {
      debugPrint('⚠️ Location not fetched yet - waiting...');
      return;
    }

    // Check if we have valid coordinates
    if (userLatitude == 0.0 && userLongitude == 0.0) {
      debugPrint('⚠️ Invalid location coordinates - using default');
    }

    try {
      _isFetching = true;

      if (isRefresh) {
        isLoadingRestaurants = true;
        hasError = false;
        errorMessage = '';
        update([restaurantsId]);
        debugPrint('🔄 Refreshing restaurants (page 1)...');
      } else {
        isLoadingMore = true;
        update([restaurantsId]);
        debugPrint('📜 Loading more restaurants (page $currentPage)...');
      }

      // Extract service type from order preference
      String serviceType = _extractServiceType(orderPreference);

      // Build query string with actual location
      String endpoint =
          "${Urls.getHomeUrl}?serviceOffered=$serviceType&userLatitude=19.076&userLongitude=72.8777&page=$currentPage&limit=$limit";

      debugPrint('🔗 API Endpoint: $endpoint');
      debugPrint('📍 Using coordinates: Lat=$userLatitude, Long=$userLongitude');

      // Make API call with timeout
      final response = await _apiClient
          .get(endpoint: endpoint)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('API request timeout after 30 seconds'),
          );

      if (response != null) {
        debugPrint('✅ API Response received');

        final homeModel = HomeModel.fromJson(response);

        if (homeModel.success == true && homeModel.data != null) {
          if (isRefresh) {
            restaurants = homeModel.data!.vendors ?? [];
          } else {
            restaurants.addAll(homeModel.data!.vendors ?? []);
          }

          // Update pagination info
          final pagination = homeModel.data!.pagination;
          if (pagination != null) {
            currentPage = pagination.currentPage ?? 1;
            totalPages = pagination.totalPages ?? 1;
            hasNextPage = pagination.hasNextPage ?? false;

            debugPrint(
              '📊 Pagination: Page $currentPage/$totalPages | HasNext: $hasNextPage | Total Items: ${restaurants.length}',
            );
          }

          isLoadingRestaurants = false;
          isLoadingMore = false;
          hasError = false;
          update([restaurantsId]);

          debugPrint('✅ Restaurants loaded successfully: ${restaurants.length} items');
        } else {
          _handleApiError(homeModel.message ?? 'Unknown error from server');
        }
      } else {
        _handleApiError('No response from server');
      }
    } on TimeoutException catch (e) {
      _handleApiError('Request timeout. Please check your internet connection.');
      debugPrint('⏱️ Timeout: $e');
    } catch (e) {
      String errorMsg = _parseError(e.toString());
      _handleApiError(errorMsg);
      debugPrint('❌ API Error: $e');
    } finally {
      _isFetching = false;
    }
  }

  // Parse error messages for better UX
  String _parseError(String error) {
    debugPrint('🔍 Parsing error: $error');

    if (error.contains('Client is closed') || error.contains('Bad state')) {
      return 'Connection lost. Please try again.';
    } else if (error.contains('SocketException') || error.contains('Failed host lookup')) {
      return 'Network connection error. Please check your internet.';
    } else if (error.contains('Connection refused')) {
      return 'Could not connect to server. Please try again.';
    } else if (error.contains('TimeoutException') || error.contains('timeout')) {
      return 'Request took too long. Please try again.';
    } else if (error.contains('Connection reset')) {
      return 'Connection interrupted. Please try again.';
    }
    return 'Unable to fetch restaurants. Please try again.';
  }

  // Handle API errors
  void _handleApiError(String message) {
    hasError = true;
    errorMessage = message;
    isLoadingRestaurants = false;
    isLoadingMore = false;
    update([restaurantsId]);

    debugPrint('🔴 Error: $message');
  }

  // Extract service type from order preference
  String _extractServiceType(String preference) {
    if (preference.contains('Delivery')) return 'Delivery';
    if (preference.contains('Take Away')) return 'Takeaway';
    if (preference.contains('Dine-in')) return 'Dinin';
    if (preference.contains('Special Booking')) return 'SpecialBooking';
    return 'Delivery'; // Default
  }

  // Scroll listener for pagination (90% threshold)
  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent * 0.9) {
      if (hasNextPage && !isLoadingMore && !isLoadingRestaurants && !_isFetching) {
        currentPage++;
        debugPrint('📜 Scroll trigger at 90%: Loading page $currentPage');
        _fetchRestaurants(isRefresh: false);
      }
    }
  }

  // Retry fetching restaurants
  Future<void> retryFetchingRestaurants() async {
    debugPrint('🔄 RETRY: Resetting pagination and fetching');
    currentPage = 1;
    restaurants.clear();
    await _fetchRestaurants(isRefresh: true);
  }

  // Refresh restaurants
  Future<void> refreshRestaurants() async {
    debugPrint('🔄 REFRESH: Fetching restaurants');
    currentPage = 1;
    restaurants.clear();
    await _fetchRestaurants(isRefresh: true);
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
