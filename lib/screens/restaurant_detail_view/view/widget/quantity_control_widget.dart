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

    // Full-width "Add" button when quantity is zero (Scenario 1 food card)
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
              boxShadow: [
                BoxShadow(
                  color: AppColor.appPrimary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: text(
                text: addButtonText!,
                color: AppColor.white,
                size: responsive.fontSize12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    // Compact +/- control
    return Container(
      margin: margin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease / remove button
          if (showRemoveButton && quantity > 0)
            _ControlButton(
              onTap: onDecrease,
              size: buttonSize,
              iconSize: iconSize,
              icon: Icons.remove,
              isAdd: false,
            ),

          // Quantity count
          if (quantity > 0) ...[
            SizedBox(width: responsive.spacing5),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder:
                  (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
              child: ConstrainedBox(
                key: ValueKey(quantity),
                constraints: BoxConstraints(minWidth: responsive.spacing20),
                child: Text(
                  quantity.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.fontSize13,
                    fontWeight: FontWeight.w700,
                    color: AppColor.appPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: responsive.spacing5),
          ],

          // Add / increase button
          _ControlButton(
            onTap: onIncrease,
            size: buttonSize,
            iconSize: iconSize,
            icon: Icons.add,
            isAdd: true,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final IconData icon;
  final bool isAdd;

  const _ControlButton({
    required this.onTap,
    required this.size,
    required this.iconSize,
    required this.icon,
    required this.isAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isAdd ? AppColor.appPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border:
              isAdd
                  ? null
                  : Border.all(
                    color: AppColor.appPrimary.withOpacity(0.5),
                    width: 1.2,
                  ),
          boxShadow:
              isAdd
                  ? [
                    BoxShadow(
                      color: AppColor.appPrimary.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Icon(
          icon,
          color: isAdd ? AppColor.white : AppColor.appPrimary,
          size: iconSize,
        ),
      ),
    );
  }
}
