import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/price_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/util/responsive_helper.dart';
import '../controller/order_confirmation_controller.dart';
import 'widget/address_section.dart';
import 'widget/number_of_guesta_widget.dart';
import 'widget/order_summary_widget.dart';
import 'widget/responsive_special_instruction.dart';
import 'widget/restaurant_widget_from_orders.dart';
import 'widget/time_selection_widget.dart';

class OrderConfirmationView extends StatefulWidget {
  const OrderConfirmationView({super.key});

  @override
  State<OrderConfirmationView> createState() => _OrderConfirmationViewState();
}

class _OrderConfirmationViewState extends State<OrderConfirmationView> {
  late OrderConfirmationController controller;
  late ResponsiveHelper responsive;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OrderConfirmationController());
    responsive = ResponsiveHelper();
  }

  @override
  Widget build(BuildContext context) {
    responsive = ResponsiveHelper();

    return Scaffold(
      appBar: _buildAppBar(),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: responsive.allPadding20,
          child: Column(
            children: [
              // ✅ Restaurant Information Widget (Always shown)
              GetBuilder<OrderConfirmationController>(
                id: 'restaurant_widget',
                builder: (controller) {
                  return ResponsiveRestaurantWidget(controller: controller);
                },
              ),
              SizedBox(height: responsive.spacing20),

              // ✅ DYNAMIC WIDGETS BASED ON SERVICE TYPE
              GetBuilder<OrderConfirmationController>(
                id: 'service_type_layout',
                builder: (controller) {
                  return Column(
                    children: [
                      // ✅ DELIVERY: Show Address Widget
                      if (controller.isDelivery()) ...[
                        ResponsiveAddressWidget(controller: controller),
                        SizedBox(height: responsive.spacing20),
                      ],

                      // ✅ TAKEAWAY: Show Time Selection Widget
                      if (controller.isTakeaway()) ...[
                        ResponsiveTimeSelectingWidget(controller: controller),
                        SizedBox(height: responsive.spacing20),
                      ],

                      // ✅ DINE-IN: Show Time + Guest Count Widgets
                      if (controller.isDineIn()) ...[
                        ResponsiveTimeSelectingWidget(controller: controller),
                        SizedBox(height: responsive.spacing20),
                        ResponsiveNumberOfGuestWidget(controller: controller),
                        SizedBox(height: responsive.spacing20),
                      ],

                      // ✅ CAR DINE-IN: Show Time Widget
                      if (controller.isCarDineIn()) ...[
                        ResponsiveTimeSelectingWidget(controller: controller),
                        SizedBox(height: responsive.spacing20),
                      ],
                    ],
                  );
                },
              ),

              // ✅ Order Summary Widget (Always shown)
              GetBuilder<OrderConfirmationController>(
                id: 'order_summary',
                builder: (controller) {
                  return ResponsiveOrderSummaryWidget(
                    mainDishes: controller.getMainDishes(),
                    addOns: controller.getAddOns(),
                    totalAmount: controller.getTotalPrice(),
                    title: 'Order Summary',
                  );
                },
              ),
              SizedBox(height: responsive.spacing20),

              // ✅ Special Instructions (if applicable)
              if (controller.instructions.isNotEmpty &&
                  (controller.isDelivery() || controller.isTakeaway())) ...[
                ResponsiveSpecialInstructionsWidget(
                  instructions: controller.instructions,
                ),
                SizedBox(height: responsive.spacing20),
              ],

              // ✅ Car Details (if car dine-in)
              if (controller.isCarDineIn() &&
                  controller.vehicleDetailsController.text.isNotEmpty) ...[
                _buildCarDetailsSection(),
                SizedBox(height: responsive.spacing20),
              ],

              // ✅ Promo Code — only show when discount > 0
              if (controller.appliedPromoCode.isNotEmpty &&
                  controller.promoDiscount > 0) ...[
                _buildPromoCodeSection(),
                SizedBox(height: responsive.spacing20),
              ],

              // ✅ Price Breakdown (Always shown)
              _buildPriceBreakdownSection(),
              SizedBox(height: responsive.spacing30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ============ APPBAR ============
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leadingWidth: responsive.appBarLeadingWidth,
      toolbarHeight: responsive.appBarHeight,
      title: text(
        text: 'Order Confirmation',
        size: responsive.fontSize18,
        fontWeight: FontWeight.w600,
      ),
      leading: GestureDetector(
        onTap: () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        child: CircleAvatar(
          radius: responsive.spacing25,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(responsive.spacing16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withOpacity(0.06),
                width: responsive.borderWidthMedium,
              ),
            ),
            child: SvgPicture.string(arrowBack2),
          ),
        ),
      ),
    );
  }

  // ============ CAR DETAILS SECTION ============
  Widget _buildCarDetailsSection() {
    return Container(
      width: responsive.widthPercent(100),
      padding: responsive.containerPadding,
      decoration: responsive.responsiveContainer(
        borderColor: AppColor.appPrimary.withOpacity(0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(
            text: 'Vehicle Details',
            size: responsive.fontSize14,
            fontWeight: FontWeight.w600,
            color: AppColor.appPrimary,
          ),
          SizedBox(height: responsive.spacing8),
          text(
            text: controller.vehicleDetailsController.text,
            size: responsive.fontSize13,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  // ============ PROMO CODE SECTION ============
  // ✅ Only rendered when appliedPromoCode is not empty AND promoDiscount > 0
  Widget _buildPromoCodeSection() {
    return Container(
      width: responsive.widthPercent(100),
      padding: EdgeInsets.symmetric(
        vertical: responsive.spacing12,
        horizontal: responsive.spacing16,
      ),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.inputBorderRadius),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          text(
            text: 'Promo Code: ${controller.appliedPromoCode}',
            size: responsive.fontSize14,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
          text(
            text: '- ${formatCurrency(controller.promoDiscount)}',
            size: responsive.fontSize14,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  // ============ PRICE BREAKDOWN SECTION ============
  Widget _buildPriceBreakdownSection() {
    return Container(
      width: responsive.widthPercent(100),
      padding: responsive.containerPadding,
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor,
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', controller.subtotal),
          SizedBox(height: responsive.spacing8),
          _buildPriceRow('Tax', controller.taxAmount, color: Colors.orange),
          SizedBox(height: responsive.spacing8),
          _buildPriceRow('Packing Charge', controller.packingCharge),

          // ✅ Show discount row in price breakdown too — only when > 0
          if (controller.promoDiscount > 0) ...[
            SizedBox(height: responsive.spacing8),
            _buildPriceRow(
              'Discount (${controller.appliedPromoCode})',
              controller.promoDiscount,
              color: Colors.green,
              isDiscount: true,
            ),
          ],

          Divider(
            color: AppColor.black.withOpacity(0.1),
            height: responsive.spacing16,
            thickness: responsive.dividerThickness,
          ),
          _buildPriceRow(
            'Total Amount',
            controller.getTotalPrice(),
            isBold: true,
            color: AppColor.appPrimary,
          ),
        ],
      ),
    );
  }

  // ============ PRICE ROW HELPER ============
  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isBold = false,
    Color color = Colors.black,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        text(
          text: label,
          size: isBold ? responsive.fontSize15 : responsive.fontSize14,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
          color: isBold ? color : AppColor.black.withOpacity(0.7),
        ),
        text(
          text:
              isDiscount
                  ? '- ${formatCurrency(amount, space: true)}'
                  : formatCurrency(amount, space: true),
          size: isBold ? responsive.fontSize15 : responsive.fontSize14,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
          color:
              isBold
                  ? color
                  : isDiscount
                  ? Colors.green
                  : AppColor.black.withOpacity(0.7),
        ),
      ],
    );
  }

  // ============ BOTTOM NAVIGATION BAR ============
  Widget _buildBottomNavigationBar() {
    return GetBuilder<OrderConfirmationController>(
      id: 'place_order_button',
      builder: (controller) {
        final isButtonEnabled =
            !controller.isLoading && _isAllFieldsValid(controller);

        return Container(
          width: responsive.widthPercent(100),
          color: AppColor.scaffoldColor,
          padding: EdgeInsets.only(
            left: responsive.spacing20,
            right: responsive.spacing20,
            top: responsive.spacing20,
            bottom: responsive.spacing20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Validation hint
              if (!isButtonEnabled && !controller.isLoading) ...[
                Container(
                  width: responsive.widthPercent(100),
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing12,
                    vertical: responsive.spacing10,
                  ),
                  margin: EdgeInsets.only(bottom: responsive.spacing12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      responsive.inputBorderRadius,
                    ),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: responsive.iconSizeSmall,
                        color: Colors.orange,
                      ),
                      SizedBox(width: responsive.spacing8),
                      Expanded(
                        child: text(
                          text: _getValidationErrorMessage(controller),
                          size: responsive.fontSize12,
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
                width: responsive.widthPercent(100),
                fontSize: responsive.fontSize18,
                height: responsive.bottomNavButtonHeight,
                fontWeight: FontWeight.w600,
                borderRadius: BorderRadius.circular(
                  responsive.extraLargeBorderRadius,
                ),
                isLoading: controller.isLoading,
                onTap: isButtonEnabled ? () => controller.confirmOrder() : null,
                color: AppColor.appPrimary,
              ),
              SizedBox(height: responsive.spacing10),
              text(
                text:
                    'If you wish to cancel your order, please do so within 40 minutes of placing it to avoid any charges.',
                size: responsive.fontSize12,
                fontWeight: FontWeight.w400,
                color: AppColor.black.withOpacity(0.6),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  // ============ VALIDATION HELPERS ============
  bool _isAllFieldsValid(OrderConfirmationController controller) {
    if (controller.isDelivery()) {
      if (controller.fullNameController.text.trim().isEmpty) return false;
      if (controller.phoneController.text.trim().isEmpty) return false;
      if (controller.addressController.text.trim().isEmpty) return false;
      return true;
    }

    if (controller.isDineIn()) {
      if (controller.guestCountController.text.trim().isEmpty) return false;
      final guestCount = int.tryParse(
        controller.guestCountController.text.trim(),
      );
      if (guestCount == null ||
          guestCount < OrderConfirmationController.minGuests ||
          guestCount > OrderConfirmationController.maxGuests) {
        return false;
      }
      if (!controller.isTimeValid()) return false;
      return true;
    }

    if (controller.isTakeaway()) {
      if (!controller.isTimeValid()) return false;
      return true;
    }

    if (controller.isCarDineIn()) {
      if (!controller.isTimeValid()) return false;
      if (controller.vehicleDetailsController.text.trim().isEmpty) return false;
      return true;
    }

    return true;
  }

  String _getValidationErrorMessage(OrderConfirmationController controller) {
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

    if (controller.isDineIn()) {
      if (controller.guestCountController.text.trim().isEmpty) {
        return 'Please enter number of guests';
      }
      final guestCount = int.tryParse(
        controller.guestCountController.text.trim(),
      );
      if (guestCount == null ||
          guestCount < OrderConfirmationController.minGuests ||
          guestCount > OrderConfirmationController.maxGuests) {
        return 'Please enter valid number of guests (1-30)';
      }
      if (!controller.isTimeValid()) {
        return controller.timeErrorMessage ?? 'Please select a valid time';
      }
      return 'Please fill in all required fields';
    }

    if (controller.isTakeaway()) {
      if (!controller.isTimeValid()) {
        return controller.timeErrorMessage ??
            'Please select a valid pickup time';
      }
      return 'Please fill in all required fields';
    }

    if (controller.isCarDineIn()) {
      if (!controller.isTimeValid()) {
        return controller.timeErrorMessage ?? 'Please select a valid time';
      }
      if (controller.vehicleDetailsController.text.trim().isEmpty) {
        return 'Please enter your vehicle details';
      }
      return 'Please fill in all required fields';
    }

    return 'Please fill in all required fields';
  }
}
