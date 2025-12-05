import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../view_model/pre_book_controller.dart';

class PrebookQuantityControlWidget extends StatelessWidget {
  final String prebookId;
  final PrebookDetailController controller;
  final double buttonSize;
  final double iconSize;
  final EdgeInsets? margin;

  const PrebookQuantityControlWidget({
    super.key,
    required this.prebookId,
    required this.controller,
    this.buttonSize = 40,
    this.iconSize = 18,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PrebookDetailController>(
      id: 'prebook_quantity_$prebookId',
      builder: (controller) {
        final quantity = controller.getQuantity(prebookId);

        // ✅ Show ADD button with text inside when quantity is 0
        if (quantity == 0) {
          return Container(
            margin: margin,
            child: GestureDetector(
              onTap: () => controller.incrementQuantity(prebookId),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                height: buttonSize,
                decoration: BoxDecoration(color: AppColor.appPrimary, borderRadius: BorderRadius.circular(100)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [text(text: 'ADD', size: 13, fontWeight: FontWeight.w600, color: AppColor.white)],
                ),
              ),
            ),
          );
        }

        // ✅ Show compact quantity control (+/-) when quantity > 0
        return Container(
          margin: margin,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrease button
              GestureDetector(
                onTap: () => controller.decrementQuantity(prebookId),
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

              // Increase button
              GestureDetector(
                onTap: () => controller.incrementQuantity(prebookId),
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(color: AppColor.appPrimary, borderRadius: BorderRadius.circular(100)),
                  child: Icon(Icons.add, color: AppColor.white, size: iconSize),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
