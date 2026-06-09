import 'dart:async';
import 'dart:developer';

import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/util/service_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../../core/routes/routes.dart';
import '../model/orders_api_model.dart';

// ─── Per-tab pagination + cache state ────────────────────────────────────────
class TabOrderState {
  List<SingleOrder> orders = [];
  int currentPage = 0;
  int totalPages = 1;

  bool isInitialLoading = false;
  bool isLoadingMore = false;
  bool hasError = false;
  String errorMessage = '';

  bool get hasMore => currentPage < totalPages;
  bool get isFetched => currentPage > 0;
  bool get isEmpty =>
      !isInitialLoading && !hasError && orders.isEmpty && isFetched;
}

class OrdersController extends GetxController {
  final FittorConnect _apiClient = FittorConnect();

  static const int _pageLimit = 10;

  // ── Tab definitions (display order as requested) ──────────────────────────
  final List<Map<String, String>> tabs = const [
    {'label': ServiceType.dineIn, 'serviceType': ServiceType.dineIn},
    {'label': ServiceType.takeaway, 'serviceType': ServiceType.takeaway},
    {'label': ServiceType.delivery, 'serviceType': ServiceType.delivery},
    {'label': ServiceType.carDineIn, 'serviceType': ServiceType.carDineIn},
    {'label': 'Prebook', 'serviceType': 'prebook'},
  ];

  late List<TabOrderState> tabStates;
  int currentTabIndex = 0;
  Timer? _pollingTimer;
  bool _isPolling = false;
  bool _isPollingActive = false;

  // ── Per-tab accessors ─────────────────────────────────────────────────────
  TabOrderState stateForTab(int index) => tabStates[index];
  List<SingleOrder> ordersForTab(int index) => tabStates[index].orders;
  bool isInitialLoadingForTab(int index) => tabStates[index].isInitialLoading;
  bool isLoadingMoreForTab(int index) => tabStates[index].isLoadingMore;
  bool hasErrorForTab(int index) => tabStates[index].hasError;
  String errorMessageForTab(int index) => tabStates[index].errorMessage;
  bool isEmptyForTab(int index) => tabStates[index].isEmpty;

  @override
  void onInit() {
    super.onInit();

    tabStates = List.generate(tabs.length, (_) => TabOrderState());

    // ✅ Do NOT call _fetchOrders(0) here.
    // OrdersView is mounted inside IndexedStack at app start even when the
    // orders tab is not visible. Fetching here fires the API on every app
    // launch regardless of which tab the user is on.
    // BottomNavController.setBottomBarIndex() calls fetchFirstTabIfNeeded()
    // when the user actually taps the orders tab for the first time.
  }

  /// Called by BottomNavController when the orders tab becomes active.
  /// Fetches the first tab only if it hasn't been loaded yet.
  void fetchFirstTabIfNeeded() {
    if (!tabStates[0].isFetched && !tabStates[0].isInitialLoading) {
      _fetchOrders(0);
    }
  }

  void startPolling() {
    if (isClosed) return;
    _isPollingActive = true;
    fetchFirstTabIfNeeded();
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _pollSelectedTab();
    });
  }

  void stopPolling() {
    _isPollingActive = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void selectTab(int index) {
    if (index < 0 || index >= tabs.length) return;
    currentTabIndex = index;
    if (!tabStates[index].isInitialLoading) {
      _fetchOrders(index);
    }
    update(['tab_bar']);
  }

  @override
  void onClose() {
    stopPolling();
    super.onClose();
  }

  // ── Scroll → load more ────────────────────────────────────────────────────
  void loadMoreForTab(int index) => _loadMore(index);

  // ── Initial fetch (resets state, shows skeleton) ──────────────────────────
  Future<void> _fetchOrders(int index) async {
    final state = tabStates[index];
    if (state.isInitialLoading) return;

    state
      ..orders = []
      ..currentPage = 0
      ..totalPages = 1
      ..isInitialLoading = true
      ..isLoadingMore = false
      ..hasError = false
      ..errorMessage = '';
    update(['orders_tab_$index']);

    await _loadPage(index, page: 1);

    state.isInitialLoading = false;
    update(['orders_tab_$index']);
  }

  // ── Load next page ────────────────────────────────────────────────────────
  Future<void> _loadMore(int index) async {
    final state = tabStates[index];
    if (state.isLoadingMore || !state.hasMore || state.isInitialLoading) return;

    state.isLoadingMore = true;
    update(['orders_tab_$index']);

    await _loadPage(index, page: state.currentPage + 1);

    state.isLoadingMore = false;
    update(['orders_tab_$index']);
  }

  // ── Core API call ─────────────────────────────────────────────────────────
  Future<void> _loadPage(int index, {required int page}) async {
    final state = tabStates[index];
    final serviceType = tabs[index]['serviceType']!;

    try {
      final endpoint =
          '${Urls.getordersUrl}?page=$page&limit=$_pageLimit&serviceType=${Uri.encodeQueryComponent(serviceType)}';

      debugPrint('📦 Fetching orders: $endpoint');
      final response = await _apiClient.get(endpoint: endpoint);
      log('Orders API [$serviceType] page $page: $response');

      if (response != null && response is Map<String, dynamic>) {
        final parsed = OrdersApiModel.fromJson(response);

        if (parsed.success == true && parsed.data != null) {
          final newOrders = parsed.data!.orders ?? [];
          state.orders = [...state.orders, ...newOrders];
          state.currentPage = parsed.data!.pagination?.page ?? page;
          state.totalPages = parsed.data!.pagination?.totalPages ?? 1;
          state.hasError = false;
          state.errorMessage = '';
          debugPrint(
            '✅ [$serviceType] Loaded ${newOrders.length} orders '
            '(page ${state.currentPage}/${state.totalPages})',
          );
        } else {
          state.hasError = true;
          state.errorMessage = parsed.message ?? 'Failed to load orders';
        }
      } else {
        state.hasError = true;
        state.errorMessage = 'Invalid response from server';
      }
    } catch (e) {
      debugPrint('❌ Error fetching orders [$serviceType]: $e');
      state.hasError = true;
      state.errorMessage = e.toString().replaceAll('Exception: ', '');
    }
  }

  // ── Retry on error ────────────────────────────────────────────────────────
  Future<OrdersApiModel> _requestOrdersPage(
    int index, {
    required int page,
  }) async {
    final serviceType = tabs[index]['serviceType']!;
    final endpoint =
        '${Urls.getordersUrl}?page=$page&limit=$_pageLimit&serviceType=${Uri.encodeQueryComponent(serviceType)}';

    debugPrint('📦 Polling orders: $endpoint');
    final response = await _apiClient.get(endpoint: endpoint);
    log('Orders poll [$serviceType] page $page: $response');

    if (response is Map<String, dynamic>) {
      return OrdersApiModel.fromJson(response);
    }

    return OrdersApiModel(
      success: false,
      message: 'Invalid response from server',
    );
  }

  Future<void> _pollSelectedTab() async {
    if (!_isPollingActive) return;
    if (_isPolling || isClosed) return;
    final index = currentTabIndex;
    if (index < 0 || index >= tabStates.length) return;

    final state = tabStates[index];
    if (state.isInitialLoading || state.isLoadingMore) return;

    if (!state.isFetched) {
      await _fetchOrders(index);
      return;
    }

    _isPolling = true;
    try {
      final pagesToRefresh = state.currentPage <= 0 ? 1 : state.currentPage;
      final refreshedOrders = <SingleOrder>[];
      int refreshedCurrentPage = state.currentPage;
      int refreshedTotalPages = state.totalPages;

      for (var page = 1; page <= pagesToRefresh; page++) {
        final parsed = await _requestOrdersPage(index, page: page);
        if (parsed.success != true || parsed.data == null) return;

        refreshedOrders.addAll(parsed.data!.orders ?? []);
        refreshedCurrentPage = parsed.data!.pagination?.page ?? page;
        refreshedTotalPages = parsed.data!.pagination?.totalPages ?? 1;
      }

      state
        ..orders = refreshedOrders
        ..currentPage = refreshedCurrentPage
        ..totalPages = refreshedTotalPages
        ..hasError = false
        ..errorMessage = '';
      update(['orders_tab_$index']);
    } catch (e) {
      debugPrint('⚠️ Orders polling skipped: $e');
    } finally {
      _isPolling = false;
    }
  }

  void retryFetch(int index) => _fetchOrders(index);

  // ── Navigate to details — passes full SingleOrder so details screen
  //    doesn't need a second API call ──────────────────────────────────────
  void viewOrderDetails(SingleOrder order) {
    Get.toNamed(Routes.orderDetailsView, arguments: {'order': order});
  }
}
