import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/screens/cart/controller/cart_service.dart';
import 'package:eatplek_app/screens/home/model/invite_model.dart';
import 'package:eatplek_app/screens/home/view/widget/clear_cart_to_join_bottom_sheet.dart';
import 'package:eatplek_app/screens/home/view/widget/invite_bottom_sheet.dart';
import 'package:eatplek_app/screens/home/view/widget/outside_radius_bottom_sheet.dart';
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
  // ─── Carousel ─────────────────────────────────────────────────────────────
  int currentCarouselIndex = 0;
  List<BannerData> banners = [];

  // ─── User data ────────────────────────────────────────────────────────────
  String userCity = 'Locating...';
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

  // ─── API data ─────────────────────────────────────────────────────────────
  List<String> availableServices = [];
  List<PrebookList> prebookList = [];
  List<Vendor> vendors = [];

  // ─── State flags ──────────────────────────────────────────────────────────
  bool isLoadingServices = false;
  bool isLoadingVendors = false;
  bool isLoadingMore = false;
  bool hasError = false;
  String errorMessage = '';

  // ─── Pagination ───────────────────────────────────────────────────────────
  int currentPage = 1;
  int totalPages = 1;
  int limit = 10;
  bool hasNextPage = false;

  // ─── GetBuilder update IDs ────────────────────────────────────────────────
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

  // Fallback only used when GPS fails AND no saved location exists
  static const double _fallbackLatitude = 11.8705;
  static const double _fallbackLongitude = 75.3679;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

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

    _listenToProfileUpdates();

    debugPrint('🚀 HomeController initialized');

    _initializeHomeScreen();
  }

  void _listenToProfileUpdates() {
    try {
      final profileController = Get.find<ProfileController>();
      ever(profileController.userData, (_) {
        debugPrint('👤 Profile data updated — refreshing greeting');
        update([userGreetingId]);
      });
    } catch (_) {
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

  // ─── Initialization ───────────────────────────────────────────────────────

  Future<void> _initializeHomeScreen() async {
    try {
      debugPrint('🔄 Starting initialization sequence...');

      // ── Step 1: Restore saved location if available ──────────────────────
      if (Store.userLatitude != 0.0 && Store.userLongitude != 0.0) {
        userLatitude = Store.userLatitude;
        userLongitude = Store.userLongitude;
        userCity = Store.userCity.isNotEmpty ? Store.userCity : 'Locating...';
        debugPrint(
          '📍 Restored saved location: $userCity ($userLatitude, $userLongitude)',
        );
        update([userGreetingId]);
      }

      // ── Step 2: Show loading overlay ─────────────────────────────────────
      isLoadingServices = true;
      _locationFetching = true;
      update([carouselId]);

      // ── Step 3: Fetch fresh GPS ───────────────────────────────────────────
      await _fetchUserLocation();
      _locationFetching = false;

      // ── Step 4: Restore saved preference if any ───────────────────────────
      final String savedPreference = Store.deliveryPreference;
      if (savedPreference.isNotEmpty) {
        orderPreference = savedPreference;
        update([orderPreferenceId]);
        debugPrint('✅ Restored saved preference: $savedPreference');
      }

      // ── Step 5: Always fetch services first (no serviceType) ──────────────
      // This tells us what's available at this location
      debugPrint('📋 Fetching available services for current location...');
      final bool servicesLoaded = await _fetchHomeData(
        serviceType: null,
        isRefresh: true,
      );

      isLoadingServices = false;
      update([carouselId]);

      if (!servicesLoaded || availableServices.isEmpty) {
        // ── No services at this location ─────────────────────────────────
        debugPrint('❌ No services available at this location');
        hasError = true;
        errorMessage =
            'No services available in your area.\nTry changing your location.';
        update([vendorsId]);
        return;
      }

      // ── Step 6: Ensure valid preference is set ────────────────────────────
      // If saved preference is no longer available at this location, clear it
      if (orderPreference.isNotEmpty &&
          !_isPreferenceAvailable(orderPreference)) {
        debugPrint(
          '⚠️ Saved preference "$orderPreference" not available here — clearing',
        );
        orderPreference = '';
        Store.deliveryPreference = '';
        update([orderPreferenceId]);
      }

      if (orderPreference.isEmpty) {
        // ── No preference — must show dialog, user cannot skip ────────────
        debugPrint(
          '📋 No preference set — showing mandatory preference dialog',
        );
        _showOrderPreferenceDialog(canDismiss: false);
      } else {
        // ── Preference exists and is valid — fetch vendors directly ───────
        debugPrint('✅ Valid preference exists: $orderPreference');
        final String? serviceType = _extractServiceType(orderPreference);
        if (serviceType != null) {
          await _fetchHomeData(serviceType: serviceType, isRefresh: true);
        }
      }

      // ── Step 7: Background tasks ──────────────────────────────────────────
      await _cartService.fetchCartItemCount();
      await _checkPendingInvites();

      debugPrint('✅ Initialization complete');
    } catch (e) {
      debugPrint('❌ Initialization error: $e');
      isLoadingServices = false;
      hasError = true;
      errorMessage = 'Failed to initialize. Please try again.';
      update([carouselId, vendorsId]);
    }
  }

  // ─── API ──────────────────────────────────────────────────────────────────

  Future<bool> _fetchHomeData({
    String? serviceType,
    required bool isRefresh,
  }) async {
    if (_isFetching) {
      debugPrint('⚠️ Already fetching — ignoring duplicate request');
      return false;
    }

    if (_locationFetching) {
      debugPrint('⚠️ Location still fetching — waiting...');
      return false;
    }

    try {
      _isFetching = true;

      if (isRefresh) {
        isLoadingVendors = true;
        hasError = false;
        errorMessage = '';
        update([vendorsId]);
        debugPrint('🔄 Refreshing home data...');
      } else {
        isLoadingMore = true;
        update([vendorsId]);
        debugPrint('📜 Loading more vendors (page $currentPage)...');
      }

      final String formattedDateTime = DateTime.now().toUtc().toIso8601String();
      final String cleanDateTime =
          '${formattedDateTime.substring(0, formattedDateTime.indexOf('.'))}Z';

      String endpoint =
          '${Urls.getHomeUrl}?latitude=$userLatitude&longitude=$userLongitude&dateTime=$cleanDateTime';

      if (serviceType != null && serviceType.isNotEmpty) {
        endpoint += '&serviceType=$serviceType';
        debugPrint('🔗 Fetching with serviceType: $serviceType');
      } else {
        debugPrint('🔗 Fetching without serviceType — services discovery only');
      }

      debugPrint('🔗 Endpoint: $endpoint');

      final response = await _apiClient
          .get(endpoint: endpoint)
          .timeout(
            const Duration(seconds: 30),
            onTimeout:
                () =>
                    throw TimeoutException(
                      'API request timed out after 30 seconds',
                    ),
          );

      if (response != null) {
        final newHomeModel = NewHomeModel.fromJson(response);

        if (newHomeModel.success == true && newHomeModel.data != null) {
          availableServices = newHomeModel.data!.availableServices ?? [];
          banners = newHomeModel.data!.banners ?? [];

          debugPrint(
            '✅ Services: ${availableServices.length} | Banners: ${banners.length}',
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

            debugPrint(
              '✅ Vendors: ${vendors.length} | Prebooks: ${prebookList.length}',
            );
          }

          isLoadingVendors = false;
          isLoadingMore = false;
          hasError = false;
          update([vendorsId]);

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
      _handleApiError('Request timed out. Check your internet connection.');
      debugPrint('⏱️ Timeout: $e');
      return false;
    } catch (e) {
      _handleApiError(_parseError(e.toString()));
      debugPrint('❌ API Error: $e');
      return false;
    } finally {
      _isFetching = false;
    }
  }

  // ─── Location ─────────────────────────────────────────────────────────────

  Future<void> _fetchUserLocation() async {
    try {
      debugPrint('🚩 locationManuallyPicked = ${Store.locationManuallyPicked}');
      debugPrint('📍 Fetching GPS location...');

      // ── Manual pick check FIRST — before any GPS call ───────────────────
      if (Store.locationManuallyPicked) {
        debugPrint(
          '📍 Manual location active — skipping GPS. Keeping: $userCity ($userLatitude, $userLongitude)',
        );
        return; // ← exits immediately, GPS never runs
      }

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

        userLatitude = position.latitude;
        userLongitude = position.longitude;
        debugPrint('✅ GPS applied: $userLatitude, $userLongitude');

        await _getCityFromCoordinates(position.latitude, position.longitude);

        // Save to Store on very first launch only
        if (Store.userLatitude == 0.0 && Store.userLongitude == 0.0) {
          Store.userLatitude = userLatitude;
          Store.userLongitude = userLongitude;
          Store.userCity = userCity;
          debugPrint('💾 Saved first-time GPS to Store');
        }

        update([userGreetingId]);
      } else {
        debugPrint('⚠️ Location permission denied');
        _useFallbackIfNeeded();
      }
    } catch (e) {
      debugPrint('❌ GPS error: $e');
      _useFallbackIfNeeded();
    }
  }

  void _useFallbackIfNeeded() {
    if (userLatitude == 0.0 && userLongitude == 0.0) {
      userLatitude = _fallbackLatitude;
      userLongitude = _fallbackLongitude;
      userCity = 'Unknown Location';
      debugPrint('📍 Using fallback coordinates');
    }
    update([userGreetingId]);
  }

  Future<void> _getCityFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await GeocodingPlatform.instance!
          .placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        userCity =
            placemarks.first.locality ??
            placemarks.first.administrativeArea ??
            'Unknown Location';
        debugPrint('✅ City: $userCity');
        update([userGreetingId]);
      }
    } catch (e) {
      debugPrint('⚠️ Geocoding error: $e');
    }
  }

  // ─── Invite flow ──────────────────────────────────────────────────────────

  Future<void> _checkPendingInvites() async {
    try {
      debugPrint('📨 Checking pending invites...');
      final response = await _apiClient.get(endpoint: Urls.checkInvitesUrl);
      if (response == null) return;

      final inviteModel = InviteModel.fromJson(response);

      if (inviteModel.success == true &&
          inviteModel.data != null &&
          inviteModel.data!.isNotEmpty) {
        debugPrint('📨 Found ${inviteModel.data!.length} pending invite(s)');
        await Future.delayed(const Duration(milliseconds: 600));
        _showInviteBottomSheet(inviteModel.data!.first);
      }
    } catch (e) {
      debugPrint('⚠️ Invite check error (non-blocking): $e');
    }
  }

  void _showInviteBottomSheet(InviteData invite) {
    InviteBottomSheet.show(
      invite: invite,
      onAccept: () => _respondToInvite(invite, action: 'accept'),
      onDecline: () => _respondToInvite(invite, action: 'ignore'),
    );
  }

  Future<void> _respondToInvite(
    InviteData invite, {
    required String action,
  }) async {
    try {
      final body = {
        'inviteId': invite.inviteId,
        'action': action,
        'latitude': userLatitude,
        'longitude': userLongitude,
      };

      final response = await _apiClient.post(
        endpoint: Urls.acceptOrRejectInvitesUrl,
        data: body,
      );

      if (Get.isBottomSheetOpen == true) Navigator.of(Get.context!).pop();
      await Future.delayed(const Duration(milliseconds: 350));

      if (response == null) {
        Get.snackbar('Error', 'Failed to respond to invite. Please try again.');
        return;
      }

      final success = response['success'] == true;
      final message = (response['message'] ?? '').toString();

      if (success) {
        if (action == 'accept') {
          Get.snackbar(
            'Joined!',
            'You have joined the shared cart.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.primaryColor.withOpacity(0.9),
            colorText: Colors.white,
          );
          Get.toNamed(Routes.cartView);
        }
      } else {
        final isOutsideRadius = response['outsideRadius'] == true;
        final isCartConflict = message.toLowerCase().contains(
          'items in your own cart',
        );

        if (isOutsideRadius) {
          OutsideRadiusBottomSheet.show(
            distanceKm: (response['distanceKm'] ?? 0.0).toDouble(),
            vendorName:
                (response['vendorName'] ??
                        invite.vendor?.name ??
                        'the restaurant')
                    .toString(),
            onDismiss: () {},
          );
        } else if (isCartConflict) {
          ClearCartToJoinBottomSheet.show(
            onClearAndRetry: () => _clearCartAndRetryInvite(invite),
            onCancel: () {},
          );
        } else {
          Get.snackbar(
            'Error',
            message.isNotEmpty ? message : 'Could not respond to invite.',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error responding to invite: $e');
      if (Get.isBottomSheetOpen == true) Navigator.of(Get.context!).pop();
      await Future.delayed(const Duration(milliseconds: 350));

      final err = e.toString().toLowerCase();
      if (err.contains('items in your own cart')) {
        ClearCartToJoinBottomSheet.show(
          onClearAndRetry: () => _clearCartAndRetryInvite(invite),
          onCancel: () {},
        );
        return;
      }
      if (err.contains('outside') || err.contains('outsideradius')) {
        double km = 0.0;
        final match = RegExp(r'([\d.]+)\s*km').firstMatch(err);
        if (match != null) km = double.tryParse(match.group(1) ?? '0') ?? 0.0;
        OutsideRadiusBottomSheet.show(
          distanceKm: km,
          vendorName: invite.vendor?.name ?? 'the restaurant',
          onDismiss: () {},
        );
        return;
      }
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _clearCartAndRetryInvite(InviteData invite) async {
    try {
      final response = await _apiClient.delete(endpoint: Urls.clearCartUrl);
      if (Get.isBottomSheetOpen == true) Navigator.of(Get.context!).pop();
      await Future.delayed(const Duration(milliseconds: 350));

      if (response != null && response is Map && response['success'] == true) {
        _cartService.clearCart();
        await _respondToInvite(invite, action: 'accept');
      } else {
        Get.snackbar('Error', 'Failed to clear cart. Please try again.');
      }
    } catch (e) {
      if (Get.isBottomSheetOpen == true) Navigator.of(Get.context!).pop();
      Get.snackbar('Error', 'Failed to clear cart. Please try again.');
    }
  }

  // ─── Order preference ─────────────────────────────────────────────────────

  /// Shows the preference dialog.
  /// [canDismiss] = false means no Cancel button — user must pick.
  /// [canDismiss] = true means Cancel is shown (used when preference already set).
  void _showOrderPreferenceDialog({bool canDismiss = true}) {
    debugPrint('📱 Opening preference dialog | canDismiss: $canDismiss');

    OrderPreferenceDialog.show(
      currentPreference: orderPreference,
      availableServices: availableServices,
      banners: banners,
      canDismiss: canDismiss,
      onPreferenceSelected: (String selected) {
        debugPrint('✅ Preference selected: $selected');
        _onPreferenceSelected(selected);
      },
      onDialogDismissed:
          canDismiss
              ? () {
                debugPrint(
                  'ℹ️ Preference dialog dismissed — preference unchanged',
                );
              }
              : null,
      title: 'How Would You Like to Order?',
      subtitle: 'Please choose your preferred service to continue.',
    );
  }

  Future<void> _onPreferenceSelected(String selectedPreference) async {
    orderPreference = selectedPreference;
    Store.deliveryPreference = selectedPreference;
    update([orderPreferenceId]);

    debugPrint('💾 Preference saved: $selectedPreference');

    currentPage = 1;
    vendors.clear();
    prebookList.clear();

    final String? serviceType = _extractServiceType(selectedPreference);
    if (serviceType != null) {
      await _fetchHomeData(serviceType: serviceType, isRefresh: true);
    }
  }

  void updateCarouselIndex(int index) {
    currentCarouselIndex = index;
    update([carouselId]);
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void onSearchTapped() {
    final String? serviceType = _extractServiceType(orderPreference);
    Get.toNamed(
      Routes.searchView,
      arguments: {
        'latitude': userLatitude,
        'longitude': userLongitude,
        'serviceType': serviceType ?? '',
        'serviceLabel':
            orderPreference.isEmpty ? 'Select Service' : orderPreference,
      },
    );
  }

  void onNotificationTapped() {
    Get.snackbar('Notifications', 'Notification panel opened');
  }

  /// Opens location picker. After confirm:
  /// - Always re-fetches available services for new location
  /// - If no services → shows error
  /// - If services available:
  ///     - If current preference still valid → re-fetch vendors
  ///     - If preference no longer valid or empty → show mandatory dialog
  void onLocationChangeTapped() async {
    debugPrint('🗺️ Opening location picker...');

    final result = await Get.toNamed(
      Routes.locationPickerView,
      arguments: {'latitude': userLatitude, 'longitude': userLongitude},
    );

    if (result == null || result is! Map<String, dynamic>) {
      debugPrint('ℹ️ Location picker dismissed without selection');
      return;
    }

    final double lat = (result['latitude'] as num).toDouble();
    final double lng = (result['longitude'] as num).toDouble();
    final String city = result['city']?.toString() ?? 'Unknown';

    debugPrint('✅ New location: $city ($lat, $lng)');

    // ── Update state and storage ─────────────────────────────────────────
    userLatitude = lat;
    userLongitude = lng;
    userCity = city;
    await Store.saveManualLocation(latitude: lat, longitude: lng, city: city);
    update([userGreetingId]);

    // ── Show loading overlay while fetching services ──────────────────────
    isLoadingServices = true;
    hasError = false;
    vendors.clear();
    prebookList.clear();
    update([carouselId, vendorsId]);

    // ── Fetch services for new location (no serviceType) ──────────────────
    debugPrint('📋 Fetching services for new location...');
    final bool servicesLoaded = await _fetchHomeData(
      serviceType: null,
      isRefresh: true,
    );

    isLoadingServices = false;
    update([carouselId]);

    if (!servicesLoaded || availableServices.isEmpty) {
      // ── No services at new location ───────────────────────────────────
      debugPrint('❌ No services at new location');
      hasError = true;
      errorMessage =
          'No services available in your area.\nTry changing your location.';
      // Also clear preference since it's invalid here
      orderPreference = '';
      Store.deliveryPreference = '';
      update([vendorsId, orderPreferenceId]);
      return;
    }

    // ── Check if existing preference is still valid here ──────────────────
    if (orderPreference.isNotEmpty &&
        !_isPreferenceAvailable(orderPreference)) {
      debugPrint(
        '⚠️ Previous preference "$orderPreference" not available at new location — clearing',
      );
      orderPreference = '';
      Store.deliveryPreference = '';
      update([orderPreferenceId]);
    }

    if (orderPreference.isEmpty) {
      // ── No valid preference — must pick one ───────────────────────────
      debugPrint('📋 No valid preference — showing mandatory dialog');
      _showOrderPreferenceDialog(canDismiss: false);
    } else {
      // ── Preference still valid — fetch vendors ────────────────────────
      debugPrint(
        '✅ Preference "$orderPreference" valid at new location — fetching vendors',
      );
      currentPage = 1;
      final String? serviceType = _extractServiceType(orderPreference);
      if (serviceType != null) {
        await _fetchHomeData(serviceType: serviceType, isRefresh: true);
      }
    }
  }

  /// Change order preference button tapped from home screen
  void onOrderPreferenceChanged() {
    debugPrint('🔄 Change preference tapped');

    if (_cartService.itemCount.value > 0) {
      _showClearCartConfirmationDialog();
    } else {
      // canDismiss: true — preference already set, user can cancel
      _showOrderPreferenceDialog(canDismiss: true);
    }
  }

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
                  _showOrderPreferenceDialog(canDismiss: true);
                } else {
                  Get.snackbar(
                    'Error',
                    'Failed to clear cart. Please try again.',
                  );
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to clear cart. Please try again.',
                );
              }
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
        'serviceType': _extractServiceType(orderPreference) ?? '',
        'serviceLabel':
            orderPreference.isEmpty ? 'Select Service' : orderPreference,
      },
    );
  }

  void onRestaurantTapped(Vendor restaurant) {
    final branches = restaurant.branchList ?? [];
    if (branches.length > 1) {
      _showMultipleBranchesBottomSheet(restaurant, branches);
    } else {
      Get.toNamed(Routes.restaurantDetail, arguments: restaurant);
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
        onBranchSelected: (Vendor selected) {
          Get.toNamed(Routes.restaurantDetail, arguments: selected);
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

  // ─── Retry / Refresh ──────────────────────────────────────────────────────

  Future<void> retryFetchingVendors() async {
    debugPrint('🔄 RETRY triggered');
    currentPage = 1;
    vendors.clear();
    prebookList.clear();

    final String? serviceType = _extractServiceType(orderPreference);
    if (serviceType != null) {
      await _fetchHomeData(serviceType: serviceType, isRefresh: true);
    } else {
      // No preference — re-run full init flow
      await _initializeHomeScreen();
    }
  }

  Future<void> refreshVendors() async {
    debugPrint('🔄 REFRESH triggered');
    currentPage = 1;
    vendors.clear();
    prebookList.clear();

    final String? serviceType = _extractServiceType(orderPreference);
    if (serviceType != null) {
      await _fetchHomeData(serviceType: serviceType, isRefresh: true);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Returns null when preference is empty — never silently defaults to delivery
  String? _extractServiceType(String preference) {
    if (preference.isEmpty) return null;
    if (preference.contains('Delivery')) return 'delivery';
    if (preference.contains('Takeaway')) return 'takeaway';
    if (preference.contains('Dine-in')) return 'dine-in';
    if (preference.contains('Special Booking')) return 'car-dine-in';
    return null;
  }

  /// Checks if the current preference is in the list of available services
  bool _isPreferenceAvailable(String preference) {
    final String? serviceType = _extractServiceType(preference);
    if (serviceType == null) return false;
    return availableServices.any(
      (s) =>
          s.toLowerCase().replaceAll('-', '').replaceAll(' ', '') ==
          serviceType.toLowerCase().replaceAll('-', '').replaceAll(' ', ''),
    );
  }

  String _parseError(String error) {
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
    debugPrint('🔴 API Error: $message');
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.9) {
      if (hasNextPage && !isLoadingMore && !isLoadingVendors && !_isFetching) {
        currentPage++;
        debugPrint('📜 Scroll trigger: Loading page $currentPage');
        final String? serviceType = _extractServiceType(orderPreference);
        if (serviceType != null) {
          _fetchHomeData(serviceType: serviceType, isRefresh: false);
        }
      }
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
