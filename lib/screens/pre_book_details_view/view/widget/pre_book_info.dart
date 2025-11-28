import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/util/app_color.dart';
import '../../../../../core/util/common_widgets.dart';
import '../../../home/model/new_home_model.dart';
import '../../../restaurant_detail_view/view/widget/quantity_control_widget.dart';
import '../../view_model/pre_book_controller.dart';

class PrebookInfoSection extends StatelessWidget {
  final String prebookName;
  final String prebookId;
  final PrebookDetailController controller;
  final PrebookList? prebookData;

  const PrebookInfoSection({
    super.key,
    required this.prebookName,
    required this.prebookId,
    required this.controller,
    this.prebookData,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(
                text: prebookName,
                size: 20,
                fontWeight: FontWeight.w600,
                maxLines: 2,
                overFlow: TextOverflow.ellipsis,
              ),
              10.h,
              if (prebookData?.vendor?.hotelName != null)
                Row(
                  children: [
                    if (prebookData?.vendor?.profileImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          prebookData!.vendor!.profileImage ?? '',
                          height: 20,
                          width: 20,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                color: AppColor.black.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          },
                        ),
                      ),
                    10.w,
                    text(
                      text: prebookData!.vendor!.hotelName ?? 'Restaurant',
                      size: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColor.black.withOpacity(0.6),
                    ),
                  ],
                ),
              20.h,
              GetBuilder<PrebookDetailController>(
                id: 'prebook_quantity_$prebookId',
                builder: (controller) {
                  final quantity = controller.getQuantity(prebookId);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      QuantityControlWidget(
                        quantity: quantity,
                        onIncrease: () => controller.incrementQuantity(prebookId),
                        onDecrease: () => controller.decrementQuantity(prebookId),
                        showRemoveButton: quantity > 0,
                        buttonSize: quantity > 0 ? 40 : 60,
                        iconSize: 18,
                        addButtonText: quantity == 0 ? 'ADD' : null,
                      ),
                      3.h,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
