import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/routes/routes.dart';
import '../../../core/util/app_color.dart';
import '../../../core/util/storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2400));

    final showedOnboarding = Store.showedOnBoarding == 'true';
    final hasToken = Store.userToken.isNotEmpty;
    final isRegistered = Store.status == 'registered';

    // ── Temporary debug — remove after fix ──────────────────
    log('🔍 showedOnboarding: $showedOnboarding');
    log('🔍 hasToken: $hasToken');
    log('🔍 Store.status raw value: "${Store.status}"');
    log('🔍 isRegistered: $isRegistered');
    // ────────────────────────────────────────────────────────

    if (!showedOnboarding && !hasToken) {
      Get.offAllNamed(Routes.onBoardingView);
    } else if (!hasToken) {
      Get.offAllNamed(Routes.login);
    } else if (isRegistered) {
      Get.offAllNamed(Routes.bottomNav);
    } else {
      Get.offAllNamed(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.appPrimary,
      body: Stack(
        children: [
          // ── Subtle radial glow at center ──────────────────────────────
          Center(
                child: Container(
                  width: size.width * 0.8,
                  height: size.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColor.white.withOpacity(0.07),
                        AppColor.transparent,
                      ],
                    ),
                  ),
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.3, 0.3),
                end: const Offset(1.2, 1.2),
                duration: 1800.ms,
                curve: Curves.easeOut,
              )
              .fade(begin: 0, end: 1, duration: 1200.ms),

          // ── Logo ───────────────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                      'assets/image/logo.png',
                      height: size.height * 0.07,
                      width: size.width * 0.55,
                      color: AppColor.white,
                      fit: BoxFit.contain,
                    )
                    .animate()
                    .fade(
                      begin: 0,
                      end: 1,
                      duration: 700.ms,
                      delay: 300.ms,
                      curve: Curves.easeOut,
                    )
                    .scale(
                      begin: const Offset(0.75, 0.75),
                      end: const Offset(1.0, 1.0),
                      duration: 700.ms,
                      delay: 300.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 12),

                // Tagline
                Text(
                      'Food. Moments. Memories.',
                      style: TextStyle(
                        color: AppColor.white.withOpacity(0.55),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    )
                    .animate()
                    .fade(begin: 0, end: 1, duration: 600.ms, delay: 800.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 600.ms,
                      delay: 800.ms,
                      curve: Curves.easeOut,
                    ),
              ],
            ),
          ),

          // ── Bottom loading indicator ───────────────────────────────────
          Positioned(
            bottom: size.height * 0.08,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColor.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fade(begin: 0, end: 1, duration: 500.ms, delay: 1200.ms),
        ],
      ),
    );
  }
}
