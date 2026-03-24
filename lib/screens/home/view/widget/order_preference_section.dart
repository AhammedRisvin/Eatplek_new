import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../controller/home_controller.dart';

class OrderPreferenceSection extends StatelessWidget {
  final HomeController controller;

  const OrderPreferenceSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GetBuilder<HomeController>(
      id: HomeController.orderPreferenceId,
      builder: (controller) {
        final hasPreference = controller.orderPreference.isNotEmpty;

        return Container(
              width: responsive.screenWidth,
              margin: EdgeInsets.only(top: responsive.spacing20),
              padding: EdgeInsets.symmetric(
                horizontal: responsive.spacing20,
                vertical: responsive.spacing16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  responsive.largeBorderRadius,
                ),
                // Subtle gradient for depth
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColor.appPrimary.withOpacity(0.07),
                    AppColor.appPrimary.withOpacity(0.03),
                  ],
                ),
                border: Border.all(
                  color: AppColor.appPrimary.withOpacity(0.12),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Service type icon
                  Container(
                    width: responsive.spacing40,
                    height: responsive.spacing40,
                    decoration: BoxDecoration(
                      color: AppColor.appPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        responsive.smallBorderRadius * 2,
                      ),
                    ),
                    child: Icon(
                      _serviceIcon(controller.orderPreference),
                      color: AppColor.appPrimary,
                      size: responsive.fontSize20,
                    ),
                  ),
                  SizedBox(width: responsive.spacing12),

                  // Label + preference
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text(
                          text: 'Order Preference',
                          size: responsive.fontSize11,
                          fontWeight: FontWeight.w500,
                          color: AppColor.black.withOpacity(0.45),
                        ),
                        SizedBox(height: responsive.spacing3),
                        text(
                          text:
                              hasPreference
                                  ? controller.orderPreference
                                  : 'Select Preference',
                          size: responsive.fontSize15,
                          fontWeight: FontWeight.w600,
                          color:
                              hasPreference
                                  ? AppColor.appPrimary
                                  : AppColor.black.withOpacity(0.4),
                          maxLines: 1,
                          overFlow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Change button
                  GestureDetector(
                    onTap: controller.onOrderPreferenceChanged,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.spacing14,
                        vertical: responsive.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.appPrimary,
                        borderRadius: BorderRadius.circular(
                          responsive.largeBorderRadius,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.appPrimary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: text(
                        text: 'Change',
                        size: responsive.fontSize12,
                        fontWeight: FontWeight.w600,
                        color: AppColor.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fade(duration: 400.ms, delay: 100.ms)
            .slideY(
              begin: 0.15,
              end: 0,
              duration: 400.ms,
              delay: 100.ms,
              curve: Curves.easeOut,
            );
      },
    );
  }

  IconData _serviceIcon(String preference) {
    if (preference.contains('Delivery')) return Icons.delivery_dining_rounded;
    if (preference.contains('Takeaway')) return Icons.shopping_bag_rounded;
    if (preference.contains('Dine')) return Icons.restaurant_rounded;
    if (preference.contains('Car')) return Icons.directions_car_rounded;
    if (preference.contains('Book')) return Icons.calendar_today_rounded;
    return Icons.fastfood_rounded;
  }
}
