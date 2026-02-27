import 'package:flutter/material.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';

class QuantityControlWidget extends StatelessWidget {
  final num quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final bool showRemoveButton;
  final double buttonSize;
  final double iconSize;
  final EdgeInsets? margin;
  final String? addButtonText;
  final bool isCompactMode;

  const QuantityControlWidget({
    super.key,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    this.showRemoveButton = true,
    this.buttonSize = 28,
    this.iconSize = 14,
    this.margin,
    this.addButtonText,
    this.isCompactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    // Full-width "Add" button (food card scenario - quantity is 0)
    if (addButtonText != null && quantity == 0 && !isCompactMode) {
      return Container(
        margin: margin,
        width: double.infinity,
        child: GestureDetector(
          onTap: onIncrease,
          child: Container(
            width: double.infinity,
            height: buttonSize + 8,
            decoration: BoxDecoration(
              color: AppColor.appPrimary,
              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
            ),
            child: Center(
              child: text(
                text: addButtonText!,
                color: AppColor.white,
                size: responsive.fontSize13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    // Compact quantity control
    return Container(
      margin: margin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease button
          if (showRemoveButton && quantity > 0)
            GestureDetector(
              onTap: onDecrease,
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.black.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(responsive.spacing6),
                ),
                child: Icon(Icons.remove, color: AppColor.black.withOpacity(0.4), size: iconSize),
              ),
            ),

          // Quantity display
          if (quantity > 0) ...[
            SizedBox(width: responsive.spacing5),
            Container(
              constraints: BoxConstraints(minWidth: responsive.spacing20),
              child: Text(
                quantity.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.fontSize14,
                  fontWeight: FontWeight.w500,
                  color: AppColor.black.withOpacity(0.6),
                ),
              ),
            ),
            SizedBox(width: responsive.spacing5),
          ],

          // Add/Increase button
          GestureDetector(
            onTap: onIncrease,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: AppColor.appPrimary,
                borderRadius: BorderRadius.circular(responsive.spacing6),
              ),
              child: Icon(Icons.add, color: AppColor.white, size: iconSize),
            ),
          ),
        ],
      ),
    );
  }
}
