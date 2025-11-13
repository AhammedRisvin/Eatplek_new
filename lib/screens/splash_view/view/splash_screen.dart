import 'dart:developer';

import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/routes.dart';
import '../../../core/util/app_color.dart';
import '../../../core/util/storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLoginScreen();
  }

  void _navigateToLoginScreen() {
    Future.delayed(const Duration(seconds: 2), () {
      final showedOnboarding = Store.showedOnBoarding == 'true';
      log('showedOnboarding $showedOnboarding');
      final hasToken = Store.userToken.isNotEmpty;
      final isRegistered = Store.status == 'registered';

      // 1. First time user (no onboarding shown & no token)
      if (!showedOnboarding && !hasToken) {
        return Get.offAllNamed(Routes.onBoardingView);
      }

      // 2. Onboarding already shown but user not logged in
      if (!hasToken) {
        return Get.offAllNamed(Routes.login);
      }

      // 3. Token exists & user fully registered → go home
      if (isRegistered) {
        return Get.offAllNamed(Routes.bottomNav);
      }

      // 4. Token exists but not fully registered
      return Get.offAllNamed(Routes.login);
    });
  }

  //Store.showOnBoarding

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appPrimary,
      body: Center(
        child: Image(image: AssetImage('assets/image/logo.png'), height: context.hp(6), width: context.hp(60)),
      ),
    );
  }
}
