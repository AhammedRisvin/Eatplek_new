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

class OrderPreferenceDialog extends StatelessWidget {
  final String currentPreference;
  final Function(String) onPreferenceSelected;
  final String? title;
  final String? subtitle;

  const OrderPreferenceDialog({
    super.key,
    required this.currentPreference,
    required this.onPreferenceSelected,
    this.title,
    this.subtitle,
  });

  // Static method to show the dialog
  static void show({
    required String currentPreference,
    required Function(String) onPreferenceSelected,
    String? title,
    String? subtitle,
  }) {
    showDialog(
      context: Get.context!,
      barrierDismissible: true,
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: Get.width * 0.9,
        decoration: BoxDecoration(color: AppColor.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildHeader(), _buildDivider(), _buildPreferenceOptions(), 20.h],
        ),
      ),
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

  Widget _buildPreferenceOptions() {
    final preferences = _getPreferenceOptions();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          20.h,
          ...preferences.map(
            (preference) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OrderPreferenceOptionWidget(
                preference: preference,
                isSelected: currentPreference == preference.value,
                onTap: () {
                  onPreferenceSelected("${preference.emoji} ${preference.value}");
                  Get.back();
                },
              ),
            ),
          ),
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
  final VoidCallback onTap;

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
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.appPrimary.withOpacity(0.1) : AppColor.scaffoldColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColor.appPrimary.withOpacity(0.3) : AppColor.black.withOpacity(0.06),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            text(
              text: '${preference.emoji}   ${preference.title}',
              size: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColor.appPrimary : AppColor.black,
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: AppColor.appPrimary, size: 20),
          ],
        ),
      ),
    );
  }
}
