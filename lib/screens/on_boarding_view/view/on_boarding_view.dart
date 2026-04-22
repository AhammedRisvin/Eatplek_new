import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: responsive.spacing20),

            // ── Logo ────────────────────────────────────────────────────────
            Image.asset(
                  'assets/image/logo.png',
                  height: responsive.spacing48,
                  width: responsive.screenWidth * 0.35,
                  color: AppColor.appPrimary,
                  fit: BoxFit.contain,
                )
                .animate()
                .fade(duration: 500.ms)
                .slideY(begin: -0.2, end: 0, duration: 500.ms),

            const Spacer(),

            // ── Main illustration ────────────────────────────────────────────
            GetBuilder<OnBoardingController>(
              id: 'page_content',
              builder:
                  (ctrl) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    transitionBuilder:
                        (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                    child: Image.asset(
                      ctrl.onBoardingData[ctrl.currentPage].image,
                      key: ValueKey(ctrl.currentPage),
                      height: responsive.screenHeight * 0.34,
                      fit: BoxFit.contain,
                    ),
                  ),
            ),

            SizedBox(height: responsive.spacing32),

            // ── Title & subtitle ─────────────────────────────────────────────
            GetBuilder<OnBoardingController>(
              id: 'page_content',
              builder:
                  (ctrl) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder:
                        (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.08),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                    child: Padding(
                      key: ValueKey('text_${ctrl.currentPage}'),
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.spacing20,
                      ),
                      child: Column(
                        children: [
                          Text(
                            ctrl.onBoardingData[ctrl.currentPage].title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: responsive.fontSize28,
                              color: AppColor.black,
                            ),
                          ),
                          SizedBox(height: responsive.spacing16),
                          Text(
                            ctrl.onBoardingData[ctrl.currentPage].subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: responsive.fontSize15,
                              color: AppColor.black.withOpacity(0.55),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),

            SizedBox(height: responsive.spacing32),

            // ── Page dots ────────────────────────────────────────────────────
            GetBuilder<OnBoardingController>(
              id: 'page_indicators',
              builder: (ctrl) {
                final data = ctrl.onBoardingData[ctrl.currentPage];
                if (!data.hasButton) return const SizedBox.shrink();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    ctrl.onBoardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      margin: EdgeInsets.symmetric(
                        horizontal: responsive.spacing4,
                      ),
                      width:
                          ctrl.currentPage == index
                              ? responsive.spacing20
                              : responsive.spacing6,
                      height: responsive.spacing6,
                      decoration: BoxDecoration(
                        color:
                            ctrl.currentPage == index
                                ? AppColor.appPrimary
                                : AppColor.appPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: responsive.spacing32),

            // ── Progress button / Get Started ────────────────────────────────
            GetBuilder<OnBoardingController>(
              id: 'progress_button',
              builder: (ctrl) {
                final data = ctrl.onBoardingData[ctrl.currentPage];

                if (data.hasButton) {
                  return CircularPercentIndicator(
                    radius: responsive.spacing35,
                    reverse: data.reverse,
                    lineWidth: responsive.spacing3,
                    percent: data.percent,
                    backgroundColor: AppColor.appPrimary.withOpacity(0.12),
                    progressColor: AppColor.appPrimary,
                    center: GestureDetector(
                      onTap: ctrl.nextPage,
                      child: Container(
                        width: responsive.spacing60,
                        height: responsive.spacing60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.appPrimary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.appPrimary.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColor.white,
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing20,
                  ),
                  child: button(
                    name: 'Get Started',
                    fontWeight: FontWeight.w700,
                    fontSize: responsive.fontSize16,
                    height: responsive.buttonHeight,
                    onTap: () {
                      Store.showedOnBoarding = 'true';
                      Get.offAllNamed(Routes.login);
                    },
                    borderRadius: BorderRadius.circular(responsive.spacing40),
                  ),
                );
              },
            ),

            SizedBox(height: responsive.spacing32),
          ],
        ),
      ),
    );
  }
}
