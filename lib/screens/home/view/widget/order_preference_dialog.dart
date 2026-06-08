import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/service_type.dart';
import 'package:eatplek_app/screens/home/model/new_home_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/responsive_helper.dart';

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

  /// When false — no Cancel button shown, user MUST select a preference
  /// When true — Cancel button shown (used when changing existing preference)
  final bool canDismiss;

  const OrderPreferenceDialog({
    super.key,
    required this.currentPreference,
    required this.availableServices,
    required this.onPreferenceSelected,
    this.onDialogDismissed,
    this.title,
    this.subtitle,
    this.canDismiss = true,
  });

  static Future<void> show({
    required String currentPreference,
    required List<String> availableServices,
    required List<BannerData> banners,
    required Function(String) onPreferenceSelected,
    VoidCallback? onDialogDismissed,
    String? title,
    String? subtitle,
    bool canDismiss = true,
  }) async {
    debugPrint('🎯 OrderPreferenceDialog.show() | canDismiss: $canDismiss');

    showDialog(
      context: Get.context!,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible:
          false, // always false — we control dismiss via canDismiss param
      builder:
          (context) => OrderPreferenceDialog(
            currentPreference: currentPreference,
            availableServices: availableServices,
            onPreferenceSelected: onPreferenceSelected,
            onDialogDismissed: onDialogDismissed,
            title: title,
            subtitle: subtitle,
            canDismiss: canDismiss,
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
      // Prevent back button from dismissing when canDismiss is false
      canPop: widget.canDismiss,
      onPopInvoked: (didPop) {
        if (didPop && widget.canDismiss) {
          widget.onDialogDismissed?.call();
        }
      },
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
              SizedBox(height: responsive.spacing10),
              // Only show Cancel button when canDismiss is true
              if (widget.canDismiss) _buildCancelButton(responsive),
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
          // Icon indicator
          Container(
            width: responsive.spacing48,
            height: responsive.spacing48,
            decoration: BoxDecoration(
              color: AppColor.appPrimary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              color: AppColor.appPrimary,
              size: responsive.spacing24,
            ),
          ),
          SizedBox(height: responsive.spacing12),
          text(
            text: widget.title ?? 'How Would You Like to Order?',
            size: responsive.fontSize20,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
            color: AppColor.appPrimary,
          ),
          SizedBox(height: responsive.spacing6),
          text(
            text:
                widget.subtitle ??
                'Please choose your preferred service to continue.',
            size: responsive.fontSize13,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.55),
            textAlign: TextAlign.center,
          ),
          // Mandatory hint when user cannot skip
          if (!widget.canDismiss) ...[
            SizedBox(height: responsive.spacing8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.spacing12,
                vertical: responsive.spacing6,
              ),
              decoration: BoxDecoration(
                color: AppColor.appPrimary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(
                  responsive.cardBorderRadius,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: responsive.spacing14,
                    color: AppColor.appPrimary,
                  ),
                  SizedBox(width: responsive.spacing6),
                  text(
                    text: 'Selection required to continue',
                    size: responsive.fontSize11,
                    fontWeight: FontWeight.w500,
                    color: AppColor.appPrimary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColor.black.withOpacity(0.08), height: 1);
  }

  Widget _buildPreferenceOptions(ResponsiveHelper responsive) {
    final allPreferences = _getPreferenceOptions();

    // Filter to only show services available at this location
    final filteredPreferences =
        allPreferences.where((pref) {
          return widget.availableServices.any(
            (service) => ServiceType.same(service, pref.value),
          );
        }).toList();

    debugPrint(
      '📋 Available options: ${filteredPreferences.map((p) => p.value).toList()}',
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing20),
      child: Column(
        children: [
          SizedBox(height: responsive.spacing16),
          ...filteredPreferences.map((preference) {
            final bool isSelected = ServiceType.same(
              widget.currentPreference,
              preference.value,
            );
            return Padding(
              padding: EdgeInsets.only(bottom: responsive.spacing10),
              child: _buildPreferenceOptionTile(
                responsive: responsive,
                preference: preference,
                isSelected: isSelected,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPreferenceOptionTile({
    required ResponsiveHelper responsive,
    required OrderPreferenceModel preference,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        debugPrint('✅ Tapped: ${preference.value}');
        final String fullPreference =
            '${preference.emoji}  ${preference.value}';
        Navigator.of(Get.context!).pop();
        Future.delayed(const Duration(milliseconds: 200), () {
          widget.onPreferenceSelected(fullPreference);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: responsive.spacing15,
          horizontal: responsive.spacing20,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColor.appPrimary.withOpacity(0.12)
                  : AppColor.scaffoldColor,
          borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
          border: Border.all(
            color:
                isSelected
                    ? AppColor.appPrimary.withOpacity(0.5)
                    : AppColor.black.withOpacity(0.08),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColor.appPrimary.withOpacity(0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Row(
          children: [
            Text(
              preference.emoji,
              style: TextStyle(fontSize: responsive.fontSize20),
            ),
            SizedBox(width: responsive.spacing12),
            text(
              text: preference.title,
              size: responsive.fontSize15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColor.appPrimary : AppColor.black,
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child:
                  isSelected
                      ? Icon(
                        Icons.check_circle_rounded,
                        key: const ValueKey('checked'),
                        color: AppColor.appPrimary,
                        size: responsive.iconSizeMedium,
                      )
                      : Icon(
                        Icons.radio_button_unchecked_rounded,
                        key: const ValueKey('unchecked'),
                        color: AppColor.black.withOpacity(0.25),
                        size: responsive.iconSizeMedium,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(ResponsiveHelper responsive) {
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
          debugPrint('❌ Preference dialog cancelled');
          Navigator.of(Get.context!).pop();
          Future.delayed(const Duration(milliseconds: 200), () {
            widget.onDialogDismissed?.call();
          });
        },
        color: AppColor.scaffoldColor,
        borderColor: AppColor.black.withOpacity(0.10),
        textColor: AppColor.black,
      ),
    );
  }

  List<OrderPreferenceModel> _getPreferenceOptions() {
    return [
      OrderPreferenceModel(
        id: 'dine-in',
        title: ServiceType.dineIn,
        emoji: '🍽️',
        value: ServiceType.dineIn,
      ),
      OrderPreferenceModel(
        id: 'takeaway',
        title: ServiceType.takeaway,
        emoji: '🥡',
        value: ServiceType.takeaway,
      ),
      OrderPreferenceModel(
        id: 'delivery',
        title: ServiceType.delivery,
        emoji: '🛵',
        value: ServiceType.delivery,
      ),
      OrderPreferenceModel(
        id: 'car-dine-in',
        title: ServiceType.carDineIn,
        emoji: '🚗',
        value: ServiceType.carDineIn,
      ),
    ];
  }
}
