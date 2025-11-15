// order_preference_dialog.dart
import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderPreferenceModel {
  final String id;
  final String title;
  final String emoji;
  final String value;

  OrderPreferenceModel({required this.id, required this.title, required this.emoji, required this.value});
}

// 🆕 GetX Controller for dialog state
class OrderPreferenceDialogController extends GetxController {
  late String currentPreference;
  final RxString selectedPreference = ''.obs;
  final RxBool isLoading = false.obs;

  OrderPreferenceDialogController({required String initial}) {
    currentPreference = initial;
    selectedPreference.value = initial;
  }

  void selectPreference(String value) {
    selectedPreference.value = value;
    debugPrint('🎯 Selected: $value');
  }

  bool isSelected(String value) {
    return selectedPreference.value.contains(value);
  }
}

class OrderPreferenceDialog extends StatelessWidget {
  final String currentPreference;
  final Function(String) onPreferenceSelected;
  final String? title;
  final String? subtitle;
  final bool isDismissible;

  late final OrderPreferenceDialogController _controller;

  OrderPreferenceDialog({
    super.key,
    required this.currentPreference,
    required this.onPreferenceSelected,
    this.title,
    this.subtitle,
    this.isDismissible = true,
  }) {
    _controller = OrderPreferenceDialogController(initial: currentPreference);
  }

  // Static method to show the dialog
  static void show({
    required String currentPreference,
    required Function(String) onPreferenceSelected,
    String? title,
    String? subtitle,
  }) {
    showDialog(
      context: Get.context!,
      barrierColor: Colors.black.withOpacity(0.5), // 🆕 Better visibility
      builder:
          (context) => OrderPreferenceDialog(
            currentPreference: currentPreference,
            onPreferenceSelected: onPreferenceSelected,
            title: title,
            subtitle: subtitle,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderPreferenceDialogController>(
      init: _controller,
      builder: (controller) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetAnimationDuration: const Duration(milliseconds: 300),
          child: Container(
            width: Get.width * 0.9,
            decoration: BoxDecoration(color: AppColor.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_buildHeader(), _buildDivider(), _buildPreferenceOptions(controller), 20.h],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          text(
            text: title ?? 'How Would You Like to Order?',
            size: 20,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          4.h,
          text(
            text: subtitle ?? 'Please choose your preferred service to continue.',
            size: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColor.black.withOpacity(0.1), height: 1);
  }

  Widget _buildPreferenceOptions(OrderPreferenceDialogController controller) {
    final preferences = _getPreferenceOptions();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          20.h,
          ...preferences.map((preference) {
            return Obx(
              () => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OrderPreferenceOptionWidget(
                  preference: preference,
                  isSelected: controller.isSelected(preference.value),
                  onTap: () {
                    // 1️⃣ Update selection visually
                    controller.selectPreference(preference.value);

                    // 2️⃣ Call callback immediately
                    String fullPreference = "${preference.emoji}  ${preference.value}";
                    onPreferenceSelected(fullPreference);
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<OrderPreferenceModel> _getPreferenceOptions() {
    return [
      OrderPreferenceModel(id: 'delivery', title: 'Delivery', emoji: '🛵', value: 'Delivery'),
      OrderPreferenceModel(id: 'takeaway', title: 'Take Away', emoji: '🥡', value: 'Take Away'),
      OrderPreferenceModel(id: 'dining', title: 'Dining', emoji: '🍽️', value: 'Dine-in'),
      OrderPreferenceModel(id: 'special', title: 'Special Day Pre-Booking', emoji: '🎉', value: 'Special Booking'),
    ];
  }
}

// order_preference_option_widget.dart
class OrderPreferenceOptionWidget extends StatelessWidget {
  final OrderPreferenceModel preference;
  final bool isSelected;
  final VoidCallback? onTap;

  const OrderPreferenceOptionWidget({
    super.key,
    required this.preference,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // 🆕 Longer animation
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.appPrimary.withOpacity(0.15) : AppColor.scaffoldColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColor.appPrimary.withOpacity(0.5) : AppColor.black.withOpacity(0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [BoxShadow(color: AppColor.appPrimary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]
                  : [],
        ),
        child: Row(
          children: [
            // 🆕 Animated emoji
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: text(
                text: '${preference.emoji}   ${preference.title}',
                size: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColor.appPrimary : AppColor.black,
              ),
            ),
            const Spacer(),
            // 🆕 Animated checkmark
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Icon(Icons.check_circle, color: AppColor.appPrimary, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
