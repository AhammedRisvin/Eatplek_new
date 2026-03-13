// lib/services/notification_service.dart

import 'dart:async';
import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// TODO: Replace with your actual route constants
// import 'package:eatplek_app/core/routes/routes.dart';

/// Notification types EatPlek sends from backend
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

  // If FCM message has a 'notification' payload (e.g. sent from Firebase Console),
  // Android already auto-shows its own system notification when app is background/killed.
  // Skip creating an Awesome Notification to avoid showing a duplicate.
  // ✅ Real backend sends data-only so Awesome Notifications will always fire in production.
  if (message.notification != null) {
    log(
      '[BG] notification payload present — FCM handles display, skipping duplicate',
    );
    return;
  }

  final type = _parseNotificationType(message.data['type']);
  await _showBackgroundNotification(message, type);
}

/// Creates an Awesome Notification banner for background data-only messages.
/// Channels must be re-declared here because the isolate is a fresh context.
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

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  String? fcmToken;

  /// Set in main.dart and passed to initialize().
  /// Used to push routes when a notification is tapped.
  GlobalKey<NavigatorState>? navigatorKey;

  // ── Public API ──────────────────────────────────────────────

  /// Call once from main.dart AFTER Firebase.initializeApp().
  ///
  /// ```dart
  /// await NotificationService.instance.initialize(
  ///   navigatorKey: navigatorKey,
  /// );
  /// ```
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

    log('[NotificationService] initialised ✓');
  }

  // ── Private helpers ─────────────────────────────────────────

  Future<void> _initAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      null, // use default launcher icon
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

    // Request permission after first frame so UI is ready
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
    fcmToken = await _fcm.getToken();
    log('[FCM] token: $fcmToken');

    // TODO: Send fcmToken to your backend so it can target this device.
    // Example:
    // final connect = Get.find<FittorConnect>();
    // await connect.post('/user/fcm-token', body: {'fcmToken': fcmToken});

    _fcm.onTokenRefresh.listen((token) {
      fcmToken = token;
      log('[FCM] token refreshed: $token');
      // TODO: re-send refreshed token to backend
    });
  }

  /// Fires while the app is in the FOREGROUND
  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((message) async {
      log('[FCM Foreground] ${message.messageId} | ${message.data}');
      final type = _parseNotificationType(message.data['type']);
      await _showForegroundNotification(message, type);
    });
  }

  /// Fires when the app is in BACKGROUND and user taps the notification
  void _listenTapFromBackground() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('[FCM] opened from background tap: ${message.data}');
      _navigateFromPayload(message.data);
    });
  }

  /// Fires when app was TERMINATED and launched via notification tap
  Future<void> _handleTerminatedStateTap() async {
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      log('[FCM] launched from terminated state: ${initial.data}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateFromPayload(initial.data);
      });
    }
  }

  // ── Foreground notification display ─────────────────────────

  Future<void> _showForegroundNotification(
    RemoteMessage message,
    EatPlekNotificationType type,
  ) async {
    // Prefer title/body from data payload (backend data-only messages),
    // fall back to notification payload (Firebase Console test messages)
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

  // ── Navigation ───────────────────────────────────────────────

  /// Called when the user TAPS a notification.
  ///
  /// Expected payload keys from backend:
  ///   type        → one of the EatPlekNotificationType strings
  ///   orderId     → e.g. "ORD-1234"
  ///   productId   → e.g. "PROD-567"
  ///   vendorId    → e.g. "VND-89"
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
          // TODO: replace with your actual GetX route
          // Get.toNamed(Routes.orderDetails, arguments: orderId);
          log('[Nav] → Order Details: $orderId');
        }
        break;

      case EatPlekNotificationType.promo:
        if (productId != null && vendorId != null) {
          // TODO: navigate to product detail
          // Get.toNamed(Routes.productDetail, arguments: {
          //   'productId': productId,
          //   'vendorId': vendorId,
          // });
          log('[Nav] → Product Detail: product=$productId vendor=$vendorId');
        } else {
          // TODO: navigate to promos screen
          // Get.toNamed(Routes.promos);
          log('[Nav] → Promos screen');
        }
        break;

      case EatPlekNotificationType.general:
      case EatPlekNotificationType.unknown:
        break;
    }
  }

  // ── Awesome Notifications listeners ─────────────────────────

  @pragma('vm:entry-point')
  static Future<void> _onActionReceived(ReceivedAction action) async {
    log(
      '[AwesomeNotif] action: ${action.buttonKeyPressed} | payload: ${action.payload}',
    );

    final payload = action.payload ?? {};
    final buttonKey = action.buttonKeyPressed;

    // Empty buttonKey = notification body tapped (not an action button)
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

  // ── Public utility methods ───────────────────────────────────

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
// Channel builders — shared between foreground and background
// ─────────────────────────────────────────────────────────────

NotificationChannel _buildOrderChannel() => NotificationChannel(
  channelGroupKey: 'orders_group',
  channelKey: 'orders_channel',
  channelName: 'Order Updates',
  channelDescription: 'Updates about your food orders',
  defaultColor: const Color(0xFFFF6B35),
  ledColor: Colors.orange,
  importance: NotificationImportance.Max, // Max = always shows heads-up popup
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
  importance: NotificationImportance.High, // High = shows heads-up popup
  channelShowBadge: true,
  playSound: true,
  enableVibration: true,
  enableLights: true,
  defaultRingtoneType: DefaultRingtoneType.Notification,
);

// ─────────────────────────────────────────────────────────────
// Helpers shared between service and background handler
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
