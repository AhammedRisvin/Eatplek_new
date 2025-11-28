import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                              const SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: BannerCarouselSection(controller: controller),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: OrderPreferenceSection(controller: controller),
                              ),
                              PrebookListSection(prebookList: controller.prebookList),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: VendorGridSection(controller: controller),
                              ),
                              if (controller.isLoadingMore) const LoadingMoreIndicator(),
                              const SizedBox(height: 100),
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
                  return LoadingOverlay(isVisible: controller.isLoadingServices, message: 'Loading services...');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class LoadingMoreIndicator extends StatelessWidget {
  const LoadingMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading more...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
