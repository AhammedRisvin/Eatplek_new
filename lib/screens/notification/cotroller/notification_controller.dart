import 'package:eatplek_app/core/network/api_client.dart';
import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/notification_model.dart' as model;

class NotificationController extends GetxController {
  // ─── State ────────────────────────────────────────────────────────────────
  List<model.Notification> notifications = [];

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasError = false;
  String errorMessage = '';

  bool hasMore = false;
  String? nextCursor;

  int unreadCount = 0;
  bool isMarkingAllRead = false;

  static const int _limit = 20;

  static const String listId = 'notificationList';
  static const String unreadBadgeId = 'unreadBadge';
  static const String fabId = 'notificationFab';

  late FittorConnect _apiClient;
  late ScrollController scrollController;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();

    try {
      _apiClient = Get.find<FittorConnect>();
    } catch (_) {
      _apiClient = FittorConnect();
      Get.put<FittorConnect>(_apiClient);
    }

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    fetchNotifications(isRefresh: true);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  // ─── Fetch ────────────────────────────────────────────────────────────────

  Future<void> fetchNotifications({required bool isRefresh}) async {
    if (isRefresh) {
      isLoading = true;
      hasError = false;
      errorMessage = '';
      notifications.clear();
      nextCursor = null;
      hasMore = false;
      update([listId, fabId]);
    } else {
      if (!hasMore || isLoadingMore) return;
      isLoadingMore = true;
      update([listId]);
    }

    try {
      String endpoint = '${Urls.getNotificationsUrl}&limit=$_limit';

      if (!isRefresh && nextCursor != null && nextCursor!.isNotEmpty) {
        endpoint += '&cursor=$nextCursor';
      }

      debugPrint('📬 Fetching notifications: $endpoint');

      final response = await _apiClient.get(endpoint: endpoint);

      if (response == null) {
        _handleError('No response from server');
        return;
      }

      final notifModel = model.NotificationModel.fromJson(response);

      if (notifModel.success == true) {
        final newItems = notifModel.data ?? [];

        if (isRefresh) {
          notifications = newItems;
        } else {
          notifications.addAll(newItems);
        }

        hasMore = notifModel.hasMore ?? false;
        nextCursor = notifModel.nextCursor;

        isLoading = false;
        isLoadingMore = false;
        hasError = false;

        // Recount unread locally from loaded notifications
        _recountUnread();

        update([listId, fabId]);
        debugPrint(
          '✅ Notifications loaded: ${notifications.length} | hasMore: $hasMore',
        );
      } else {
        _handleError('Failed to load notifications');
      }
    } catch (e) {
      _handleError(_parseError(e.toString()));
      debugPrint('❌ Notification fetch error: $e');
    }
  }

  // ─── Unread count (called from HomeController) ────────────────────────────

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiClient.get(endpoint: Urls.getUnreadCountUrl);

      if (response != null && response['success'] == true) {
        final count =
            response['unreadCount'] ??
            response['data']?['unreadCount'] ??
            response['data']?['count'] ??
            response['count'] ??
            0;
        unreadCount = (count as num).toInt();
        update([unreadBadgeId]);
        debugPrint('🔔 Unread count: $unreadCount');
      }
    } catch (e) {
      debugPrint('⚠️ Unread count fetch error (non-blocking): $e');
    }
  }

  // ─── Mark all read ────────────────────────────────────────────────────────

  Future<void> markAllAsRead() async {
    if (isMarkingAllRead || unreadCount == 0) return;

    isMarkingAllRead = true;
    update([fabId]);

    try {
      final response = await _apiClient.patch(
        endpoint: Urls.readAllNotificationUrl,
        data: {},
      );

      if (response != null && response['success'] == true) {
        // Optimistically mark all local notifications as read
        notifications =
            notifications.map((n) {
              return model.Notification(
                id: n.id,
                userId: n.userId,
                title: n.title,
                body: n.body,
                imageUrl: n.imageUrl,
                data: n.data,
                isRead: true,
                createdAt: n.createdAt,
              );
            }).toList();

        unreadCount = 0;
        isMarkingAllRead = false;

        update([listId, fabId, unreadBadgeId]);

        Get.snackbar(
          'Done',
          'All notifications marked as read',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
        );

        debugPrint('✅ All notifications marked as read');
      } else {
        isMarkingAllRead = false;
        update([fabId]);
        Get.snackbar('Error', 'Failed to mark all as read. Try again.');
      }
    } catch (e) {
      isMarkingAllRead = false;
      update([fabId]);
      debugPrint('❌ Mark all read error: $e');
      Get.snackbar('Error', 'Something went wrong. Please try again.');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _recountUnread() {
    unreadCount = notifications.where((n) => n.isRead == false).length;
    update([unreadBadgeId]);
  }

  void _handleError(String message) {
    hasError = true;
    errorMessage = message;
    isLoading = false;
    isLoadingMore = false;
    update([listId, fabId]);
    debugPrint('🔴 Notification error: $message');
  }

  String _parseError(String error) {
    if (error.contains('SocketException') ||
        error.contains('Failed host lookup')) {
      return 'Network connection error. Please check your internet.';
    } else if (error.contains('timeout') ||
        error.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else if (error.contains('Connection refused')) {
      return 'Could not connect to server. Please try again.';
    }
    return 'Unable to load notifications. Please try again.';
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.88) {
      if (hasMore && !isLoadingMore && !isLoading) {
        debugPrint('📜 Pagination triggered — fetching more notifications');
        fetchNotifications(isRefresh: false);
      }
    }
  }
}
