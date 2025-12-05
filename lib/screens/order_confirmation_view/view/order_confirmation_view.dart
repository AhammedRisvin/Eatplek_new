import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:svg_flutter/svg.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../controller/order_confirmation_controller.dart';
import 'widget/address_section.dart';
import 'widget/number_of_guesta_widget.dart';
import 'widget/order_summary_widget.dart';
import 'widget/restaurant_widget_from_orders.dart';
import 'widget/time_selection_widget.dart';

class OrderConfirmationView extends StatefulWidget {
  const OrderConfirmationView({super.key});

  @override
  State<OrderConfirmationView> createState() => _OrderConfirmationViewState();
}

class _OrderConfirmationViewState extends State<OrderConfirmationView> {
  late OrderConfirmationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OrderConfirmationController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        title: text(text: 'Order Confirmation', size: 18, fontWeight: FontWeight.w600),
        leading: GestureDetector(
          onTap: () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withOpacity(0.06), width: 1.5),
              ),
              child: SvgPicture.string(arrowBack2),
            ),
          ),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // ✅ Restaurant Information Widget (Always shown)
              GetBuilder<OrderConfirmationController>(
                id: 'restaurant_widget',
                builder: (controller) {
                  return RestaurantWidgetFromOrders();
                },
              ),
              20.h,

              // ✅ DYNAMIC WIDGETS BASED ON SERVICE TYPE
              GetBuilder<OrderConfirmationController>(
                id: 'service_type_layout',
                builder: (controller) {
                  return Column(
                    children: [
                      // ✅ DELIVERY: Show Address Widget
                      if (controller.isDelivery()) ...[AddressWidget(controller: controller), 20.h],

                      // ✅ TAKEAWAY: Show Time Selection Widget
                      if (controller.isTakeaway()) ...[TimeSelectingWidget(controller: controller), 20.h],

                      // ✅ DINE-IN: Show Time + Guest Count Widgets
                      if (controller.isDineIn()) ...[
                        TimeSelectingWidget(controller: controller),
                        20.h,
                        NumberOfGuestWidget(controller: controller),
                        20.h,
                      ],

                      // ✅ CAR DINE-IN: Show Time Widget (Car details from cart)
                      if (controller.isCarDineIn()) ...[TimeSelectingWidget(controller: controller), 20.h],
                    ],
                  );
                },
              ),

              // ✅ Order Summary Widget (Always shown)
              GetBuilder<OrderConfirmationController>(
                id: 'order_summary',
                builder: (controller) {
                  return OrderSummaryWidget(
                    mainDishes: controller.getMainDishes(),
                    addOns: controller.getAddOns(),
                    totalAmount: controller.getTotalPrice(),
                    title: 'Order Summary',
                    showMainDishesSection: true,
                    showAddOnsSection: true,
                    showTotalSection: true,
                    mainDishesTitle: 'Items',
                    addOnsTitle: 'Add-ons & Customizations',
                    totalTitle: 'Total Amount',
                  );
                },
              ),
              20.h,

              // ✅ Special Instructions Display (if any and applicable service types)
              if (controller.instructions.isNotEmpty && (controller.isDelivery() || controller.isTakeaway())) ...[
                Container(
                  width: context.wp(100),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.appPrimary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text(
                        text: 'Special Instructions',
                        size: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.appPrimary,
                      ),
                      8.h,
                      text(
                        text: controller.instructions,
                        size: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColor.black.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
                20.h,
              ],

              // ✅ Car Details Display (if car dine-in and car details available)
              if (controller.isCarDineIn() && controller.vehicleDetailsController.text.isNotEmpty) ...[
                Container(
                  width: context.wp(100),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.appPrimary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text(text: 'Vehicle Details', size: 14, fontWeight: FontWeight.w600, color: AppColor.appPrimary),
                      8.h,
                      text(
                        text: controller.vehicleDetailsController.text,
                        size: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColor.black.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
                20.h,
              ],

              // ✅ Promo Code Display (if applied)
              if (controller.appliedPromoCode.isNotEmpty) ...[
                Container(
                  width: context.wp(100),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text(
                        text: 'Promo Code: ${controller.appliedPromoCode}',
                        size: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                      text(
                        text: '- ₹${controller.promoDiscount.toStringAsFixed(2)}',
                        size: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
                20.h,
              ],

              // ✅ Price Breakdown (Always shown)
              Container(
                width: context.wp(100),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(color: AppColor.scaffoldColor, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildPriceRow('Subtotal', controller.subtotal),
                    8.h,
                    _buildPriceRow('Tax', controller.taxAmount, color: Colors.orange),
                    8.h,
                    _buildPriceRow('Packing Charge', controller.packingCharge),
                    Divider(color: AppColor.black.withOpacity(0.1), height: 16),
                    _buildPriceRow(
                      'Total Amount',
                      controller.getTotalPrice(),
                      isBold: true,
                      color: AppColor.appPrimary,
                    ),
                  ],
                ),
              ),
              30.h,
            ],
          ),
        ),
      ),
      bottomNavigationBar: GetBuilder<OrderConfirmationController>(
        id: 'place_order_button',
        builder: (controller) {
          // ✅ Determine if button should be enabled based on service type validation
          final isButtonEnabled = !controller.isLoading && _isAllFieldsValid(controller);

          return Container(
            width: context.wp(100),
            color: AppColor.scaffoldColor,
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Validation error message if fields are incomplete
                if (!isButtonEnabled && !controller.isLoading) ...[
                  Container(
                    width: context.wp(100),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.orange),
                        8.w,
                        Expanded(
                          child: text(
                            text: _getValidationErrorMessage(controller),
                            size: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                button(
                  name: 'Confirm Order',
                  width: context.wp(100),
                  fontSize: 18,
                  height: 60,
                  fontWeight: FontWeight.w600,
                  borderRadius: BorderRadius.circular(100),
                  isLoading: controller.isLoading,
                  onTap: isButtonEnabled ? () => controller.confirmOrder() : null,
                  color: AppColor.appPrimary,
                ),
                10.h,
                text(
                  text:
                      'If you wish to cancel your order, please do so within 40 minutes of placing it to avoid any charges.',
                  size: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColor.black.withOpacity(0.6),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ✅ Helper widget to build price rows
  Widget _buildPriceRow(String label, double amount, {bool isBold = false, Color color = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        text(
          text: label,
          size: isBold ? 15 : 14,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
          color: isBold ? color : AppColor.black.withOpacity(0.7),
        ),
        text(
          text: '₹ ${amount.toStringAsFixed(2)}',
          size: isBold ? 15 : 14,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
          color: isBold ? color : AppColor.black.withOpacity(0.7),
        ),
      ],
    );
  }

  /// ✅ Check if all required fields are valid based on service type
  bool _isAllFieldsValid(OrderConfirmationController controller) {
    // ✅ DELIVERY: name, phoneNumber, address required
    if (controller.isDelivery()) {
      if (controller.fullNameController.text.trim().isEmpty) return false;
      if (controller.phoneController.text.trim().isEmpty) return false;
      if (controller.addressController.text.trim().isEmpty) return false;
      return true;
    }

    // ✅ DINE-IN: personCount, reachTime required
    if (controller.isDineIn()) {
      if (controller.guestCountController.text.trim().isEmpty) return false;

      final guestCount = int.tryParse(controller.guestCountController.text.trim());
      if (guestCount == null ||
          guestCount < OrderConfirmationController.minGuests ||
          guestCount > OrderConfirmationController.maxGuests) {
        return false;
      }

      if (!controller.isTimeValid()) return false;
      return true;
    }

    // ✅ TAKEAWAY: reachTime required only
    if (controller.isTakeaway()) {
      if (!controller.isTimeValid()) return false;
      return true;
    }

    // ✅ CAR DINE-IN: reachTime, vehicleDetails required
    if (controller.isCarDineIn()) {
      if (!controller.isTimeValid()) return false;
      if (controller.vehicleDetailsController.text.trim().isEmpty) return false;
      return true;
    }

    return true;
  }

  /// ✅ Get validation error message based on service type and missing fields
  String _getValidationErrorMessage(OrderConfirmationController controller) {
    // ✅ DELIVERY
    if (controller.isDelivery()) {
      if (controller.fullNameController.text.trim().isEmpty) {
        return 'Please enter your full name';
      }
      if (controller.phoneController.text.trim().isEmpty) {
        return 'Please enter your phone number';
      }
      if (controller.addressController.text.trim().isEmpty) {
        return 'Please enter your delivery address';
      }
      return 'Please fill in all required fields';
    }

    // ✅ DINE-IN
    if (controller.isDineIn()) {
      if (controller.guestCountController.text.trim().isEmpty) {
        return 'Please enter number of guests';
      }
      final guestCount = int.tryParse(controller.guestCountController.text.trim());
      if (guestCount == null ||
          guestCount < OrderConfirmationController.minGuests ||
          guestCount > OrderConfirmationController.maxGuests) {
        return 'Please enter valid number of guests (1-30)';
      }
      if (!controller.isTimeValid()) {
        return controller.timeErrorMessage ?? 'Please select a valid dining time';
      }
      return 'Please fill in all required fields';
    }

    // ✅ TAKEAWAY
    if (controller.isTakeaway()) {
      if (!controller.isTimeValid()) {
        return controller.timeErrorMessage ?? 'Please select a valid pickup time';
      }
      return 'Please fill in all required fields';
    }

    // ✅ CAR DINE-IN
    if (controller.isCarDineIn()) {
      if (!controller.isTimeValid()) {
        return controller.timeErrorMessage ?? 'Please select a valid dining time';
      }
      if (controller.vehicleDetailsController.text.trim().isEmpty) {
        return 'Please enter your vehicle details';
      }
      return 'Please fill in all required fields';
    }

    return 'Please fill in all required fields';
  }
}
