import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/on_boarding_model.dart';

class OnBoardingController extends GetxController with GetSingleTickerProviderStateMixin {
  int currentPage = 0;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  final List<OnBoardingData> onBoardingData = [
    OnBoardingData(
      image: 'assets/image/onBoarding1.png',
      title: 'Every Flavor. One Place.',
      subtitle: 'From fresh produce to baked treats, find everything you love in one app',
      percent: 0.4, // 40% for 2 to 5 o'clock
      reverse: true, // Anticlockwise
      hasButton: true,
    ),
    OnBoardingData(
      image: 'assets/image/onBoarding2.png',
      title: 'Choose How You Enjoy',
      subtitle: 'Table for two, doorstep delivery, or pick it up fresh.',
      percent: 1.0, // Full circle
      reverse: false, // Clockwise
      hasButton: true,
    ),
    OnBoardingData(
      image: 'assets/image/onBoarding2.png',
      title: 'Eat How You Like',
      subtitle: 'Delivery, dine-in, or takeaway — it’s all here.',
      percent: 0.0, // No progress indicator
      reverse: false,
      hasButton: false, // No button on third screen
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic));

    // Start initial animation
    animationController.forward();
  }

  void nextPage() {
    if (currentPage < onBoardingData.length - 1) {
      currentPage++;
      _updateAnimations();
      update(['page_content', 'page_indicators', 'progress_button']);
    } else {
      Get.offNamed('/login');
    }
  }

  void _updateAnimations() {
    animationController.reset();

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic));

    animationController.forward();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
