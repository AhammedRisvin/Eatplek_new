import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';

class QuantityControlWidget extends StatelessWidget {
  final num quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final bool showRemoveButton;
  final double buttonSize;
  final double iconSize;
  final EdgeInsets? margin;
  final String? addButtonText;
  final bool isCompactMode; // ✅ NEW: Flag to determine if this is used in add-ons/customization

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
    this.isCompactMode = false, // ✅ Default false (full-width mode)
  });

  @override
  Widget build(BuildContext context) {
    // ✅ When showing full-width "Add" button (food card scenario - quantity is 0)
    // This check is important: when quantity becomes 0, we should show Add button
    if (addButtonText != null && quantity == 0 && !isCompactMode) {
      return Container(
        margin: margin,
        width: double.infinity,
        child: GestureDetector(
          onTap: onIncrease,
          child: Container(
            width: double.infinity,
            height: buttonSize + 8,
            decoration: BoxDecoration(color: AppColor.appPrimary, borderRadius: BorderRadius.circular(100)),
            child: Center(
              child: text(text: addButtonText!, color: AppColor.white, size: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    // ✅ Compact quantity control (add-ons, customizations, OR when quantity > 0)
    return Container(
      margin: margin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease button - only show if quantity > 0
          if (showRemoveButton && quantity > 0)
            GestureDetector(
              onTap: onDecrease,
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.black.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(6), // ✅ Rounded square (not fully rounded)
                ),
                child: Icon(Icons.remove, color: AppColor.black.withOpacity(0.4), size: iconSize),
              ),
            ),

          // Quantity display - only show if quantity > 0
          if (quantity > 0) ...[
            5.w,
            Container(
              constraints: BoxConstraints(minWidth: 20),
              child: Text(
                quantity.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.black.withOpacity(0.6)),
              ),
            ),
            5.w,
          ],

          // Add/Increase button
          GestureDetector(
            onTap: onIncrease,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: AppColor.appPrimary,
                borderRadius: BorderRadius.circular(6), // ✅ Rounded square (not fully rounded circle)
              ),
              child: Icon(Icons.add, color: AppColor.white, size: iconSize),
            ),
          ),
        ],
      ),
    );
  }
}
