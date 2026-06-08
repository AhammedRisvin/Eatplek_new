import 'package:flutter/material.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/responsive_helper.dart';

class OrderPreferenceConfirmBottomSheet extends StatelessWidget {
  final String restaurantName;
  final String preference;
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  const OrderPreferenceConfirmBottomSheet({
    super.key,
    required this.restaurantName,
    required this.preference,
    required this.onContinue,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          responsive.spacing20,
          responsive.spacing10,
          responsive.spacing20,
          responsive.spacing20,
        ),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(responsive.largeBorderRadius),
            topRight: Radius.circular(responsive.largeBorderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: responsive.spacing80,
              height: responsive.spacing4,
              margin: EdgeInsets.only(bottom: responsive.spacing18),
              decoration: BoxDecoration(
                color: AppColor.black.withOpacity(0.12),
                borderRadius: BorderRadius.circular(
                  responsive.largeBorderRadius,
                ),
              ),
            ),
            Container(
              width: responsive.spacing50,
              height: responsive.spacing50,
              decoration: BoxDecoration(
                color: AppColor.appPrimary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _serviceIcon(preference),
                color: AppColor.appPrimary,
                size: responsive.spacing25,
              ),
            ),
            SizedBox(height: responsive.spacing14),
            Text(
              'Continue with this preference?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.black,
                fontSize: responsive.fontSize18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: responsive.spacing8),
            Text(
              'You are about to open $restaurantName using your selected order preference.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.black.withOpacity(0.55),
                fontSize: responsive.fontSize13,
                height: 1.35,
              ),
            ),
            SizedBox(height: responsive.spacing16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: responsive.spacing16,
                vertical: responsive.spacing14,
              ),
              decoration: BoxDecoration(
                color: AppColor.appPrimary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(
                  responsive.cardBorderRadius,
                ),
                border: Border.all(
                  color: AppColor.appPrimary.withOpacity(0.18),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _serviceIcon(preference),
                    color: AppColor.appPrimary,
                    size: responsive.spacing20,
                  ),
                  SizedBox(width: responsive.spacing10),
                  Expanded(
                    child: Text(
                      preference.isEmpty ? 'Select Preference' : preference,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColor.appPrimary,
                        fontSize: responsive.fontSize15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: responsive.spacing20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: responsive.buttonHeight,
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.black.withOpacity(0.7),
                        side: BorderSide(
                          color: AppColor.black.withOpacity(0.14),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            responsive.largeBorderRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: responsive.fontSize14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: responsive.spacing12),
                Expanded(
                  child: SizedBox(
                    height: responsive.buttonHeight,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.appPrimary,
                        foregroundColor: AppColor.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            responsive.largeBorderRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: responsive.fontSize14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _serviceIcon(String preference) {
    if (preference.contains('Delivery')) return Icons.delivery_dining_rounded;
    if (preference.contains('Takeaway')) return Icons.shopping_bag_rounded;
    if (preference.contains('Car')) return Icons.directions_car_rounded;
    if (preference.contains('Dine')) return Icons.restaurant_rounded;
    return Icons.fastfood_rounded;
  }
}
