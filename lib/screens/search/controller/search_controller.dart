import 'dart:async';

import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:eatplek_app/screens/home/controller/home_controller.dart';
import 'package:eatplek_app/screens/home/model/new_home_model.dart';
import 'package:eatplek_app/screens/home/view/widget/order_preference_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';

class SearchVendorController extends GetxController {
  // ─── Update IDs ────────────────────────────────────────────────────────────
  static const String headerId = 'searchHeader';
  static const String vendorsId = 'searchVendors';

  // ─── State ─────────────────────────────────────────────────────────────────
  List<Vendor> vendors = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasError = false;
  String errorMessage = '';

  // ─── Pagination ────────────────────────────────────────────────────────────
  int currentPage = 1;
  static const int pageLimit = 10;
  bool hasNextPage = false;

  // ─── Search & Sort ─────────────────────────────────────────────────────────
  String searchKeyword = '';
  String selectedSort = ''; // '' | 'distance' | 'rating'

  // ─── Passed from Home ──────────────────────────────────────────────────────
  late double userLatitude;
  late double userLongitude;
  String serviceType = ''; // raw api value e.g. 'delivery'
  String serviceLabel = ''; // display label e.g. '🛵 Delivery'

  // ─── Internal ──────────────────────────────────────────────────────────────
  late FittorConnect _apiClient;
  late ScrollController scrollController;
  late TextEditingController searchTextController;
  Timer? _debounceTimer;
  bool _isFetching = false;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();

    try {
      _apiClient = Get.find<FittorConnect>();
    } catch (_) {
      _apiClient = FittorConnect();
      Get.put<FittorConnect>(_apiClient);
    }

    // Read arguments passed from HomeController
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    userLatitude = (args['latitude'] as double?) ?? 0.0;
    userLongitude = (args['longitude'] as double?) ?? 0.0;
    serviceType = (args['serviceType'] as String?) ?? '';
    serviceLabel = (args['serviceLabel'] as String?) ?? '';

    scrollController = ScrollController();
    searchTextController = TextEditingController();

    scrollController.addListener(_onScroll);

    // Initial fetch — load all vendors immediately
    _fetchVendors(isRefresh: true);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchTextController.dispose();
    super.onClose();
  }

  // ─── Search ────────────────────────────────────────────────────────────────

  /// Called from the TextField's onChanged
  void onSearchChanged(String value) {
    // Cancel any pending timer
    _debounceTimer?.cancel();

    // Update UI for clear button immediately
    searchKeyword = value;
    update([headerId]);

    // Fire API after 500 ms of inactivity
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      debugPrint('🔍 Debounce fired — searching: "$searchKeyword"');
      currentPage = 1;
      vendors.clear();
      _fetchVendors(isRefresh: true);
    });
  }

  /// Clear search field and reload all vendors
  void clearSearch() {
    searchTextController.clear();
    searchKeyword = '';
    currentPage = 1;
    vendors.clear();
    update([headerId]);
    _fetchVendors(isRefresh: true);
  }

  // ─── Sort ──────────────────────────────────────────────────────────────────

  void onSortSelected(String sort) {
    // Tap same sort to deselect
    selectedSort = (selectedSort == sort) ? '' : sort;
    currentPage = 1;
    vendors.clear();
    update([headerId]);
    _fetchVendors(isRefresh: true);
  }

  // ─── Service Type ──────────────────────────────────────────────────────────

  void onServiceTypeChipTapped() {
    final homeController = Get.find<HomeController>();

    OrderPreferenceDialog.show(
      currentPreference: homeController.orderPreference,
      availableServices: homeController.availableServices,
      banners: homeController.banners,
      onPreferenceSelected: (String selectedPreference) {
        debugPrint('🔄 SearchView: service type changed → $selectedPreference');

        // Update HomeController (this also saves to Store inside home controller)
        homeController.orderPreference = selectedPreference;
        Store.deliveryPreference = selectedPreference;
        homeController.update([HomeController.orderPreferenceId]);

        // Derive new service type for this screen
        serviceLabel = selectedPreference;
        serviceType = _extractServiceType(selectedPreference);

        // Re-fetch with new service type
        currentPage = 1;
        vendors.clear();
        update([headerId]);
        _fetchVendors(isRefresh: true);

        // Trigger home to refresh vendors too
        homeController.refreshVendors();
      },
    );
  }

  // ─── API ───────────────────────────────────────────────────────────────────

  Future<void> _fetchVendors({required bool isRefresh}) async {
    if (_isFetching) return;

    try {
      _isFetching = true;

      if (isRefresh) {
        isLoading = true;
        hasError = false;
        errorMessage = '';
        update([vendorsId]);
      } else {
        isLoadingMore = true;
        update([vendorsId]);
      }

      final String formattedDateTime = _formattedNow();

      // Build query string
      final params = StringBuffer();
      params.write('latitude=$userLatitude');
      params.write('&longitude=$userLongitude');
      params.write('&serviceType=$serviceType');
      params.write('&dateTime=$formattedDateTime');
      params.write('&page=$currentPage');
      params.write('&limit=$pageLimit');

      if (searchKeyword.trim().isNotEmpty) {
        params.write('&search=${Uri.encodeComponent(searchKeyword.trim())}');
      }
      if (selectedSort.isNotEmpty) {
        params.write('&sortBy=$selectedSort');
      }

      final endpoint = '${Urls.getVendorsUrl}?${params.toString()}';
      debugPrint('🔗 Vendors endpoint: $endpoint');

      final response = await _apiClient
          .get(endpoint: endpoint)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Request timed out'),
          );

      if (response != null) {
        // Expecting same structure as home — adapt if your model differs
        final newHomeModel = NewHomeModel.fromJson(response);

        if (newHomeModel.success == true && newHomeModel.data != null) {
          final newVendors = newHomeModel.data!.vendors ?? [];

          // Pagination meta — adjust field names to match your actual API response
          // If your API returns pagination info separately, parse it here
          hasNextPage = newVendors.length >= pageLimit;

          if (isRefresh) {
            vendors = newVendors;
          } else {
            vendors.addAll(newVendors);
          }

          isLoading = false;
          isLoadingMore = false;
          hasError = false;
          update([vendorsId]);
          debugPrint('✅ Vendors loaded: ${vendors.length} total');
        } else {
          _handleError(newHomeModel.message ?? 'Something went wrong');
        }
      } else {
        _handleError('No response from server');
      }
    } on TimeoutException {
      _handleError('Request timed out. Please try again.');
    } catch (e) {
      _handleError(_parseError(e.toString()));
      debugPrint('❌ Vendor fetch error: $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<void> retryFetch() async {
    currentPage = 1;
    vendors.clear();
    await _fetchVendors(isRefresh: true);
  }

  // ─── Scroll ────────────────────────────────────────────────────────────────

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.9) {
      // No pagination during active search
      if (searchKeyword.isNotEmpty) return;

      if (hasNextPage && !isLoadingMore && !isLoading && !_isFetching) {
        currentPage++;
        debugPrint('📜 Scroll → loading page $currentPage');
        _fetchVendors(isRefresh: false);
      }
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _formattedNow() {
    final iso = DateTime.now().toUtc().toIso8601String();
    return '${iso.substring(0, iso.indexOf('.'))}Z';
  }

  String _extractServiceType(String preference) {
    if (preference.contains('Delivery')) return 'delivery';
    if (preference.contains('Takeaway')) return 'takeaway';
    if (preference.contains('Dine-in')) return 'dine-in';
    if (preference.contains('SpecialBooking') ||
        preference.contains('Special Booking'))
      // ignore: curly_braces_in_flow_control_structures
      return 'car-dine-in';
    if (preference.contains('Pickup')) return 'pickup';
    return 'delivery';
  }

  void _handleError(String message) {
    hasError = true;
    errorMessage = message;
    isLoading = false;
    isLoadingMore = false;
    update([vendorsId]);
    debugPrint('🔴 Error: $message');
  }

  String _parseError(String error) {
    if (error.contains('SocketException') ||
        error.contains('Failed host lookup')) {
      return 'Network error. Please check your connection.';
    } else if (error.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (error.contains('Connection refused')) {
      return 'Could not connect to server.';
    }
    return 'Unable to load vendors. Please try again.';
  }
}
