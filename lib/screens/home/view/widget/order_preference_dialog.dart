import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/screens/home/model/new_home_model.dart';
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

class OrderPreferenceDialog extends StatefulWidget {
  final String currentPreference;
  final List<String> availableServices;
  final Function(String) onPreferenceSelected;
  final VoidCallback? onDialogDismissed;
  final String? title;
  final String? subtitle;

  const OrderPreferenceDialog({
    super.key,
    required this.currentPreference,
    required this.availableServices,
    required this.onPreferenceSelected,
    this.onDialogDismissed,
    this.title,
    this.subtitle,
  });

  /// Static method to show the dialog
  static Future<void> show({
    required String currentPreference,
    required List<String> availableServices,
    required List<BannerData> banners,
    required Function(String) onPreferenceSelected,
    VoidCallback? onDialogDismissed,
    String? title,
    String? subtitle,
  }) async {
    debugPrint('🎯 OrderPreferenceDialog.show() called');

    showDialog(
      context: Get.context!,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: false, // ✅ Force user to select or explicitly close
      builder:
          (context) => OrderPreferenceDialog(
            currentPreference: currentPreference,
            availableServices: availableServices,
            onPreferenceSelected: onPreferenceSelected,
            onDialogDismissed: onDialogDismissed,
            title: title,
            subtitle: subtitle,
          ),
    );
  }

  @override
  State<OrderPreferenceDialog> createState() => _OrderPreferenceDialogState();
}

class _OrderPreferenceDialogState extends State<OrderPreferenceDialog> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // ✅ Prevent back button from closing dialog
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetAnimationDuration: const Duration(milliseconds: 300),
        child: Container(
          width: Get.width * 0.9,
          decoration: BoxDecoration(color: AppColor.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [_buildHeader(), _buildDivider(), _buildPreferenceOptions(), _buildCloseButton(), 20.h],
          ),
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
            text: widget.title ?? 'How Would You Like to Order?',
            size: 20,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          4.h,
          text(
            text: widget.subtitle ?? 'Please choose your preferred service to continue.',
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

    // Filter preferences based on available services
    final filteredPreferences =
        preferences
            .where(
              (pref) => widget.availableServices.any(
                (service) => service.toLowerCase() == pref.value.toLowerCase().replaceAll('-', '').replaceAll(' ', ''),
              ),
            )
            .toList();

    debugPrint('📋 Filtered preferences: ${filteredPreferences.map((p) => p.value).toList()}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          20.h,
          ...filteredPreferences.map((preference) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OrderPreferenceOptionWidget(
                preference: preference,
                isSelected: widget.currentPreference.contains(preference.value),
                onTap: () {
                  debugPrint('✅ Preference tapped: ${preference.value}');

                  // Create full preference string with emoji
                  String fullPreference = "${preference.emoji}  ${preference.value}";

                  debugPrint('📤 Closing dialog and calling callback with: $fullPreference');

                  // 1️⃣ Close dialog first
                  Navigator.of(Get.context!).pop();

                  // 2️⃣ Call callback after dialog closes
                  Future.delayed(const Duration(milliseconds: 200), () {
                    debugPrint('📞 Calling onPreferenceSelected callback');
                    widget.onPreferenceSelected(fullPreference);
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: button(
        name: 'Cancel',
        width: double.infinity,
        height: 45,
        borderRadius: BorderRadius.circular(12),
        fontSize: 14,
        fontWeight: FontWeight.w600,
        onTap: () {
          debugPrint('❌ Dialog closed without selection');
          Navigator.of(Get.context!).pop();

          Future.delayed(const Duration(milliseconds: 200), () {
            widget.onDialogDismissed?.call();
          });
        },
        color: AppColor.scaffoldColor,
        borderColor: AppColor.black.withOpacity(0.1),
        textColor: AppColor.black,
      ),
    );
  }

  List<OrderPreferenceModel> _getPreferenceOptions() {
    return [
      OrderPreferenceModel(id: 'delivery', title: 'Delivery', emoji: '🛵', value: 'Delivery'),
      OrderPreferenceModel(id: 'takeaway', title: 'Take Away', emoji: '🥡', value: 'Takeaway'),
      OrderPreferenceModel(id: 'dining', title: 'Dine-in', emoji: '🍽️', value: 'Dine-in'),
      OrderPreferenceModel(id: 'special', title: 'Special Booking', emoji: '🎉', value: 'SpecialBooking'),
    ];
  }
}

/// Individual preference option widget
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
        duration: const Duration(milliseconds: 300),
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
            // Animated emoji and title
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
            // Animated checkmark
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
