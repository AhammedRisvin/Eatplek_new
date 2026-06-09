import 'dart:async';

import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/util/service_type.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:eatplek_app/screens/cart/controller/cart_service.dart';
import 'package:eatplek_app/screens/home/controller/home_controller.dart';
import 'package:eatplek_app/screens/restaurant_detail_view/controller/restaurant_detail_view_controller.dart';
import 'package:eatplek_app/screens/restaurant_detail_view/model/restaurent_details_model.dart';
import 'package:eatplek_app/screens/restaurant_detail_view/view/widget/food_details_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../model/today_offers_model.dart';

class OfferController extends GetxController {
  static const String preferencesId = 'offerPreferences';
  static const String foodsId = 'offerFoods';
  static const int pageLimit = 20;

  final FittorConnect _apiClient = FittorConnect();
  final ScrollController scrollController = ScrollController();

  List<String> availableServices = [];
  List<OfferFood> offers = [];

  String selectedPreference = '';
  double userLatitude = 0.0;
  double userLongitude = 0.0;

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasError = false;
  String errorMessage = '';

  int currentPage = 1;
  int totalPages = 0;
  bool hasNextPage = false;

  bool _isFetching = false;
  Timer? _homeSyncRetryTimer;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _syncFromHome(fetchAfterSync: true);
  }

  @override
  void onClose() {
    _homeSyncRetryTimer?.cancel();
    scrollController.removeListener(_onScroll);
    super.onClose();
  }

  void refreshFromHome() {
    _syncFromHome(fetchAfterSync: true, forceRefresh: true);
  }

  Future<void> retryFetch() async {
    currentPage = 1;
    offers.clear();
    await _fetchOffers(isRefresh: true);
  }

  Future<void> refreshOffers() async {
    _syncFromHome(fetchAfterSync: false, forceRefresh: true);
    currentPage = 1;
    offers.clear();
    await _fetchOffers(isRefresh: true);
  }

  void onPreferenceSelected(String preference) {
    final normalized = ServiceType.normalize(preference);
    if (ServiceType.same(selectedPreference, normalized)) return;

    selectedPreference = normalized;
    Store.deliveryPreference = normalized;
    _syncHomePreference(normalized);

    currentPage = 1;
    offers.clear();
    update([preferencesId, foodsId]);
    _fetchOffers(isRefresh: true);
  }

  Future<void> onOfferActionTapped(OfferFood offer) async {
    final food = offer.food;
    final foodId = food.foodId ?? '';
    if (foodId.isEmpty) return;

    final hasCustomizations = food.customizations?.isNotEmpty ?? false;
    final hasAddOns = food.addOns?.isNotEmpty ?? false;

    if (!hasCustomizations && !hasAddOns) {
      await increasePlainOfferQuantity(food);
      return;
    }

    _openFoodOptionsSheet(food);
  }

  Future<void> increasePlainOfferQuantity(Food food) async {
    final foodId = food.foodId ?? '';
    if (foodId.isEmpty) return;

    final cartService = Get.find<CartService>();
    await _setPlainFoodQuantity(food, cartService.getFoodQuantity(foodId) + 1);
  }

  Future<void> decreasePlainOfferQuantity(Food food) async {
    final foodId = food.foodId ?? '';
    if (foodId.isEmpty) return;

    final cartService = Get.find<CartService>();
    final currentQuantity = cartService.getFoodQuantity(foodId);
    if (currentQuantity <= 0) return;

    await _setPlainFoodQuantity(food, currentQuantity - 1);
  }

  Future<void> _setPlainFoodQuantity(Food food, int quantity) async {
    final foodId = food.foodId ?? '';
    if (foodId.isEmpty) return;

    try {
      final cartService = Get.find<CartService>();
      final response = await _apiClient.post(
        endpoint: Urls.addOrUpdateCartUrl,
        data: {
          'foodId': foodId,
          'quantity': quantity,
          'serviceType': ServiceType.normalize(selectedPreference),
        },
      );

      if (response is Map<String, dynamic> &&
          response['success'] == true &&
          response['data'] != null) {
        cartService.updateCartFromApi(response['data']);
      } else {
        Get.snackbar(
          'Error',
          response is Map
              ? response['message'] ?? 'Failed to add item'
              : 'Failed to add item',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Offer add plain food error: $e');
      Get.snackbar(
        'Error',
        'Failed to add item to cart',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _openFoodOptionsSheet(Food food) {
    final detailController = _ensureFoodSheetController();
    final cartService = Get.find<CartService>();
    final isEdit = cartService.isFoodInCart(food.foodId ?? '');

    detailController.selectFoodItem(food, isEdit: isEdit);

    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (_) => const FoodDetailsBottomSheet(),
    ).then((_) => detailController.resetBottomSheetState());
  }

  RestaurantDetailViewController _ensureFoodSheetController() {
    if (Get.isRegistered<RestaurantDetailViewController>()) {
      return Get.find<RestaurantDetailViewController>();
    }

    return Get.put<RestaurantDetailViewController>(
      RestaurantDetailViewController(skipInitialFetch: true),
    );
  }

  void _syncFromHome({
    required bool fetchAfterSync,
    bool forceRefresh = false,
  }) {
    final previousPreference = selectedPreference;
    final previousLatitude = userLatitude;
    final previousLongitude = userLongitude;

    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      availableServices = _normalizeAvailableServices(
        homeController.availableServices,
      );
      userLatitude = homeController.userLatitude;
      userLongitude = homeController.userLongitude;

      final homePreference = homeController.orderPreference;
      selectedPreference = _resolveSelectedPreference(
        homePreference: homePreference,
      );
    } else {
      userLatitude = Store.userLatitude;
      userLongitude = Store.userLongitude;
      selectedPreference = _resolveSelectedPreference();
    }

    if (availableServices.isEmpty && Store.availableServices.isNotEmpty) {
      availableServices = _normalizeAvailableServices(Store.availableServices);
      selectedPreference = _resolveSelectedPreference(
        homePreference: selectedPreference,
      );
    }

    if (userLatitude == 0.0 && Store.userLatitude != 0.0) {
      userLatitude = Store.userLatitude;
    }
    if (userLongitude == 0.0 && Store.userLongitude != 0.0) {
      userLongitude = Store.userLongitude;
    }

    update([preferencesId]);

    final shouldRefetch =
        forceRefresh ||
        offers.isEmpty ||
        !ServiceType.same(previousPreference, selectedPreference) ||
        previousLatitude != userLatitude ||
        previousLongitude != userLongitude;

    if (fetchAfterSync &&
        selectedPreference.isNotEmpty &&
        _hasUsableLocation &&
        shouldRefetch) {
      currentPage = 1;
      offers.clear();
      _fetchOffers(isRefresh: true);
    }

    _scheduleHomeSyncRetryIfNeeded();
  }

  String _resolveSelectedPreference({String homePreference = ''}) {
    final savedPreference = Store.deliveryPreference;

    if (_isAvailable(homePreference)) {
      return ServiceType.normalize(homePreference);
    }
    if (_isAvailable(savedPreference)) {
      return ServiceType.normalize(savedPreference);
    }
    if (availableServices.isNotEmpty) {
      return ServiceType.normalize(availableServices.first);
    }
    if (homePreference.trim().isNotEmpty) {
      return ServiceType.normalize(homePreference);
    }
    if (savedPreference.trim().isNotEmpty) {
      return ServiceType.normalize(savedPreference);
    }

    return ServiceType.delivery;
  }

  List<String> _normalizeAvailableServices(List<String> services) {
    final normalized = <String>[];

    for (final service in services) {
      final cleanService = _normalizeServiceAlias(service);
      if (cleanService.isEmpty) continue;
      if (normalized.any((item) => ServiceType.same(item, cleanService))) {
        continue;
      }
      normalized.add(cleanService);
    }

    return normalized;
  }

  String _normalizeServiceAlias(String service) {
    final cleaned = service.trim().toLowerCase();
    if (cleaned == 'pickup' || cleaned == 'pick up') {
      return ServiceType.takeaway;
    }
    return ServiceType.normalize(service);
  }

  bool _isAvailable(String preference) {
    if (preference.trim().isEmpty || availableServices.isEmpty) return false;
    return availableServices.any((item) => ServiceType.same(item, preference));
  }

  void _syncHomePreference(String preference) {
    if (!Get.isRegistered<HomeController>()) return;

    final homeController = Get.find<HomeController>();
    homeController.orderPreference = preference;
    homeController.update([HomeController.orderPreferenceId]);
  }

  void _scheduleHomeSyncRetryIfNeeded() {
    if (availableServices.isNotEmpty && _hasUsableLocation) return;
    if (!Get.isRegistered<HomeController>()) return;

    _homeSyncRetryTimer?.cancel();
    _homeSyncRetryTimer = Timer(const Duration(seconds: 1), () {
      if (isClosed) return;
      if (!Get.isRegistered<HomeController>()) return;

      final homeController = Get.find<HomeController>();
      final homeServices = homeController.availableServices;
      final homeHasLocation =
          homeController.userLatitude != 0.0 ||
          homeController.userLongitude != 0.0;
      _syncFromHome(fetchAfterSync: homeServices.isNotEmpty && homeHasLocation);
    });
  }

  Future<void> _fetchOffers({required bool isRefresh}) async {
    if (_isFetching) return;
    if (!_hasUsableLocation) {
      _handleError('Location is not available yet. Please try again.');
      _scheduleHomeSyncRetryIfNeeded();
      return;
    }

    try {
      _isFetching = true;

      if (isRefresh) {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      } else {
        isLoadingMore = true;
      }
      update([foodsId]);

      final endpoint = _buildOffersEndpoint();
      debugPrint('Offers endpoint: $endpoint');

      final response = await _apiClient
          .get(endpoint: endpoint)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Request timed out'),
          );

      if (response is! Map<String, dynamic>) {
        _handleError('Invalid response from server');
        return;
      }

      final parsed = TodayOffersModel.fromJson(response);
      if (!parsed.success) {
        _handleError(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to load offers',
        );
        return;
      }

      final responseServices = parsed.data?.availableServices ?? [];
      if (responseServices.isNotEmpty) {
        availableServices = _normalizeAvailableServices(responseServices);
        selectedPreference = _resolveSelectedPreference(
          homePreference: selectedPreference,
        );
        update([preferencesId]);
      }

      final newOffers = parsed.data?.offers ?? [];
      final pagination = parsed.data?.pagination;

      if (isRefresh) {
        offers = newOffers;
      } else {
        offers.addAll(newOffers);
      }

      currentPage = pagination?.currentPage ?? currentPage;
      totalPages = pagination?.totalPages ?? totalPages;
      hasNextPage = pagination?.hasNextPage ?? newOffers.length >= pageLimit;

      isLoading = false;
      isLoadingMore = false;
      hasError = false;
      update([foodsId]);
    } on TimeoutException {
      _handleError('Request timed out. Please try again.');
    } catch (e) {
      _handleError(_parseError(e.toString()));
      debugPrint('Offer fetch error: $e');
    } finally {
      _isFetching = false;
    }
  }

  String _buildOffersEndpoint() {
    final params = StringBuffer();
    params.write('latitude=$userLatitude');
    params.write('&longitude=$userLongitude');
    params.write(
      '&serviceType=${Uri.encodeQueryComponent(ServiceType.normalize(selectedPreference))}',
    );
    params.write('&dateTime=${Uri.encodeQueryComponent(_formattedNow())}');
    params.write('&page=$currentPage');
    params.write('&limit=$pageLimit');

    return '${Urls.getTodayOffersUrl}?${params.toString()}';
  }

  bool get _hasUsableLocation => userLatitude != 0.0 || userLongitude != 0.0;

  String _formattedNow() {
    final iso = DateTime.now().toUtc().toIso8601String();
    final dotIndex = iso.indexOf('.');
    if (dotIndex == -1) return iso;
    return '${iso.substring(0, dotIndex)}Z';
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels <
        scrollController.position.maxScrollExtent * 0.85) {
      return;
    }

    if (hasNextPage && !isLoading && !isLoadingMore && !_isFetching) {
      currentPage++;
      _fetchOffers(isRefresh: false);
    }
  }

  void _handleError(String message) {
    hasError = true;
    errorMessage = message;
    isLoading = false;
    isLoadingMore = false;
    update([foodsId]);
  }

  String _parseError(String error) {
    if (error.contains('SocketException') ||
        error.contains('Failed host lookup')) {
      return 'Network error. Please check your connection.';
    }
    if (error.toLowerCase().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (error.contains('Connection refused')) {
      return 'Could not connect to server.';
    }
    return 'Unable to load offers. Please try again.';
  }
}
