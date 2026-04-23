// lib/core/service/notification_services.dart

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

// ─────────────────────────────────────────────────────────────
// Notification type enum
// ─────────────────────────────────────────────────────────────
enum EatPlekNotificationType {
  orderAccepted,
  orderRejected,
  orderReady,
  orderPickedUp,
  orderDelivered,
  orderCancelled,
  timeSuggestion,
  promo,
  general,
  unknown,
}

EatPlekNotificationType _parseNotificationType(String? raw) {
  switch (raw?.toLowerCase().trim()) {
    case 'order_accepted':
      return EatPlekNotificationType.orderAccepted;
    case 'order_rejected':
      return EatPlekNotificationType.orderRejected;
    case 'order_ready':
      return EatPlekNotificationType.orderReady;
    case 'order_picked_up':
      return EatPlekNotificationType.orderPickedUp;
    case 'order_delivered':
      return EatPlekNotificationType.orderDelivered;
    case 'order_cancelled':
      return EatPlekNotificationType.orderCancelled;
    case 'time_suggestion':
      return EatPlekNotificationType.timeSuggestion;
    case 'promo':
      return EatPlekNotificationType.promo;
    case 'general':
      return EatPlekNotificationType.general;
    default:
      return EatPlekNotificationType.unknown;
  }
}

// ─────────────────────────────────────────────────────────────
// NotificationService singleton
// ─────────────────────────────────────────────────────────────
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const String _oneSignalAppId = '84f1ab18-029d-4b73-afa1-8030e50ed0dc';

  static const String _orderChannelId = 'orders_channel';
  static const String _orderChannelName = 'Order Updates';
  static const String _promoChannelId = 'promo_channel';
  static const String _promoChannelName = 'Promotions & Offers';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  GlobalKey<NavigatorState>? navigatorKey;

  // ─────────────────────────────────────────────────────────────
  // Initialize
  // ─────────────────────────────────────────────────────────────
  Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    this.navigatorKey = navigatorKey;

    await _initLocalNotifications();
    await _initOneSignal();

    log('[NotificationService] initialised ✓');
  }

  // ─────────────────────────────────────────────────────────────
  // Local Notifications setup
  // ─────────────────────────────────────────────────────────────
  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _orderChannelId,
        _orderChannelName,
        description: 'Updates about your food orders',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Colors.orange,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _promoChannelId,
        _promoChannelName,
        description: 'Deals, discounts, and new restaurants near you',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    log('[LocalNotifications] initialised ✓');
  }

  // ─────────────────────────────────────────────────────────────
  // OneSignal setup
  // ─────────────────────────────────────────────────────────────
  Future<void> _initOneSignal() async {
    OneSignal.Debug.setLogLevel(
      kDebugMode ? OSLogLevel.verbose : OSLogLevel.none,
    );

    // Register foreground listener BEFORE initialize
    OneSignal.Notifications.addForegroundWillDisplayListener((event) async {
      log(
        '[OneSignal] foreground — displaying via flutter_local_notifications',
      );

      // Prevent OneSignal from showing its own notification
      event.preventDefault();

      final notification = event.notification;
      final data = notification.additionalData ?? {};
      final type = _parseNotificationType(data['type']?.toString());

      await _showNotification(
        id: notification.notificationId.hashCode,
        title: notification.title ?? _defaultTitle(type),
        body: notification.body ?? '',
        type: type,
        payload: data.map((k, v) => MapEntry(k, v.toString())),
      );
    });

    OneSignal.initialize(_oneSignalAppId);
    await OneSignal.Notifications.requestPermission(true);

    // Handle notification tap from background/killed
    OneSignal.Notifications.addClickListener((event) {
      log('[OneSignal] tapped: ${event.notification.additionalData}');
      _navigateFromPayload(event.notification.additionalData ?? {});
    });

    log('[OneSignal] initialised ✓ | AppId: $_oneSignalAppId');
  }

  // ─────────────────────────────────────────────────────────────
  // Show notification via flutter_local_notifications
  // ─────────────────────────────────────────────────────────────
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required EatPlekNotificationType type,
    Map<String, String>? payload,
  }) async {
    final channelId = _channelIdForType(type);
    final channelName = _channelNameForType(type);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          importance:
              type == EatPlekNotificationType.promo
                  ? Importance.high
                  : Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          color: const Color(0xFFFF6B35),
          icon: '@mipmap/ic_launcher',
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload?.entries.map((e) => '${e.key}=${e.value}').join('&'),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Handle notification tap
  // ─────────────────────────────────────────────────────────────
  void _onNotificationTap(NotificationResponse response) {
    log('[LocalNotifications] tapped — payload: ${response.payload}');

    if (response.payload == null || response.payload!.isEmpty) return;

    // Parse payload back from query string format
    final Map<String, dynamic> data = {};
    for (final part in response.payload!.split('&')) {
      final kv = part.split('=');
      if (kv.length == 2) {
        data[kv[0]] = kv[1];
      }
    }

    _navigateFromPayload(data);
  }

  // ─────────────────────────────────────────────────────────────
  // Navigation
  // ─────────────────────────────────────────────────────────────
  void _navigateFromPayload(Map<String, dynamic> payload) {
    final navigator = navigatorKey?.currentState;
    if (navigator == null) {
      log('[Nav] navigatorKey not set — cannot navigate');
      return;
    }

    final type = _parseNotificationType(payload['type']?.toString());
    final orderId = payload['orderId']?.toString();
    final productId = payload['productId']?.toString();
    final vendorId = payload['vendorId']?.toString();

    log(
      '[Nav] type=$type orderId=$orderId productId=$productId vendorId=$vendorId',
    );

    switch (type) {
      case EatPlekNotificationType.orderAccepted:
      case EatPlekNotificationType.orderRejected:
      case EatPlekNotificationType.orderReady:
      case EatPlekNotificationType.orderPickedUp:
      case EatPlekNotificationType.orderDelivered:
      case EatPlekNotificationType.orderCancelled:
      case EatPlekNotificationType.timeSuggestion:
        if (orderId != null) {
          // TODO: Get.toNamed(Routes.orderDetails, arguments: orderId);
          log('[Nav] → Order Details: $orderId');
        }
        break;
      case EatPlekNotificationType.promo:
        if (productId != null && vendorId != null) {
          // TODO: Get.toNamed(Routes.productDetail, arguments: {...});
          log('[Nav] → Product Detail: product=$productId vendor=$vendorId');
        } else {
          // TODO: Get.toNamed(Routes.promos);
          log('[Nav] → Promos screen');
        }
        break;
      case EatPlekNotificationType.general:
      case EatPlekNotificationType.unknown:
        break;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // User identification
  // ─────────────────────────────────────────────────────────────

  /// Call after successful login
  void setUser(String userId) {
    OneSignal.login(userId);
    log('[OneSignal] user set: $userId');
  }

  /// Call on logout
  void clearUser() {
    OneSignal.logout();
    log('[OneSignal] user cleared');
  }

  /// Tag device for segmented campaigns
  void setTags(Map<String, dynamic> tags) {
    OneSignal.User.addTags(tags);
    log('[OneSignal] tags set: $tags');
  }

  // ─────────────────────────────────────────────────────────────
  // Utility
  // ─────────────────────────────────────────────────────────────
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

String _channelIdForType(EatPlekNotificationType type) {
  switch (type) {
    case EatPlekNotificationType.promo:
      return 'promo_channel';
    default:
      return 'orders_channel';
  }
}

String _channelNameForType(EatPlekNotificationType type) {
  switch (type) {
    case EatPlekNotificationType.promo:
      return 'Promotions & Offers';
    default:
      return 'Order Updates';
  }
}

String _defaultTitle(EatPlekNotificationType type) {
  switch (type) {
    case EatPlekNotificationType.orderAccepted:
      return 'Order Accepted 🎉';
    case EatPlekNotificationType.orderRejected:
      return 'Order Rejected';
    case EatPlekNotificationType.orderReady:
      return 'Your Order is Ready!';
    case EatPlekNotificationType.orderPickedUp:
      return 'Order Picked Up 🛵';
    case EatPlekNotificationType.orderDelivered:
      return 'Order Delivered ✅';
    case EatPlekNotificationType.orderCancelled:
      return 'Order Cancelled';
    case EatPlekNotificationType.timeSuggestion:
      return 'New Time Suggested';
    case EatPlekNotificationType.promo:
      return 'Special Offer 🔥';
    default:
      return 'EatPlek';
  }
}
