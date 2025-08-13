import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';

import '../../../core/routes/routes.dart';
import '../controller/on_boaring_contreoller.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: SizedBox(
        height: context.hp(100),
        width: context.wp(100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            20.h,

            // Logo (Static)
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Image(
                image: AssetImage('assets/image/logo.png'),
                height: 43,
                width: context.wp(34.4),
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
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            40.h,

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
                              child: text(
                                text: controller.onBoardingData[controller.currentPage].title,
                                fontWeight: FontWeight.w900,
                                size: 30,
                                color: Color(0XFF3E3E3E),
                              ),
                            ),

                            20.h,

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 58.0),
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
                                child: text(
                                  text: controller.onBoardingData[controller.currentPage].subtitle,
                                  fontWeight: FontWeight.w400,
                                  size: 18,
                                  color: AppColor.black.withOpacity(0.6),
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
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: CircleAvatar(
                              radius: controller.currentPage == index ? 5 : 3,
                              backgroundColor:
                                  controller.currentPage == index
                                      ? AppColor.appPrimary
                                      : AppColor.black.withOpacity(0.1),
                            ),
                          ),
                        ),
                      ),
                    )
                    : SizedBox.shrink();
              },
            ),

            // Progress Button (Using CircularPercentIndicator)
            GetBuilder<OnBoardingController>(
              id: 'progress_button',
              builder: (controller) {
                final currentData = controller.onBoardingData[controller.currentPage];

                return currentData.hasButton
                    ? CircularPercentIndicator(
                      radius: 35.0,
                      reverse: currentData.reverse,
                      lineWidth: 3.0,
                      percent: currentData.percent,
                      center: GestureDetector(
                        onTap: () {
                          controller.nextPage();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColor.white,
                            child: CircleAvatar(
                              radius: 30,
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
                      fontSize: 16,
                      height: 60,
                      onTap: () {
                        Get.offAllNamed(Routes.login);
                      },
                      width: context.wp(80),
                      borderRadius: BorderRadius.circular(50),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
