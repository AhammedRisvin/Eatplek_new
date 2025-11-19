import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../controller/home_controller.dart';

class HomeHeaderSection extends StatelessWidget {
  final HomeController controller;

  const HomeHeaderSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: Get.mediaQuery.padding.top + 20, left: 20, right: 20, bottom: 20),
      child: Row(
        children: [
          Expanded(child: _buildUserGreeting()),
          10.w,
          _buildIconButton(searchSvg, controller.onSearchTapped),
          10.w,
          _buildIconButton(bellSvg, controller.onNotificationTapped),
        ],
      ),
    );
  }

  /// Builds the user greeting section with location
  Widget _buildUserGreeting() {
    return GetBuilder<HomeController>(
      id: HomeController.userGreetingId,
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                text(text: 'Hello,', size: 26, fontWeight: FontWeight.w600, color: AppColor.appPrimary),
                10.w,
                Flexible(
                  child: text(
                    text: '${controller.userName} 👋',
                    size: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            5.h,
            // Location with change option
            Row(
              children: [
                text(text: controller.userCity, size: 14, fontWeight: FontWeight.w300, color: AppColor.black),
                10.w,
                GestureDetector(
                  onTap: controller.onLocationChangeTapped,
                  child: text(text: 'Change', size: 10, fontWeight: FontWeight.w600, color: AppColor.appPrimary),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Builds an icon button with svg
  Widget _buildIconButton(String svgString, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.black.withOpacity(0.1), width: 1),
        ),
        child: Center(child: SvgPicture.string(svgString)),
      ),
    );
  }
}
