import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../controller/order_confirmation_controller.dart';

class OrderItemUpdateSheet extends StatelessWidget {
  final OrderConfirmationController controller;

  const OrderItemUpdateSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final maxHeight = MediaQuery.of(context).size.height * 0.86;

    return SafeArea(
      top: false,
      child: Container(
        width: responsive.widthPercent(100),
        constraints: BoxConstraints(maxHeight: maxHeight),
        padding: EdgeInsets.fromLTRB(
          responsive.spacing20,
          responsive.spacing10,
          responsive.spacing20,
          responsive.spacing16,
        ),
        decoration: BoxDecoration(
          color: AppColor.scaffoldColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(responsive.extraLargeBorderRadius),
          ),
        ),
        child: GetBuilder<OrderConfirmationController>(
          id: 'vendor_item_update_sheet',
          builder: (controller) {
            final changes = controller.vendorItemChanges;
            final hasUnavailable = changes.any((item) => item.isUnavailable);
            final title =
                hasUnavailable
                    ? 'Item Unavailable - Please Reorder'
                    : 'Quantity Update Required';

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: responsive.spacing120,
                  height: responsive.spacing4,
                  margin: EdgeInsets.only(bottom: responsive.spacing12),
                  decoration: BoxDecoration(
                    color: const Color(0XFFD9D9D9),
                    borderRadius: BorderRadius.circular(
                      responsive.extraLargeBorderRadius,
                    ),
                  ),
                ),
                _buildPlaceholder(responsive),
                SizedBox(height: responsive.spacing12),
                text(
                  text: title,
                  size: responsive.fontSize20,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: responsive.spacing8),
                text(
                  text:
                      hasUnavailable
                          ? 'Some items in your order are currently unavailable. Please select replacement items or continue without them.'
                          : 'Please adjust your order. You can continue with the available quantity or reorder with different items.',
                  size: responsive.fontSize13,
                  fontWeight: FontWeight.w400,
                  color: AppColor.black.withOpacity(0.58),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: responsive.spacing18),
                Flexible(
                  child: Container(
                    width: responsive.widthPercent(100),
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(
                        responsive.largeBorderRadius,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child:
                        changes.isEmpty
                            ? Padding(
                              padding: EdgeInsets.all(responsive.spacing20),
                              child: text(
                                text: 'No item changes were returned.',
                                size: responsive.fontSize14,
                                color: AppColor.black.withOpacity(0.6),
                                textAlign: TextAlign.center,
                              ),
                            )
                            : ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.all(responsive.spacing12),
                              itemCount: changes.length,
                              separatorBuilder:
                                  (context, index) =>
                                      SizedBox(height: responsive.spacing12),
                              itemBuilder:
                                  (_, index) => _buildItemRow(
                                    responsive,
                                    controller,
                                    changes[index],
                                  ),
                            ),
                  ),
                ),
                SizedBox(height: responsive.spacing18),
                button(
                  name: 'Continue with Order',
                  width: responsive.widthPercent(100),
                  height: responsive.formFieldHeight,
                  borderRadius: BorderRadius.circular(
                    responsive.extraLargeBorderRadius,
                  ),
                  fontSize: responsive.fontSize15,
                  fontWeight: FontWeight.w600,
                  onTap: () async {
                    await controller.continueWithVendorItemChanges();
                  },
                ),
                SizedBox(height: responsive.spacing10),
                GestureDetector(
                  onTap: controller.cancelVendorUpdateFlow,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: responsive.spacing6,
                    ),
                    child: text(
                      text: 'Cancel and edit order',
                      size: responsive.fontSize13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black.withOpacity(0.55),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ResponsiveHelper responsive) {
    return Container(
      width: responsive.spacing80,
      height: responsive.spacing60,
      decoration: BoxDecoration(
        color: AppColor.appPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(responsive.inputBorderRadius),
      ),
      child: Icon(
        Icons.room_service_outlined,
        color: AppColor.appPrimary,
        size: responsive.iconSizeLarge,
      ),
    );
  }

  Widget _buildItemRow(
    ResponsiveHelper responsive,
    OrderConfirmationController controller,
    VendorOrderItemChange item,
  ) {
    final statusText =
        item.isUnavailable
            ? 'Unavailable'
            : item.hasQuantityUpdate
            ? 'Only ${item.updatedQuantity} QTY'
            : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        image(
          url: item.foodImage,
          width: responsive.spacing48,
          height: responsive.spacing48,
          borderRadius: BorderRadius.circular(responsive.inputBorderRadius),
        ),
        SizedBox(width: responsive.spacing10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(
                text:
                    item.hasQuantityUpdate
                        ? '${item.foodName} (X${item.requestedQuantity})'
                        : item.foodName,
                size: responsive.fontSize13,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                overFlow: TextOverflow.ellipsis,
              ),
              SizedBox(height: responsive.spacing4),
              Wrap(
                spacing: responsive.spacing8,
                runSpacing: responsive.spacing4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  text(
                    text: 'Rs.${item.price.toStringAsFixed(0)}',
                    size: responsive.fontSize13,
                    fontWeight: FontWeight.w700,
                    color: AppColor.appPrimary,
                  ),
                  if (statusText != null)
                    text(
                      text: statusText,
                      size: responsive.fontSize12,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                ],
              ),
              if (item.reason != null && item.reason!.trim().isNotEmpty) ...[
                SizedBox(height: responsive.spacing4),
                text(
                  text: item.reason!,
                  size: responsive.fontSize11,
                  color: AppColor.black.withOpacity(0.48),
                  maxLines: 2,
                  overFlow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (item.isModified) ...[
          SizedBox(width: responsive.spacing8),
          SizedBox(
            height: responsive.spacing35,
            child: TextButton(
              onPressed: () => controller.reorderVendorItem(item),
              style: TextButton.styleFrom(
                backgroundColor: AppColor.appPrimary,
                foregroundColor: AppColor.white,
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    responsive.inputBorderRadius,
                  ),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: text(
                text: 'Reorder',
                size: responsive.fontSize11,
                fontWeight: FontWeight.w700,
                color: AppColor.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
