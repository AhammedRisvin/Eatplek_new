import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';

import '../../../core/routes/routes.dart';
import '../../../core/util/storage.dart';
import '../controller/on_boaring_contreoller.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    final responsive = ResponsiveHelper();

    return Scaffold(
      body: SizedBox(
        height: responsive.screenHeight,
        width: responsive.screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: responsive.spacing20),

            // Logo (Static)
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Image(
                image: const AssetImage('assets/image/logo.png'),
                height: responsive.spacing48,
                width: responsive.screenWidth * 0.344,
                color: AppColor.appPrimary,
              ),
            ),

            // Main Image (Animated)
            GetBuilder<OnBoardingController>(
              id: 'page_content',
              builder: (controller) {
                return AnimatedBuilder(
                  animation: controller.fadeAnimation,
                  builder: (context, child) {
                    return SlideTransition(
                      position: controller.slideAnimation,
                      child: FadeTransition(
                        opacity: controller.fadeAnimation,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: Image(
                            key: ValueKey(controller.currentPage),
                            image: AssetImage(controller.onBoardingData[controller.currentPage].image),
                            height: responsive.screenHeight * 0.35,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            SizedBox(height: responsive.spacing40),

            // Title and Subtitle (Animated)
            GetBuilder<OnBoardingController>(
              id: 'page_content',
              builder: (controller) {
                return AnimatedBuilder(
                  animation: controller.fadeAnimation,
                  builder: (context, child) {
                    return SlideTransition(
                      position: controller.slideAnimation,
                      child: FadeTransition(
                        opacity: controller.fadeAnimation,
                        child: Column(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: FadeTransition(opacity: animation, child: child),
                                );
                              },
                              child: Text(
                                controller.onBoardingData[controller.currentPage].title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: responsive.fontSize32,
                                  color: const Color(0XFF3E3E3E),
                                ),
                              ),
                            ),

                            SizedBox(height: responsive.spacing20),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: responsive.spacing16 * 3.6),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 600),
                                transitionBuilder: (child, animation) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.3),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: FadeTransition(opacity: animation, child: child),
                                  );
                                },
                                child: Text(
                                  controller.onBoardingData[controller.currentPage].subtitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: responsive.fontSize18,
                                    color: AppColor.black.withOpacity(0.6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Page Indicators (Animated)
            GetBuilder<OnBoardingController>(
              id: 'page_indicators',
              builder: (controller) {
                final currentData = controller.onBoardingData[controller.currentPage];
                return currentData.hasButton
                    ? AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          controller.onBoardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            margin: EdgeInsets.symmetric(horizontal: responsive.spacing10),
                            child: CircleAvatar(
                              radius: controller.currentPage == index ? responsive.spacing5 : responsive.spacing3,
                              backgroundColor:
                                  controller.currentPage == index
                                      ? AppColor.appPrimary
                                      : AppColor.black.withOpacity(0.1),
                            ),
                          ),
                        ),
                      ),
                    )
                    : const SizedBox.shrink();
              },
            ),

            // Progress Button (Using CircularPercentIndicator)
            GetBuilder<OnBoardingController>(
              id: 'progress_button',
              builder: (controller) {
                final currentData = controller.onBoardingData[controller.currentPage];

                return currentData.hasButton
                    ? CircularPercentIndicator(
                      radius: responsive.spacing35,
                      reverse: currentData.reverse,
                      lineWidth: responsive.spacing3,
                      percent: currentData.percent,
                      center: GestureDetector(
                        onTap: () {
                          controller.nextPage();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: CircleAvatar(
                            radius: responsive.spacing32,
                            backgroundColor: AppColor.white,
                            child: CircleAvatar(
                              radius: responsive.spacing30,
                              backgroundColor: AppColor.appPrimary,
                              child: const Icon(Icons.arrow_forward_ios, color: AppColor.white),
                            ),
                          ),
                        ),
                      ),
                      backgroundColor: Colors.transparent,
                      progressColor: AppColor.appPrimary,
                    )
                    : button(
                      name: 'Get Started',
                      fontWeight: FontWeight.w700,
                      fontSize: responsive.fontSize16,
                      height: responsive.buttonHeight,
                      onTap: () {
                        Store.showedOnBoarding = 'true';
                        Get.offAllNamed(Routes.login);
                      },
                      width: responsive.screenWidth * 0.8,
                      borderRadius: BorderRadius.circular(responsive.spacing40),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
