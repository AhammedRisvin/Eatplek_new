import 'dart:developer';

import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/screens/order_confirmation_view/view/widget/waiting_confirmation_sheet.dart';
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          text(text: 'Select Your Payment Method', size: 18, fontWeight: FontWeight.w600, color: AppColor.black),
          6.h,
          text(
            text: 'Choose a secure and convenient way to pay for your order.',
            size: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.6),
          ),
          12.h,
          Divider(color: AppColor.black.withOpacity(0.06), thickness: 1),
          12.h,
          GetBuilder<OrderConfirmationController>(
            id: 'payment_method',
            builder: (controller) {
              return ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final paymentMethod = controller.paymentMethods[index];
                  return GestureDetector(
                    onTap: () => controller.selectPaymentMethod(index),
                    child: Container(
                      width: context.wp(100),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              controller.selectedPaymentMethodIndex == index
                                  ? AppColor.appPrimary
                                  : AppColor.black.withOpacity(0.03),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.black.withOpacity(0.05),
                            blurRadius: 24,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          image(
                            url: paymentMethod['imageUrl'],
                            width: 40,
                            height: 40,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          12.w,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                text(
                                  text: paymentMethod['name'],
                                  size: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.black,
                                ),
                                4.h,
                                text(
                                  text: paymentMethod['Description'],
                                  size: 11,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.black.withOpacity(0.6),
                                ),
                              ],
                            ),
                          ),
                          Radio<int>(
                            value: index,
                            groupValue: controller.selectedPaymentMethodIndex,
                            onChanged: (value) => controller.selectPaymentMethod(index),
                            activeColor: AppColor.appPrimary,
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
          button(
            name: 'Pay Now',
            width: context.wp(100),
            height: 50,
            borderRadius: BorderRadius.circular(100),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            onTap: () {
              Get.back();
              final selectedPaymentMethod = controller.paymentMethods[controller.selectedPaymentMethodIndex];
              log('Selected Payment Method: ${selectedPaymentMethod['name']}');
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColor.scaffoldColor,
                // isDismissible: false,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))),
                builder: (context) {
                  return WaitingFormConfirmationSheet(selectedPaymentMethod: selectedPaymentMethod);
                },
              );
            },
          ),
          10.h,
        ],
      ),
    );
  }
}
