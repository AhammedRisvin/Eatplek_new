import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../../notification/cotroller/notification_controller.dart';
import '../../controller/home_controller.dart';

class HomeHeaderSection extends StatelessWidget {
  final HomeController controller;

  const HomeHeaderSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      padding: EdgeInsets.only(
        top: responsive.topPadding + responsive.spacing16,
        left: responsive.spacing20,
        right: responsive.spacing20,
        bottom: responsive.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor,
        border: Border(
          bottom: BorderSide(color: AppColor.black.withOpacity(0.04), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildUserGreeting(responsive)),
          SizedBox(width: responsive.spacing10),
          _buildIconButton(searchSvg, controller.onSearchTapped, responsive)
              .animate()
              .fade(duration: 400.ms, delay: 200.ms)
              .slideX(
                begin: 0.3,
                end: 0,
                duration: 400.ms,
                delay: 200.ms,
                curve: Curves.easeOut,
              ),
          SizedBox(width: responsive.spacing10),
          _buildBellButton(responsive)
              .animate()
              .fade(duration: 400.ms, delay: 300.ms)
              .slideX(
                begin: 0.3,
                end: 0,
                duration: 400.ms,
                delay: 300.ms,
                curve: Curves.easeOut,
              ),
        ],
      ),
    );
  }

  Widget _buildUserGreeting(ResponsiveHelper responsive) {
    return GetBuilder<HomeController>(
      init: controller,
      global: false,
      id: HomeController.userGreetingId,
      builder: (controller) {
        return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    text(
                      text: 'Hello,',
                      size: responsive.fontSize22,
                      fontWeight: FontWeight.w600,
                      color: AppColor.appPrimary,
                    ),
                    SizedBox(width: responsive.spacing6),
                    Flexible(
                      child: text(
                        text:
                            controller.userName.isNotEmpty
                                ? '${controller.userName} 👋'
                                : '👋',
                        size: responsive.fontSize22,
                        fontWeight: FontWeight.w600,
                        color: AppColor.black.withOpacity(0.75),
                        maxLines: 1,
                        overFlow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsive.spacing4),
                GestureDetector(
                  onTap: controller.onLocationChangeTapped,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: responsive.fontSize14,
                        color: AppColor.appPrimary.withOpacity(0.7),
                      ),
                      SizedBox(width: responsive.spacing4),
                      Flexible(
                        child: text(
                          text: controller.userCity,
                          size: responsive.fontSize13,
                          fontWeight: FontWeight.w400,
                          color: AppColor.black.withOpacity(0.55),
                          maxLines: 1,
                          overFlow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: responsive.spacing6),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.spacing8,
                          vertical: responsive.spacing3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.appPrimary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(
                            responsive.largeBorderRadius,
                          ),
                        ),
                        child: text(
                          text: 'Change',
                          size: responsive.fontSize10,
                          fontWeight: FontWeight.w600,
                          color: AppColor.appPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
            .animate()
            .fade(duration: 400.ms)
            .slideX(
              begin: -0.2,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOut,
            );
      },
    );
  }

  /// Bell button with unread badge overlay
  Widget _buildBellButton(ResponsiveHelper responsive) {
    return GetBuilder<NotificationController>(
      id: NotificationController.unreadBadgeId,
      builder: (notifController) {
        final int count = notifController.unreadCount;

        return GestureDetector(
          onTap: controller.onNotificationTapped,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(responsive.spacing10),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(
                    responsive.cardBorderRadius,
                  ),
                  border: Border.all(
                    color: AppColor.black.withOpacity(0.08),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SvgPicture.string(
                  bellSvg,
                  width: responsive.spacing20,
                  height: responsive.spacing20,
                ),
              ),

              // ── Unread badge ─────────────────────────────────────────────
              if (count > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: responsive.spacing16,
                      minHeight: responsive.spacing16,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: count > 9 ? responsive.spacing4 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: count > 9 ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius:
                          count > 9
                              ? BorderRadius.circular(
                                responsive.largeBorderRadius,
                              )
                              : null,
                      border: Border.all(
                        color: AppColor.scaffoldColor,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: text(
                        text: count > 99 ? '99+' : '$count',
                        size: responsive.fontSize9,
                        fontWeight: FontWeight.w700,
                        color: AppColor.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconButton(
    String svgString,
    VoidCallback onTap,
    ResponsiveHelper responsive,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(responsive.spacing10),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
          border: Border.all(color: AppColor.black.withOpacity(0.08), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SvgPicture.string(
          svgString,
          width: responsive.spacing20,
          height: responsive.spacing20,
        ),
      ),
    );
  }
}
