import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:svg_flutter/svg.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../controller/order_confirmation_controller.dart';
import 'widget/address_section.dart';
import 'widget/delivery_date_bottom_sheet.dart';
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
  final controller = Get.put(OrderConfirmationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        title: text(text: 'Order Confirmation', size: 18, fontWeight: FontWeight.w600),
        leading: GestureDetector(
          onTap: () => Get.back(),
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
              RestaurantWidgetFromOrders(),
              DeliveryDateCalender(),
              AddressWidget(controller: controller),
              TimeSelectingWidget(controller: controller),
              NumberOfGuestWidget(controller: controller),
              OrderSummaryWidget(
                mainDishes: controller.getMainDishes(),
                addOns: controller.getAddOns(),
                totalAmount: controller.getTotalPrice(),
                title: 'Order Summary',
                showMainDishesSection: true,
                showAddOnsSection: true,
                showTotalSection: true,
                mainDishesTitle: 'Main Dishes',
                addOnsTitle: 'Add-ons',
                totalTitle: 'Total Amount',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: context.wp(100),
        color: AppColor.scaffoldColor,
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            button(
              name: 'Confirm Order',
              width: context.wp(100),
              fontSize: 18,
              height: 60,
              fontWeight: FontWeight.w600,
              borderRadius: BorderRadius.circular(100),
              onTap: controller.confirmOrder,
            ),
            10.h,
            text(
              text:
                  'If you wish to cancel your order, please do so within 40 minutes of placing it to avoid any charges.',
              size: 14,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
