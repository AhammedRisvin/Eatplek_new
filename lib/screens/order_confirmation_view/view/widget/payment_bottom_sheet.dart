import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../controller/order_confirmation_controller.dart';

class PaymentBottomSheet extends StatelessWidget {
  final OrderConfirmationController controller;

  const PaymentBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.wp(100),
      padding: const EdgeInsets.only(left: 16.0, right: 16, top: 10, bottom: 20),
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Drag indicator
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 120,
              height: 4,
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: Color(0XFFD9D9D9), borderRadius: BorderRadius.circular(100)),
            ),
          ),
          6.h,

          // ✅ Title
          text(text: 'Select Your Payment Method', size: 18, fontWeight: FontWeight.w600, color: AppColor.black),
          6.h,

          // ✅ Description
          text(
            text: 'Choose a secure and convenient way to pay for your order.',
            size: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.6),
          ),
          12.h,

          // ✅ Divider
          Divider(color: AppColor.black.withOpacity(0.06), thickness: 1),
          12.h,

          // ✅ Payment Methods List
          GetBuilder<OrderConfirmationController>(
            id: 'payment_method',
            builder: (controller) {
              return ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final paymentMethod = controller.paymentMethods[index];
                  final isSelected = controller.selectedPaymentMethodIndex == index;

                  return GestureDetector(
                    onTap: () => controller.selectPaymentMethod(index),
                    child: Container(
                      width: context.wp(100),
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColor.appPrimary : AppColor.black.withOpacity(0.08),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppColor.appPrimary.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          else
                            BoxShadow(
                              color: AppColor.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // ✅ Payment method image
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColor.scaffoldColor,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                paymentMethod['imageUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColor.appPrimary.withOpacity(0.1),
                                    child: Icon(Icons.payment, color: AppColor.appPrimary),
                                  );
                                },
                              ),
                            ),
                          ),
                          14.w,

                          // ✅ Payment method info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                text(
                                  text: paymentMethod['name'] ?? 'Payment Method',
                                  size: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.black,
                                ),
                                4.h,
                                text(
                                  text: paymentMethod['description'] ?? 'Secure payment',
                                  size: 12,
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
                separatorBuilder: (context, index) => 12.h,
                itemCount: controller.paymentMethods.length,
              );
            },
          ),
          20.h,

          // ✅ Payment button
          button(
            name: 'Pay Now',
            width: context.wp(100),
            height: 56,
            borderRadius: BorderRadius.circular(100),
            fontSize: 16,
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

              // ✅ TODO: Integrate with payment gateway
              // Get.back();
              // TODO: Call payment processing method
              // Example: controller.processPayment(selectedPaymentMethod);

              Get.snackbar(
                'Payment Initiated',
                'Processing ${selectedPaymentMethod['name']} payment...',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColor.appPrimary.withOpacity(0.8),
                colorText: Colors.white,
                duration: Duration(seconds: 2),
              );

              // For now, just close the sheet after 2 seconds
              Future.delayed(Duration(seconds: 2), () {
                Get.back();
                // TODO: Navigate to order success page
                // Get.offAllNamed(Routes.orderSuccess);
              });
            },
          ),
          10.h,

          // ✅ Security info
          Container(
            width: context.wp(100),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lock, size: 16, color: Colors.green),
                8.w,
                Expanded(
                  child: text(
                    text: 'Your payment information is secure and encrypted.',
                    size: 12,
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
