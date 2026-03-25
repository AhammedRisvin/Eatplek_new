import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../cotroller/notification_controller.dart';
import '../model/notification_model.dart' as model;

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();
    final responsive = ResponsiveHelper();

    return Scaffold(
      backgroundColor: AppColor.scaffoldColor,
      appBar: _buildAppBar(responsive),
      body: GetBuilder<NotificationController>(
        id: NotificationController.listId,
        builder: (controller) {
          // ── Skeleton loading (initial fetch) ─────────────────────────────
          if (controller.isLoading) {
            return _NotificationSkeletonList(responsive: responsive);
          }

          // ── Error state ───────────────────────────────────────────────────
          if (controller.hasError && controller.notifications.isEmpty) {
            return _NotificationErrorScreen(
              message: controller.errorMessage,
              onRetry: () => controller.fetchNotifications(isRefresh: true),
              responsive: responsive,
            );
          }

          // ── Empty state ───────────────────────────────────────────────────
          if (!controller.isLoading && controller.notifications.isEmpty) {
            return _NotificationEmptyScreen(responsive: responsive);
          }

          // ── Main list ─────────────────────────────────────────────────────
          return RefreshIndicator(
            onRefresh: () => controller.fetchNotifications(isRefresh: true),
            color: AppColor.appPrimary,
            backgroundColor: AppColor.white,
            strokeWidth: 2.5,
            child: ListView.builder(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.only(
                top: responsive.spacing12,
                bottom: responsive.spacing100,
              ),
              itemCount:
                  controller.notifications.length +
                  (controller.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // ── Bottom pagination loader ───────────────────────────────
                if (index == controller.notifications.length) {
                  return _buildPaginationLoader(responsive);
                }

                final notification = controller.notifications[index];
                return _NotificationTile(
                  notification: notification,
                  responsive: responsive,
                );
              },
            ),
          );
        },
      ),

      // ── Mark all as read FAB ──────────────────────────────────────────────
      floatingActionButton: GetBuilder<NotificationController>(
        id: NotificationController.fabId,
        builder: (controller) {
          final hasUnread = controller.unreadCount > 0;
          final isLoading = controller.isLoading;

          if (isLoading || controller.notifications.isEmpty) {
            return const SizedBox.shrink();
          }

          return AnimatedSlide(
            offset: hasUnread ? Offset.zero : const Offset(0, 2),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: hasUnread ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton.extended(
                onPressed:
                    controller.isMarkingAllRead
                        ? null
                        : controller.markAllAsRead,
                backgroundColor: AppColor.appPrimary,
                elevation: 4,
                icon:
                    controller.isMarkingAllRead
                        ? SizedBox(
                          width: responsive.spacing16,
                          height: responsive.spacing16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColor.white,
                            ),
                          ),
                        )
                        : Icon(
                          Icons.done_all_rounded,
                          color: AppColor.white,
                          size: responsive.fontSize18,
                        ),
                label: text(
                  text:
                      controller.isMarkingAllRead
                          ? 'Marking...'
                          : 'Mark all as read',
                  size: responsive.fontSize13,
                  fontWeight: FontWeight.w600,
                  color: AppColor.white,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(ResponsiveHelper responsive) {
    return AppBar(
      backgroundColor: AppColor.scaffoldColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: EdgeInsets.all(responsive.spacing10),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
            border: Border.all(
              color: AppColor.black.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: responsive.fontSize16,
            color: AppColor.black.withOpacity(0.7),
          ),
        ),
      ),
      title: GetBuilder<NotificationController>(
        id: NotificationController.unreadBadgeId,
        builder: (controller) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              text(
                text: 'Notifications',
                size: responsive.fontSize18,
                fontWeight: FontWeight.w700,
                color: AppColor.black,
              ),
              if (controller.unreadCount > 0) ...[
                SizedBox(width: responsive.spacing8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing8,
                    vertical: responsive.spacing3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.appPrimary,
                    borderRadius: BorderRadius.circular(
                      responsive.largeBorderRadius,
                    ),
                  ),
                  child: text(
                    text: '${controller.unreadCount}',
                    size: responsive.fontSize11,
                    fontWeight: FontWeight.w700,
                    color: AppColor.white,
                  ),
                ),
              ],
            ],
          );
        },
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColor.black.withOpacity(0.06)),
      ),
    );
  }

  Widget _buildPaginationLoader(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive.spacing20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: responsive.spacing16,
            height: responsive.spacing16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColor.appPrimary.withOpacity(0.5),
              ),
            ),
          ),
          SizedBox(width: responsive.spacing10),
          text(
            text: 'Loading more...',
            size: responsive.fontSize13,
            color: AppColor.black.withOpacity(0.4),
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}

// ─── Notification Tile ────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final model.Notification notification;
  final ResponsiveHelper responsive;

  const _NotificationTile({
    required this.notification,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = notification.isRead == false;
    final double radius = responsive.cardBorderRadius;

    // Flutter does not allow borderRadius + non-uniform Border colors on the
    // same BoxDecoration. Solution: Stack a separate left-accent bar behind
    // the main rounded card — no constraint violation, same visual result.
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing16,
        vertical: responsive.spacing5,
      ),
      child: Stack(
        children: [
          // ── Unread left accent bar ───────────────────────────────────────
          if (isUnread)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: AppColor.appPrimary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(radius),
                    bottomLeft: Radius.circular(radius),
                  ),
                ),
              ),
            ),

          // ── Main card (uniform border — no crash) ────────────────────────
          Container(
            decoration: BoxDecoration(
              color:
                  isUnread
                      ? AppColor.appPrimary.withOpacity(0.04)
                      : AppColor.white,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: AppColor.black.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withOpacity(isUnread ? 0.05 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              // Extra left padding on unread tiles so content clears the bar
              padding: EdgeInsets.only(
                left:
                    isUnread ? responsive.spacing14 + 3 : responsive.spacing14,
                top: responsive.spacing14,
                right: responsive.spacing14,
                bottom: responsive.spacing14,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Icon / image ─────────────────────────────────────────
                  _buildLeadingIcon(isUnread),
                  SizedBox(width: responsive.spacing12),

                  // ── Content ──────────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: text(
                                text: notification.title ?? 'Notification',
                                size: responsive.fontSize14,
                                fontWeight:
                                    isUnread
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                color: AppColor.black.withOpacity(
                                  isUnread ? 0.9 : 0.75,
                                ),
                                maxLines: 1,
                                overFlow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isUnread) ...[
                              SizedBox(width: responsive.spacing6),
                              Container(
                                width: responsive.spacing8,
                                height: responsive.spacing8,
                                decoration: BoxDecoration(
                                  color: AppColor.appPrimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (notification.body != null &&
                            notification.body!.isNotEmpty) ...[
                          SizedBox(height: responsive.spacing4),
                          text(
                            text: notification.body!,
                            size: responsive.fontSize13,
                            fontWeight: FontWeight.w400,
                            color: AppColor.black.withOpacity(0.5),
                            maxLines: 2,
                            overFlow: TextOverflow.ellipsis,
                          ),
                        ],
                        SizedBox(height: responsive.spacing8),
                        _buildTimestamp(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(bool isUnread) {
    if (notification.imageUrl != null && notification.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
        child: Image.network(
          notification.imageUrl!,
          width: responsive.spacing40,
          height: responsive.spacing40,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _defaultIcon(isUnread),
        ),
      );
    }
    return _defaultIcon(isUnread);
  }

  Widget _defaultIcon(bool isUnread) {
    return Container(
      width: responsive.spacing40,
      height: responsive.spacing40,
      decoration: BoxDecoration(
        color:
            isUnread
                ? AppColor.appPrimary.withOpacity(0.12)
                : AppColor.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
      ),
      child: Icon(
        _iconForType(notification.data?.type),
        size: responsive.fontSize20,
        color: isUnread ? AppColor.appPrimary : AppColor.black.withOpacity(0.4),
      ),
    );
  }

  IconData _iconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'order':
        return Icons.receipt_long_rounded;
      case 'promo':
      case 'discount':
        return Icons.local_offer_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'invite':
        return Icons.group_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Widget _buildTimestamp() {
    if (notification.createdAt == null) return const SizedBox.shrink();

    final String timeText = _formatTime(notification.createdAt!);
    return Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          size: responsive.fontSize11,
          color: AppColor.black.withOpacity(0.35),
        ),
        SizedBox(width: responsive.spacing3),
        text(
          text: timeText,
          size: responsive.fontSize11,
          fontWeight: FontWeight.w400,
          color: AppColor.black.withOpacity(0.35),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

// ─── Skeleton Loading ─────────────────────────────────────────────────────────

class _NotificationSkeletonList extends StatelessWidget {
  final ResponsiveHelper responsive;

  const _NotificationSkeletonList({required this.responsive});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: AppColor.black.withOpacity(0.06),
        highlightColor: AppColor.black.withOpacity(0.12),
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: responsive.spacing12,
          bottom: responsive.spacing20,
        ),
        itemCount: 8,
        itemBuilder: (_, _) => _SkeletonTile(responsive: responsive),
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  final ResponsiveHelper responsive;

  const _SkeletonTile({required this.responsive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsive.spacing16,
        vertical: responsive.spacing5,
      ),
      padding: EdgeInsets.all(responsive.spacing14),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon placeholder
          Container(
            width: responsive.spacing40,
            height: responsive.spacing40,
            decoration: BoxDecoration(
              color: AppColor.black.withOpacity(0.08),
              borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
            ),
          ),
          SizedBox(width: responsive.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Container(
                  height: responsive.spacing14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.black.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: responsive.spacing6),
                // Body line 1
                Container(
                  height: responsive.spacing12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: responsive.spacing4),
                // Body line 2 (shorter)
                Container(
                  height: responsive.spacing12,
                  width: 140,
                  decoration: BoxDecoration(
                    color: AppColor.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: responsive.spacing8),
                // Timestamp
                Container(
                  height: responsive.spacing10,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColor.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _NotificationEmptyScreen extends StatelessWidget {
  final ResponsiveHelper responsive;

  const _NotificationEmptyScreen({required this.responsive});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColor.appPrimary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 40,
                color: AppColor.appPrimary.withOpacity(0.5),
              ),
            ),
            SizedBox(height: responsive.spacing20),
            text(
              text: 'No Notifications Yet',
              size: responsive.fontSize18,
              fontWeight: FontWeight.w700,
              color: AppColor.black.withOpacity(0.8),
            ),
            SizedBox(height: responsive.spacing8),
            text(
              text:
                  "You're all caught up! We'll let you know\nwhen something new arrives.",
              size: responsive.fontSize14,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.45),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────

class _NotificationErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final ResponsiveHelper responsive;

  const _NotificationErrorScreen({
    required this.message,
    required this.onRetry,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: Colors.redAccent.withOpacity(0.6),
              ),
            ),
            SizedBox(height: responsive.spacing20),
            text(
              text: 'Something Went Wrong',
              size: responsive.fontSize18,
              fontWeight: FontWeight.w700,
              color: AppColor.black.withOpacity(0.8),
            ),
            SizedBox(height: responsive.spacing8),
            text(
              text: message,
              size: responsive.fontSize14,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.45),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            SizedBox(height: responsive.spacing24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.appPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing24,
                  vertical: responsive.spacing12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    responsive.cardBorderRadius,
                  ),
                ),
                elevation: 0,
              ),
              icon: Icon(
                Icons.refresh_rounded,
                color: AppColor.white,
                size: responsive.fontSize16,
              ),
              label: text(
                text: 'Try Again',
                size: responsive.fontSize14,
                fontWeight: FontWeight.w600,
                color: AppColor.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
