import 'package:eatplek_app/core/util/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/responsive_helper.dart';
import '../controller/home_controller.dart';
import 'widget/banner_carousal_section.dart';
import 'widget/error_screen_section.dart';
import 'widget/home_header_section.dart';
import 'widget/loading_overlay_widget.dart';
import 'widget/order_preference_section.dart';
import 'widget/pre_book_section.dart';
import 'widget/restaurent_grid_section.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          body: Stack(
            children: [
              Column(
                children: [
                  HomeHeaderSection(controller: controller),
                  Expanded(
                    child: GetBuilder<HomeController>(
                      id: HomeController.vendorsId,
                      builder: (controller) {
                        if (controller.hasError && controller.vendors.isEmpty) {
                          return ErrorScreenSection(controller: controller);
                        }

                        return RefreshIndicator(
                          onRefresh: controller.refreshVendors,
                          color: AppColor.appPrimary,
                          backgroundColor: AppColor.white,
                          strokeWidth: 2.5,
                          child: SingleChildScrollView(
                            controller: controller.scrollController,
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: responsive.spacing20,
                                  ),
                                  child: BannerCarouselSection(
                                    controller: controller,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: responsive.spacing20,
                                  ),
                                  child: OrderPreferenceSection(
                                    controller: controller,
                                  ),
                                ),
                                PrebookListSection(
                                  prebookList: controller.prebookList,
                                ),
                                VendorGridSection(controller: controller),
                                if (controller.isLoadingMore)
                                  _buildLoadingMoreIndicator(responsive),
                                SizedBox(height: responsive.spacing100),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Loading overlay while switching service types
              GetBuilder<HomeController>(
                id: HomeController.carouselId,
                builder:
                    (controller) => LoadingOverlay(
                      isVisible: controller.isLoadingServices,
                      message: 'Finding restaurants near you...',
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingMoreIndicator(ResponsiveHelper responsive) {
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
          Text(
            'Loading more...',
            style: TextStyle(
              fontSize: responsive.fontSize13,
              color: AppColor.black.withOpacity(0.4),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
