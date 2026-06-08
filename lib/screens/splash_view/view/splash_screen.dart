import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/routes/routes.dart';
import '../../../core/util/app_color.dart';
import '../../../core/util/storage.dart';

const _splashAnimationDuration = Duration(milliseconds: 5000);
const _splashSystemUiStyle = SystemUiOverlayStyle(
  statusBarColor: AppColor.transparent,
  statusBarIconBrightness: Brightness.light,
  systemNavigationBarColor: AppColor.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(_splashSystemUiStyle);
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(_splashAnimationDuration);

    if (!mounted) return;

    final showedOnboarding = Store.showedOnBoarding == 'true';
    final hasToken = Store.userToken.isNotEmpty;
    final isRegistered = Store.status == 'registered';

    log('showedOnboarding: $showedOnboarding');
    log('hasToken: $hasToken');
    log('Store.status raw value: "${Store.status}"');
    log('isRegistered: $isRegistered');

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
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColor.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColor.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: _splashSystemUiStyle,
      child: Scaffold(
        backgroundColor: AppColor.appPrimary,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: SizedBox.expand(
          child: Image(
            image: AssetImage('assets/image/loginSc.gif'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            gaplessPlayback: true,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
