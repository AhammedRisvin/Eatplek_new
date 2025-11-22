import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';

class QuantityControlWidget extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final bool showRemoveButton;
  final double buttonSize;
  final double iconSize;
  final EdgeInsets? margin;
  final String? addButtonText;

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
  });

  @override
  Widget build(BuildContext context) {
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
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(Icons.remove, color: AppColor.black.withOpacity(0.4), size: iconSize),
              ),
            ),

          // Quantity display
          if (showRemoveButton && quantity > 0) ...[
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
              width: addButtonText != null && quantity == 0 ? null : buttonSize,
              height: addButtonText != null && quantity == 0 ? null : buttonSize,
              padding: addButtonText != null && quantity == 0 ? EdgeInsets.symmetric(horizontal: 8, vertical: 6) : null,
              decoration: BoxDecoration(
                color: AppColor.appPrimary,
                borderRadius: BorderRadius.circular(
                  addButtonText != null && quantity == 0 ? 20 : (showRemoveButton ? 100 : 6),
                ),
              ),
              child:
                  addButtonText != null && quantity == 0
                      ? text(text: addButtonText!, color: AppColor.white, size: 12, fontWeight: FontWeight.w600)
                      : Icon(Icons.add, color: AppColor.white, size: iconSize),
            ),
          ),
        ],
      ),
    );
  }
}
