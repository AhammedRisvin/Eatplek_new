import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/screens/home/model/new_home_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/responsive_helper.dart' show ResponsiveHelper;

class OrderPreferenceModel {
  final String id;
  final String title;
  final String emoji;
  final String value;

  OrderPreferenceModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.value,
  });
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
      barrierDismissible: false,
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
    final responsive = ResponsiveHelper();

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetAnimationDuration: const Duration(milliseconds: 300),
        child: Container(
          width: responsive.widthPercent(90),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(responsive),
              _buildDivider(),
              _buildPreferenceOptions(responsive),
              _buildCloseButton(responsive),
              SizedBox(height: responsive.spacing20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.all(responsive.spacing20),
      child: Column(
        children: [
          text(
            text: widget.title ?? 'How Would You Like to Order?',
            size: responsive.fontSize20,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing4),
          text(
            text:
                widget.subtitle ??
                'Please choose your preferred service to continue.',
            size: responsive.fontSize14,
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

  Widget _buildPreferenceOptions(ResponsiveHelper responsive) {
    final preferences = _getPreferenceOptions();

    final filteredPreferences =
        preferences
            .where(
              (pref) => widget.availableServices.any(
                (service) =>
                    service
                        .toLowerCase()
                        .replaceAll('-', '')
                        .replaceAll(' ', '') ==
                    pref.value
                        .toLowerCase()
                        .replaceAll('-', '')
                        .replaceAll(' ', ''),
              ),
            )
            .toList();

    debugPrint(
      '📋 Filtered preferences: ${filteredPreferences.map((p) => p.value).toList()}',
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing20),
      child: Column(
        children: [
          SizedBox(height: responsive.spacing20),
          ...filteredPreferences.map((preference) {
            return Padding(
              padding: EdgeInsets.only(bottom: responsive.spacing10),
              child: OrderPreferenceOptionWidget(
                preference: preference,
                isSelected: widget.currentPreference.contains(preference.value),
                onTap: () {
                  debugPrint('✅ Preference tapped: ${preference.value}');
                  String fullPreference =
                      "${preference.emoji}  ${preference.value}";
                  debugPrint(
                    '📤 Closing dialog and calling callback with: $fullPreference',
                  );
                  Navigator.of(Get.context!).pop();
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

  Widget _buildCloseButton(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing20),
      child: button(
        name: 'Cancel',
        width: double.infinity,
        height: responsive.buttonHeight,
        borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
        fontSize: responsive.fontSize14,
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
      OrderPreferenceModel(
        id: 'delivery',
        title: 'Delivery',
        emoji: '🛵',
        value: 'Delivery',
      ),
      OrderPreferenceModel(
        id: 'takeaway',
        title: 'Take Away',
        emoji: '🥡',
        value: 'Takeaway',
      ),
      OrderPreferenceModel(
        id: 'dining',
        title: 'Dine-in',
        emoji: '🍽️',
        value: 'Dine-in',
      ),
      OrderPreferenceModel(
        id: 'special',
        title: 'Special Booking',
        emoji: '🎉',
        value: 'SpecialBooking',
      ),
      OrderPreferenceModel(
        id: 'pickup',
        title: 'Pickup',
        emoji: '🏃',
        value: 'Pickup',
      ),
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
    final responsive = ResponsiveHelper();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: responsive.spacing15,
          horizontal: responsive.spacing20,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColor.appPrimary.withOpacity(0.15)
                  : AppColor.scaffoldColor,
          borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
          border: Border.all(
            color:
                isSelected
                    ? AppColor.appPrimary.withOpacity(0.5)
                    : AppColor.black.withOpacity(0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColor.appPrimary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Row(
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: text(
                text: '${preference.emoji}   ${preference.title}',
                size: responsive.fontSize16,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColor.appPrimary : AppColor.black,
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.check_circle,
                  color: AppColor.appPrimary,
                  size: responsive.iconSizeMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
