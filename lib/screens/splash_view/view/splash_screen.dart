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
      if (Store.userToken.isNotEmpty) {
        return Get.offAllNamed(Routes.bottomNav);
      } else {
        return Get.offAllNamed(Routes.onBoardingView);
      }
    });
  }

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
