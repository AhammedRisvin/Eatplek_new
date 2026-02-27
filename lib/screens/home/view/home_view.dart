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
      init: HomeController(),
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

                        return SingleChildScrollView(
                          controller: controller.scrollController,
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
                        );
                      },
                    ),
                  ),
                ],
              ),

              GetBuilder<HomeController>(
                id: HomeController.carouselId,
                builder: (controller) {
                  return LoadingOverlay(
                    isVisible: controller.isLoadingServices,
                    message: 'Loading services...',
                  );
                },
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
      child: Center(
        child: SizedBox(
          height: responsive.spacing40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: responsive.spacing16,
                height: responsive.spacing16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Get.theme.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: responsive.spacing12),
              Text(
                'Loading more...',
                style: Get.theme.textTheme.bodyMedium?.copyWith(
                  fontSize: responsive.fontSize14,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
