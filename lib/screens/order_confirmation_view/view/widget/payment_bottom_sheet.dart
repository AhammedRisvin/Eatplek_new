import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../controller/order_confirmation_controller.dart';

class ResponsivePaymentBottomSheet extends StatelessWidget {
  final OrderConfirmationController controller;

  const ResponsivePaymentBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      width: responsive.widthPercent(100),
      padding: responsive.bottomSheetPadding,
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(responsive.extraLargeBorderRadius)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Drag indicator
          Align(
            alignment: Alignment.center,
            child: Container(
              width: responsive.spacing120,
              height: responsive.spacing4,
              margin: EdgeInsets.only(bottom: responsive.spacing10),
              decoration: BoxDecoration(
                color: const Color(0XFFD9D9D9),
                borderRadius: BorderRadius.circular(responsive.extraLargeBorderRadius),
              ),
            ),
          ),
          SizedBox(height: responsive.spacing6),

          // ✅ Title
          text(
            text: 'Select Your Payment Method',
            size: responsive.fontSize18,
            fontWeight: FontWeight.w600,
            color: AppColor.black,
          ),
          SizedBox(height: responsive.spacing6),

          // ✅ Description
          text(
            text: 'Choose a secure and convenient way to pay for your order.',
            size: responsive.fontSize14,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.6),
          ),
          SizedBox(height: responsive.spacing12),

          // ✅ Divider
          Divider(color: AppColor.black.withOpacity(0.06), thickness: responsive.dividerThickness),
          SizedBox(height: responsive.spacing12),

          // ✅ Payment Methods List
          GetBuilder<OrderConfirmationController>(
            id: 'payment_method',
            builder: (controller) {
              return ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final paymentMethod = controller.paymentMethods[index];
                  final isSelected = controller.selectedPaymentMethodIndex == index;

                  return GestureDetector(
                    onTap: () => controller.selectPaymentMethod(index),
                    child: Container(
                      width: responsive.widthPercent(100),
                      padding: EdgeInsets.symmetric(vertical: responsive.spacing14, horizontal: responsive.spacing14),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(responsive.inputBorderRadius),
                        border: Border.all(
                          color: isSelected ? AppColor.appPrimary : AppColor.black.withOpacity(0.08),
                          width: isSelected ? responsive.borderWidthThick : responsive.borderWidthThin,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppColor.appPrimary.withOpacity(0.2),
                              blurRadius: responsive.shadowBlurMedium,
                              offset: Offset(0, responsive.shadowOffsetMedium),
                            )
                          else
                            BoxShadow(
                              color: AppColor.black.withOpacity(0.05),
                              blurRadius: responsive.shadowBlurSmall,
                              offset: Offset(0, responsive.shadowOffsetSmall),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // ✅ Payment method image
                          Container(
                            width: responsive.paymentIconSize,
                            height: responsive.paymentIconSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(responsive.inputBorderRadius),
                              color: AppColor.scaffoldColor,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(responsive.inputBorderRadius),
                              child: Image.network(
                                paymentMethod['imageUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColor.appPrimary.withOpacity(0.1),
                                    child: Icon(
                                      Icons.payment,
                                      color: AppColor.appPrimary,
                                      size: responsive.iconSizeMedium,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: responsive.spacing14),

                          // ✅ Payment method info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                text(
                                  text: paymentMethod['name'] ?? 'Payment Method',
                                  size: responsive.fontSize15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.black,
                                ),
                                SizedBox(height: responsive.spacing4),
                                text(
                                  text: paymentMethod['description'] ?? 'Secure payment',
                                  size: responsive.fontSize12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.black.withOpacity(0.6),
                                  maxLines: 1,
                                  overFlow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // ✅ Radio button
                          Radio<int>(
                            value: index,
                            groupValue: controller.selectedPaymentMethodIndex,
                            onChanged: (value) => controller.selectPaymentMethod(index),
                            activeColor: AppColor.appPrimary,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(height: responsive.spacing12),
                itemCount: controller.paymentMethods.length,
              );
            },
          ),
          SizedBox(height: responsive.spacing20),

          // ✅ Payment button
          button(
            name: 'Pay Now',
            width: responsive.widthPercent(100),
            height: responsive.formFieldHeight,
            borderRadius: BorderRadius.circular(responsive.extraLargeBorderRadius),
            fontSize: responsive.fontSize16,
            fontWeight: FontWeight.w600,
            onTap: () {
              final selectedPaymentMethod = controller.paymentMethods[controller.selectedPaymentMethodIndex];

              debugPrint('═════════════════════════════════════════');
              debugPrint('💳 PAYMENT METHOD SELECTED');
              debugPrint('═════════════════════════════════════════');
              debugPrint('Method: ${selectedPaymentMethod['name']}');
              debugPrint('ID: ${selectedPaymentMethod['id']}');
              debugPrint('Amount: ₹${controller.getTotalPrice()}');
              debugPrint('═════════════════════════════════════════');

              Get.snackbar(
                'Payment Initiated',
                'Processing ${selectedPaymentMethod['name']} payment...',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColor.appPrimary.withOpacity(0.8),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );

              Future.delayed(const Duration(seconds: 2), () {
                Get.back();
              });
            },
          ),
          SizedBox(height: responsive.spacing10),

          // ✅ Security info
          Container(
            width: responsive.widthPercent(100),
            padding: EdgeInsets.symmetric(vertical: responsive.spacing12, horizontal: responsive.spacing12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.inputBorderRadius),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lock, size: responsive.iconSizeSmall, color: Colors.green),
                SizedBox(width: responsive.spacing8),
                Expanded(
                  child: text(
                    text: 'Your payment information is secure and encrypted.',
                    size: responsive.fontSize12,
                    fontWeight: FontWeight.w400,
                    color: Colors.green.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
