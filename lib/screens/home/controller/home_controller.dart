import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/screens/cart/controller/cart_service.dart';
import 'package:eatplek_app/screens/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../../core/util/storage.dart';
import '../model/new_home_model.dart';
import '../view/widget/multiple_branch_bottom_sheet.dart';
import '../view/widget/order_preference_dialog.dart';

class HomeController extends GetxController {
  // Carousel properties
  int currentCarouselIndex = 0;
  List<BannerData> banners = [];

  // User data
  String userCity = 'Kannur';
  double userLatitude = 0.0;
  double userLongitude = 0.0;
  String orderPreference = '';

  // Derived from ProfileController — no duplicate API call
  String get userName {
    try {
      final profileController = Get.find<ProfileController>();
      final name = profileController.userData.value?.name;
      if (name != null && name.isNotEmpty) return name.split(' ').first;
    } catch (_) {}
    return '';
  }

  // Service data from API
  List<String> availableServices = [];

  // Prebook data from API
  List<PrebookList> prebookList = [];

  // Vendor data from API
  List<Vendor> vendors = [];
  bool isLoadingServices = false;
  bool isLoadingVendors = false;
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
  static const String vendorsId = 'vendors';

  late FittorConnect _apiClient;
  late CartService _cartService;
  late ScrollController scrollController;

  bool _isFetching = false;
  bool _isInitialized = false;
  bool _locationFetching = false;
  bool _isFirstTimeSetup = false;

  static const double STATIC_LATITUDE = 11.8705;
  static const double STATIC_LONGITUDE = 75.3679;

  @override
  void onInit() {
    super.onInit();

    if (_isInitialized) {
      debugPrint('⚠️ HomeController already initialized, skipping...');
      return;
    }
    _isInitialized = true;

    try {
      _apiClient = Get.find<FittorConnect>();
    } catch (e) {
      _apiClient = FittorConnect();
      Get.put<FittorConnect>(_apiClient);
    }

    _cartService = Get.find<CartService>();

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    // Listen to profile data changes and refresh the greeting when name loads
    _listenToProfileUpdates();

    debugPrint('🚀 HomeController initialized');

    _initializeHomeScreen();
  }

  /// Re-trigger userGreeting update whenever profile data arrives
  void _listenToProfileUpdates() {
    try {
      final profileController = Get.find<ProfileController>();
      ever(profileController.userData, (_) {
        debugPrint('👤 Profile data updated — refreshing greeting');
        update([userGreetingId]);
      });
    } catch (_) {
      // ProfileController not yet registered — greeting will fall back to ''
      debugPrint(
        '⚠️ ProfileController not found during greeting listener setup',
      );
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  /// Initialize home screen with unified flow
  Future<void> _initializeHomeScreen() async {
    try {
      debugPrint('🔄 Starting initialization sequence...');

      _isFirstTimeSetup = userLatitude == 0.0 && userLongitude == 0.0;
      String? savedPreference = Store.deliveryPreference;

      debugPrint(
        '📊 Initial State - Location: ($userLatitude, $userLongitude) | Preference: "$savedPreference" | FirstTimeSetup: $_isFirstTimeSetup',
      );

      isLoadingServices = true;
      _locationFetching = true;
      update([carouselId]);

      await _fetchUserLocation();
      _locationFetching = false;

      if (savedPreference.isNotEmpty) {
        debugPrint('✅ Using saved preference: $savedPreference');
        orderPreference = savedPreference;
        update([orderPreferenceId]);

        isLoadingServices = false;
        update([carouselId]);

        String serviceType = _extractServiceType(savedPreference);
        await _fetchHomeData(serviceType: serviceType, isRefresh: true);
      } else {
        debugPrint('📋 No preference saved - fetching available services...');

        final success = await _fetchHomeData(
          serviceType: null,
          isRefresh: true,
        );

        if (success && availableServices.isNotEmpty) {
          isLoadingServices = false;
          update([carouselId]);

          debugPrint('✅ Services loaded, showing dialog now');
          _showOrderPreferenceDialog();
        } else {
          isLoadingServices = false;
          update([carouselId]);

          if (availableServices.isEmpty && !hasError) {
            hasError = true;
            errorMessage =
                'No services available in your location. Please change your location.';
            debugPrint(
              '❌ No services available - show location change message',
            );
            update([vendorsId]);
          }
        }
      }

      // Populate cart badge regardless of preference outcome
      await _cartService.fetchCartItemCount();

      debugPrint('✅ Initialization complete');
    } catch (e) {
      debugPrint('❌ Initialization error: $e');
      isLoadingServices = false;
      hasError = true;
      errorMessage = 'Failed to initialize. Please try again.';
      update([carouselId, vendorsId]);
    }
  }

  /// Unified API call to fetch home data
  Future<bool> _fetchHomeData({
    String? serviceType,
    required bool isRefresh,
  }) async {
    if (_isFetching) {
      debugPrint('⚠️ Already fetching - ignoring duplicate request');
      return false;
    }

    if (_locationFetching) {
      debugPrint('⚠️ Location still fetching - waiting...');
      return false;
    }

    try {
      _isFetching = true;

      if (isRefresh) {
        isLoadingVendors = true;
        hasError = false;
        errorMessage = '';
        update([vendorsId]);
        debugPrint('🔄 Refreshing home data (page 1)...');
      } else {
        isLoadingMore = true;
        update([vendorsId]);
        debugPrint('📜 Loading more vendors (page $currentPage)...');
      }

      String formattedDateTime = DateTime.now().toUtc().toIso8601String();
      String cleanDateTime =
          '${formattedDateTime.substring(0, formattedDateTime.indexOf('.'))}Z';

      String endpoint =
          "${Urls.getHomeUrl}?latitude=$userLatitude&longitude=$userLongitude&dateTime=$cleanDateTime";

      if (serviceType != null && serviceType.isNotEmpty) {
        endpoint += "&serviceType=$serviceType";
        debugPrint('🔗 Fetching with serviceType: $serviceType');
      } else {
        debugPrint('🔗 Fetching without serviceType (services only)');
      }

      debugPrint('🔗 API Endpoint: $endpoint');

      final response = await _apiClient
          .get(endpoint: endpoint)
          .timeout(
            const Duration(seconds: 30),
            onTimeout:
                () =>
                    throw TimeoutException(
                      'API request timeout after 30 seconds',
                    ),
          );

      if (response != null) {
        debugPrint('✅ API Response received');

        final newHomeModel = NewHomeModel.fromJson(response);

        if (newHomeModel.success == true && newHomeModel.data != null) {
          availableServices = newHomeModel.data!.availableServices ?? [];
          banners = newHomeModel.data!.banners ?? [];

          debugPrint(
            '✅ Services loaded: ${availableServices.length} services, ${banners.length} banners',
          );

          if (serviceType != null) {
            final newVendors = newHomeModel.data!.vendors ?? [];
            final newPrebooks = newHomeModel.data!.prebookList ?? [];

            if (isRefresh) {
              vendors = newVendors;
              prebookList = newPrebooks;
            } else {
              vendors.addAll(newVendors);
              prebookList.addAll(newPrebooks);
            }

            debugPrint('✅ Vendors loaded: ${vendors.length} items');
            debugPrint('✅ Prebooks loaded: ${prebookList.length} items');
          }

          isLoadingVendors = false;
          isLoadingMore = false;
          hasError = false;
          update([vendorsId]);

          debugPrint('✅ Home data loaded successfully');
          return true;
        } else {
          _handleApiError(newHomeModel.message ?? 'Unknown error from server');
          return false;
        }
      } else {
        _handleApiError('No response from server');
        return false;
      }
    } on TimeoutException catch (e) {
      _handleApiError(
        'Request timeout. Please check your internet connection.',
      );
      debugPrint('⏱️ Timeout: $e');
      return false;
    } catch (e) {
      String errorMsg = _parseError(e.toString());
      _handleApiError(errorMsg);
      debugPrint('❌ API Error: $e');
      return false;
    } finally {
      _isFetching = false;
    }
  }

  /// Fetch user's current location
  Future<void> _fetchUserLocation() async {
    try {
      debugPrint('📍 Starting location fetch...');

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        userLatitude = STATIC_LATITUDE;
        userLongitude = STATIC_LONGITUDE;

        debugPrint(
          '✅ Location fetched: Lat=$userLatitude, Long=$userLongitude',
        );

        await _getCityFromCoordinates(position.latitude, position.longitude);

        update([userGreetingId]);
      } else {
        debugPrint('⚠️ Location permission denied - using default location');
        userCity = 'Unknown Location';
        userLatitude = STATIC_LATITUDE;
        userLongitude = STATIC_LONGITUDE;
        update([userGreetingId]);
      }
    } catch (e) {
      debugPrint('❌ Error fetching location: $e');
      userCity = 'Unknown Location';
      userLatitude = STATIC_LATITUDE;
      userLongitude = STATIC_LONGITUDE;
      update([userGreetingId]);
    }
  }

  /// Get city name from latitude and longitude
  Future<void> _getCityFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await GeocodingPlatform.instance!
          .placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        userCity =
            placemarks.first.locality ??
            placemarks.first.administrativeArea ??
            'Unknown Location';
        debugPrint('✅ City resolved: $userCity');
        update([userGreetingId]);
      }
    } catch (e) {
      debugPrint('⚠️ Error getting city: $e');
    }
  }

  /// Show order preference dialog with available services
  void _showOrderPreferenceDialog() {
    debugPrint('📱 Opening preference dialog...');

    OrderPreferenceDialog.show(
      currentPreference: orderPreference,
      availableServices: availableServices,
      banners: banners,
      onPreferenceSelected: (String selectedPreference) {
        debugPrint('✅ Preference Selected from Dialog: $selectedPreference');
        _onPreferenceSelected(selectedPreference);
      },
      onDialogDismissed: () {},
      title: 'How Would You Like to Order?',
      subtitle: 'Please choose your preferred service to continue.',
    );
  }

  /// Handle preference selection from dialog
  Future<void> _onPreferenceSelected(String selectedPreference) async {
    debugPrint('🎯 Updating preference: $selectedPreference');

    orderPreference = selectedPreference;
    Store.deliveryPreference = selectedPreference;

    debugPrint('💾 Saved to storage: $selectedPreference');

    update([orderPreferenceId]);

    String serviceType = _extractServiceType(selectedPreference);

    currentPage = 1;
    vendors.clear();
    prebookList.clear();

    debugPrint('🚀 Fetching vendors for service type: $serviceType');
    await _fetchHomeData(serviceType: serviceType, isRefresh: true);
  }

  /// Update carousel index
  void updateCarouselIndex(int index) {
    currentCarouselIndex = index;
    update([carouselId]);
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void onSearchTapped() {
    Get.toNamed(
      Routes.searchView,
      arguments: {
        'latitude': userLatitude,
        'longitude': userLongitude,
        'serviceType': _extractServiceType(orderPreference),
        'serviceLabel':
            orderPreference.isEmpty ? 'Select Service' : orderPreference,
      },
    );
  }

  void onNotificationTapped() {
    Get.snackbar('Notifications', 'Notification panel opened');
  }

  void onLocationChangeTapped() {
    debugPrint('🔄 Location change tapped');
    Get.snackbar('Location', 'Change location functionality');
  }

  /// Change order preference — shows cart-clear confirmation if cart has items
  void onOrderPreferenceChanged() {
    debugPrint('🔄 Change preference tapped');

    if (_cartService.itemCount.value > 0) {
      _showClearCartConfirmationDialog();
    } else {
      _showOrderPreferenceDialog();
    }
  }

  /// Confirmation dialog shown when user has cart items and taps change preference
  void _showClearCartConfirmationDialog() {
    final count = _cartService.itemCount.value;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear Cart?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          'You have $count item${count > 1 ? 's' : ''} in your cart. '
          'Changing your order preference will clear your cart. '
          'Do you want to continue?',
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.of(Get.context!).pop();

              try {
                final response = await _apiClient.delete(
                  endpoint: Urls.clearCartUrl,
                );

                if (response != null &&
                    response is Map<String, dynamic> &&
                    response['success'] == true) {
                  _cartService.clearCart();
                  debugPrint('✅ Cart cleared before preference change');
                } else {
                  Get.snackbar(
                    'Error',
                    'Failed to clear cart. Please try again.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
              } catch (e) {
                debugPrint('❌ Error clearing cart: $e');
                Get.snackbar(
                  'Error',
                  'Failed to clear cart. Please try again.',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              _showOrderPreferenceDialog();
            },
            child: const Text(
              'Yes, Clear & Change',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void onViewAllRestaurants() {
    Get.toNamed(
      Routes.searchView,
      arguments: {
        'latitude': userLatitude,
        'longitude': userLongitude,
        'serviceType': _extractServiceType(orderPreference),
        'serviceLabel':
            orderPreference.isEmpty ? 'Select Service' : orderPreference,
      },
    );
  }

  /// Handle restaurant/vendor tap - check for multiple branches
  void onRestaurantTapped(Vendor restaurant) {
    final branches = restaurant.branchList ?? [];

    debugPrint('🏪 Restaurant tapped: ${restaurant.hotelName}');
    debugPrint('📍 Branch count: ${branches.length}');

    if (branches.isEmpty) {
      debugPrint('✅ Single location - navigating directly');
      Get.toNamed(Routes.restaurantDetail, arguments: restaurant);
    } else if (branches.length == 1) {
      debugPrint('✅ Only one branch - navigating directly');
      Get.toNamed(Routes.restaurantDetail, arguments: restaurant);
    } else {
      debugPrint('🔀 Multiple branches detected - showing bottom sheet');
      _showMultipleBranchesBottomSheet(restaurant, branches);
    }
  }

  void _showMultipleBranchesBottomSheet(
    Vendor mainVendor,
    List<Vendor> branches,
  ) {
    Get.bottomSheet(
      MultipleBranchBottomSheet(
        vendorName: mainVendor.hotelName ?? 'Restaurant',
        branches: branches,
        onBranchSelected: (Vendor selectedBranch) {
          Get.toNamed(Routes.restaurantDetail, arguments: selectedBranch);
        },
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _parseError(String error) {
    debugPrint('🔍 Parsing error: $error');

    if (error.contains('Client is closed') || error.contains('Bad state')) {
      return 'Connection lost. Please try again.';
    } else if (error.contains('SocketException') ||
        error.contains('Failed host lookup')) {
      return 'Network connection error. Please check your internet.';
    } else if (error.contains('Connection refused')) {
      return 'Could not connect to server. Please try again.';
    } else if (error.contains('TimeoutException') ||
        error.contains('timeout')) {
      return 'Request took too long. Please try again.';
    } else if (error.contains('Connection reset')) {
      return 'Connection interrupted. Please try again.';
    }
    return 'Unable to load data. Please try again.';
  }

  void _handleApiError(String message) {
    hasError = true;
    errorMessage = message;
    isLoadingVendors = false;
    isLoadingMore = false;
    update([vendorsId]);

    debugPrint('🔴 Error: $message');
  }

  String _extractServiceType(String preference) {
    if (preference.contains('Delivery')) return 'delivery';
    if (preference.contains('Takeaway')) return 'takeaway';
    if (preference.contains('Dine-in')) return 'dine-in';
    if (preference.contains('Special Booking')) return 'car-dine-in';
    return 'delivery';
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.9) {
      if (hasNextPage && !isLoadingMore && !isLoadingVendors && !_isFetching) {
        currentPage++;
        debugPrint('📜 Scroll trigger at 90%: Loading page $currentPage');
        String serviceType = _extractServiceType(orderPreference);
        _fetchHomeData(serviceType: serviceType, isRefresh: false);
      }
    }
  }

  Future<void> retryFetchingVendors() async {
    debugPrint('🔄 RETRY: Resetting pagination and fetching');
    currentPage = 1;
    vendors.clear();
    prebookList.clear();

    String serviceType = _extractServiceType(orderPreference);
    await _fetchHomeData(serviceType: serviceType, isRefresh: true);
  }

  Future<void> refreshVendors() async {
    debugPrint('🔄 REFRESH: Fetching vendors');
    currentPage = 1;
    vendors.clear();
    prebookList.clear();

    String serviceType = _extractServiceType(orderPreference);
    await _fetchHomeData(serviceType: serviceType, isRefresh: true);
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
