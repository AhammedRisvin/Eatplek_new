import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/util/app_color.dart';
import '../../../../../core/util/common_widgets.dart';
import '../../view_model/pre_book_controller.dart';

class PrebookBottomCartButton extends StatelessWidget {
  final String prebookId;
  final PrebookDetailController controller;

  const PrebookBottomCartButton({super.key, required this.prebookId, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PrebookDetailController>(
      id: 'prebook_quantity_$prebookId',
      builder: (controller) {
        final quantity = controller.getQuantity(prebookId);
        final isEnabled = quantity > 0;

        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColor.white,
              boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.08), blurRadius: 12, offset: Offset(0, -4))],
            ),
            child: SafeArea(
              top: false,
              child: GestureDetector(
                onTap:
                    isEnabled
                        ? () {
                          controller.addToCart(prebookId);
                        }
                        : null,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isEnabled ? AppColor.appPrimary : AppColor.appPrimary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: text(text: 'Add to Cart', size: 16, fontWeight: FontWeight.w600, color: AppColor.white),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
