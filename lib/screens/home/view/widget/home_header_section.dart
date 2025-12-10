import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../controller/home_controller.dart';

class HomeHeaderSection extends StatelessWidget {
  final HomeController controller;

  const HomeHeaderSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      padding: EdgeInsets.only(
        top: responsive.topPadding + responsive.spacing20,
        left: responsive.spacing20,
        right: responsive.spacing20,
        bottom: responsive.spacing20,
      ),
      child: Row(
        children: [
          Expanded(child: _buildUserGreeting(responsive)),
          SizedBox(width: responsive.spacing10),
          _buildIconButton(searchSvg, controller.onSearchTapped, responsive),
          SizedBox(width: responsive.spacing10),
          _buildIconButton(bellSvg, controller.onNotificationTapped, responsive),
        ],
      ),
    );
  }

  /// Builds the user greeting section with location
  Widget _buildUserGreeting(ResponsiveHelper responsive) {
    return GetBuilder<HomeController>(
      id: HomeController.userGreetingId,
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                text(
                  text: 'Hello,',
                  size: responsive.fontSize26,
                  fontWeight: FontWeight.w600,
                  color: AppColor.appPrimary,
                ),
                SizedBox(width: responsive.spacing10),
                Flexible(
                  child: text(
                    text: '${controller.userName} 👋',
                    size: responsive.fontSize26,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.spacing5),
            Row(
              children: [
                text(
                  text: controller.userCity,
                  size: responsive.fontSize14,
                  fontWeight: FontWeight.w300,
                  color: AppColor.black,
                ),
                SizedBox(width: responsive.spacing10),
                GestureDetector(
                  onTap: controller.onLocationChangeTapped,
                  child: text(
                    text: 'Change',
                    size: responsive.fontSize10,
                    fontWeight: FontWeight.w600,
                    color: AppColor.appPrimary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Builds an icon button with svg
  Widget _buildIconButton(String svgString, VoidCallback onTap, ResponsiveHelper responsive) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(responsive.spacing11),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
          border: Border.all(color: AppColor.black.withOpacity(0.1), width: 1),
        ),
        child: Center(child: SvgPicture.string(svgString)),
      ),
    );
  }
}
