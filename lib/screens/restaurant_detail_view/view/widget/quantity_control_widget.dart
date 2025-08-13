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

          GestureDetector(
            onTap: onIncrease,
            child: Container(
              width: addButtonText != null && quantity == 0 ? null : buttonSize,
              height: addButtonText != null && quantity == 0 ? null : buttonSize,
              padding:
                  addButtonText != null && quantity == 0 ? EdgeInsets.symmetric(horizontal: 20, vertical: 10) : null,
              decoration: BoxDecoration(
                color: AppColor.appPrimary,
                borderRadius: BorderRadius.circular(
                  addButtonText != null && quantity == 0 ? 20 : (showRemoveButton ? 100 : 6),
                ),
              ),
              child:
                  addButtonText != null && quantity == 0
                      ? text(text: addButtonText!, color: AppColor.white, size: 14, fontWeight: FontWeight.w600)
                      : Icon(Icons.add, color: AppColor.white, size: iconSize),
            ),
          ),
        ],
      ),
    );
  }
}

class AddOnSelectionWidget extends StatelessWidget {
  final String id;
  final String name;
  final String price;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;
  final double margin;

  const AddOnSelectionWidget({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
    this.margin = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.wp(100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColor.white,
          border: Border.all(color: isSelected ? AppColor.transparent : Colors.transparent, width: 1),
        ),
        margin: EdgeInsets.symmetric(horizontal: margin),
        padding: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 17),
        child: Row(
          children: [
            image(url: imageUrl, height: 40, width: 40, borderRadius: BorderRadius.circular(4)),
            20.w,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text(
                    text: name,
                    size: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black,
                    maxLines: 1,
                    overFlow: TextOverflow.ellipsis,
                  ),
                  4.h,
                  text(text: price, size: 12, fontWeight: FontWeight.w500, color: AppColor.black.withOpacity(0.6)),
                ],
              ),
            ),
            Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                color: isSelected ? AppColor.appPrimary : AppColor.white,
                border: Border.all(color: isSelected ? AppColor.appPrimary : AppColor.appPrimary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(6),
              ),
              child:
                  isSelected
                      ? Icon(Icons.done, color: isSelected ? AppColor.white : AppColor.black.withOpacity(0.4), size: 13)
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
