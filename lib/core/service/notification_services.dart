// lib/core/service/notification_services.dart

import 'dart:async';
import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart'; // ← ADD THIS

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

/// Parses the raw 'type' string from FCM payload into an enum
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
// Top-level background handler — must be outside any class
// ─────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('[BG] message received: ${message.messageId} | data: ${message.data}');

  if (message.notification != null) {
    log(
      '[BG] notification payload present — FCM handles display, skipping duplicate',
    );
    return;
  }

  final type = _parseNotificationType(message.data['type']);
  await _showBackgroundNotification(message, type);
}

Future<void> _showBackgroundNotification(
  RemoteMessage message,
  EatPlekNotificationType type,
) async {
  await AwesomeNotifications().initialize(null, [
    _buildOrderChannel(),
    _buildPromoChannel(),
  ], debug: kDebugMode);

  final title = message.data['title']?.toString() ?? _defaultTitle(type);
  final body = message.data['body']?.toString() ?? '';
  final channelKey = _channelKeyForType(type);
  final id =
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch;

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: id,
      channelKey: channelKey,
      title: title,
      body: body,
      notificationLayout: NotificationLayout.Default,
      payload: message.data.map((k, v) => MapEntry(k, v.toString())),
      category: _categoryForType(type),
      autoDismissible: true,
    ),
    actionButtons: _actionButtonsForType(type),
  );
}

// ─────────────────────────────────────────────────────────────
// NotificationService singleton
// ─────────────────────────────────────────────────────────────
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // ── ADD: OneSignal App ID ─────────────────────────────────
  static const String _oneSignalAppId = '84f1ab18-029d-4b73-afa1-8030e50ed0dc';

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  String? fcmToken;
  GlobalKey<NavigatorState>? navigatorKey;

  // ── Public API ──────────────────────────────────────────────

  Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    this.navigatorKey = navigatorKey;

    await _initAwesomeNotifications();
    await _requestFcmPermissions();
    await _fetchFcmToken();
    _listenForeground();
    _listenTapFromBackground();
    await _handleTerminatedStateTap();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // ── ADD: OneSignal init after everything else ──────────
    await _initOneSignal();

    log('[NotificationService] initialised ✓');
  }

  // ── Existing methods — UNCHANGED ────────────────────────────

  Future<void> _initAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [_buildOrderChannel(), _buildPromoChannel()],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'orders_group',
          channelGroupName: 'Order Updates',
        ),
        NotificationChannelGroup(
          channelGroupKey: 'promo_group',
          channelGroupName: 'Promotions',
        ),
      ],
      debug: kDebugMode,
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceived,
      onNotificationCreatedMethod: _onNotificationCreated,
      onNotificationDisplayedMethod: _onNotificationDisplayed,
      onDismissActionReceivedMethod: _onDismissActionReceived,
    );

    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        await AwesomeNotifications().requestPermissionToSendNotifications(
          permissions: [
            NotificationPermission.Alert,
            NotificationPermission.Sound,
            NotificationPermission.Badge,
            NotificationPermission.Vibration,
          ],
        );
      });
    }
  }

  Future<void> _requestFcmPermissions() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log('[FCM] auth status: ${settings.authorizationStatus}');
  }

  Future<void> _fetchFcmToken() async {
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 3);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        fcmToken = await _fcm.getToken();
        log('[FCM] token: $fcmToken');

        // final connect = Get.find<FittorConnect>();
        // await connect.post('/user/fcm-token', body: {'fcmToken': fcmToken});

        _fcm.onTokenRefresh.listen((token) {
          fcmToken = token;
          log('[FCM] token refreshed: $token');
        });

        return;
      } catch (e) {
        log('[FCM] Token fetch attempt $attempt/$maxRetries failed: $e');
        if (attempt < maxRetries) {
          await Future.delayed(retryDelay);
        } else {
          log('[FCM] All retries exhausted. App will run without FCM token.');
        }
      }
    }
  }

  // ── ADD: OneSignal initialisation ───────────────────────────
  Future<void> _initOneSignal() async {
    OneSignal.Debug.setLogLevel(
      kDebugMode ? OSLogLevel.verbose : OSLogLevel.none,
    );

    OneSignal.initialize(_oneSignalAppId);

    OneSignal.Notifications.addForegroundWillDisplayListener((event) async {
      log('[OneSignal] foreground received — showing via AwesomeNotifications');

      final notification = event.notification;
      final title = notification.title ?? 'EatPlek';
      final body = notification.body ?? '';
      final data = notification.additionalData ?? {};
      final type = _parseNotificationType(data['type']?.toString());
      final id =
          notification.notificationId.hashCode ??
          DateTime.now().millisecondsSinceEpoch;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: _channelKeyForType(type),
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          payload: data.map((k, v) => MapEntry(k, v.toString())),
          category: _categoryForType(type),
          autoDismissible: true,
        ),
        actionButtons: _actionButtonsForType(type),
      );
    });

    await OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addClickListener((event) {
      log('[OneSignal] tapped: ${event.notification.additionalData}');
      _navigateFromPayload(event.notification.additionalData ?? {});
    });

    log('[OneSignal] initialised ✓ | AppId: $_oneSignalAppId');
  }

  // ── ADD: Identify user to OneSignal after login ─────────────

  /// Call this in your LoginController after successful login.
  /// OneSignal will associate this device's push token with the user ID
  /// so your backend can send targeted pushes.
  ///
  /// ```dart
  /// // In LoginController, after saving user:
  /// NotificationService.instance.setUser(user.id.toString());
  /// ```
  void setUser(String userId) {
    OneSignal.login(userId);
    log('[OneSignal] user set: $userId');
  }

  /// Call this in your logout flow.
  void clearUser() {
    OneSignal.logout();
    log('[OneSignal] user cleared');
  }

  /// Tag this device for segmented campaigns (city, plan type, etc.)
  ///
  /// ```dart
  /// NotificationService.instance.setTags({
  ///   'city': 'Malappuram',
  ///   'user_type': 'customer',
  /// });
  /// ```
  void setTags(Map<String, dynamic> tags) {
    OneSignal.User.addTags(tags);
    log('[OneSignal] tags set: $tags');
  }

  // ── Existing methods — UNCHANGED ────────────────────────────
  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((message) async {
      log('[FCM Foreground] ${message.messageId} | ${message.data}');
      // OneSignal handles background/killed — FCM handles foreground display
      final type = _parseNotificationType(message.data['type']);
      await _showForegroundNotification(message, type);
    });
  }

  void _listenTapFromBackground() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('[FCM] opened from background tap: ${message.data}');
      _navigateFromPayload(message.data);
    });
  }

  Future<void> _handleTerminatedStateTap() async {
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      log('[FCM] launched from terminated state: ${initial.data}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateFromPayload(initial.data);
      });
    }
  }

  Future<void> _showForegroundNotification(
    RemoteMessage message,
    EatPlekNotificationType type,
  ) async {
    final title =
        message.data['title']?.toString() ??
        message.notification?.title ??
        _defaultTitle(type);
    final body =
        message.data['body']?.toString() ?? message.notification?.body ?? '';
    final channelKey = _channelKeyForType(type);
    final id =
        message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        payload: message.data.map((k, v) => MapEntry(k, v.toString())),
        category: _categoryForType(type),
        autoDismissible: true,
      ),
      actionButtons: _actionButtonsForType(type),
    );
  }

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
          log('[Nav] → Order Details: $orderId');
        }
        break;

      case EatPlekNotificationType.promo:
        if (productId != null && vendorId != null) {
          log('[Nav] → Product Detail: product=$productId vendor=$vendorId');
        } else {
          log('[Nav] → Promos screen');
        }
        break;

      case EatPlekNotificationType.general:
      case EatPlekNotificationType.unknown:
        break;
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onActionReceived(ReceivedAction action) async {
    log(
      '[AwesomeNotif] action: ${action.buttonKeyPressed} | payload: ${action.payload}',
    );

    final payload = action.payload ?? {};
    final buttonKey = action.buttonKeyPressed;

    if (buttonKey == 'view_order' || buttonKey == '') {
      NotificationService.instance._navigateFromPayload(
        payload.map((k, v) => MapEntry(k, v as dynamic)),
      );
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreated(
    ReceivedNotification notification,
  ) async {
    log('[AwesomeNotif] created: ${notification.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayed(
    ReceivedNotification notification,
  ) async {
    log('[AwesomeNotif] displayed: ${notification.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> _onDismissActionReceived(ReceivedAction action) async {
    log('[AwesomeNotif] dismissed: ${action.id}');
  }

  // ── Utility ──────────────────────────────────────────────────

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    log('[FCM] subscribed to: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    log('[FCM] unsubscribed from: $topic');
  }
}

// ─────────────────────────────────────────────────────────────
// Channel builders — UNCHANGED
// ─────────────────────────────────────────────────────────────

NotificationChannel _buildOrderChannel() => NotificationChannel(
  channelGroupKey: 'orders_group',
  channelKey: 'orders_channel',
  channelName: 'Order Updates',
  channelDescription: 'Updates about your food orders',
  defaultColor: const Color(0xFFFF6B35),
  ledColor: Colors.orange,
  importance: NotificationImportance.Max,
  channelShowBadge: true,
  playSound: true,
  enableVibration: true,
  enableLights: true,
  defaultRingtoneType: DefaultRingtoneType.Notification,
);

NotificationChannel _buildPromoChannel() => NotificationChannel(
  channelGroupKey: 'promo_group',
  channelKey: 'promo_channel',
  channelName: 'Promotions & Offers',
  channelDescription: 'Deals, discounts, and new restaurants near you',
  defaultColor: const Color(0xFFFF6B35),
  ledColor: Colors.orange,
  importance: NotificationImportance.High,
  channelShowBadge: true,
  playSound: true,
  enableVibration: true,
  enableLights: true,
  defaultRingtoneType: DefaultRingtoneType.Notification,
);

// ─────────────────────────────────────────────────────────────
// Helpers — UNCHANGED
// ─────────────────────────────────────────────────────────────

String _channelKeyForType(EatPlekNotificationType type) {
  switch (type) {
    case EatPlekNotificationType.promo:
      return 'promo_channel';
    default:
      return 'orders_channel';
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

NotificationCategory? _categoryForType(EatPlekNotificationType type) {
  switch (type) {
    case EatPlekNotificationType.promo:
      return NotificationCategory.Promo;
    case EatPlekNotificationType.orderDelivered:
      return NotificationCategory.Status;
    default:
      return null;
  }
}

List<NotificationActionButton>? _actionButtonsForType(
  EatPlekNotificationType type,
) {
  switch (type) {
    case EatPlekNotificationType.orderAccepted:
    case EatPlekNotificationType.orderReady:
    case EatPlekNotificationType.orderPickedUp:
    case EatPlekNotificationType.orderDelivered:
    case EatPlekNotificationType.timeSuggestion:
      return [
        NotificationActionButton(
          key: 'view_order',
          label: 'View Order',
          actionType: ActionType.Default,
        ),
      ];
    case EatPlekNotificationType.promo:
      return [
        NotificationActionButton(
          key: 'view_order',
          label: 'View Offer',
          actionType: ActionType.Default,
        ),
      ];
    default:
      return null;
  }
}
