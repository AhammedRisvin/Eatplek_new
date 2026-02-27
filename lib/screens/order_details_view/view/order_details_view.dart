import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../../core/util/common_widgets.dart';
import '../../cart/view/widget/price_summary_widget.dart';
import '../../order_confirmation_view/view/widget/order_summary_widget.dart';
import '../controller/order_details_controller.dart';
import 'widget/mini_map_widget.dart';
import 'widget/restaurant_order_info_widget.dart';

class OrderDetailsView extends StatefulWidget {
  const OrderDetailsView({super.key});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: GetBuilder<OrderDetailsController>(
        id: 'loading',
        init: OrderDetailsController(),
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.order == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load order details'),
                  ElevatedButton(
                    onPressed: controller.refreshOrder,
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GetBuilder<OrderDetailsController>(
                  id: 'order_details',
                  builder:
                      (controller) => MiniMapWidget(
                        restaurant: controller.order!.restaurant,
                        onMapTap: controller.openGoogleMaps,
                        onTrackTap: controller.trackOrder,
                      ),
                ),
                GetBuilder<OrderDetailsController>(
                  id: 'order_details',
                  builder:
                      (controller) => _buildTimeEstimate(
                        controller.order!.estimatedDeliveryTime,
                      ),
                ),
                GetBuilder<OrderDetailsController>(
                  id: 'order_details',
                  builder:
                      (controller) => RestaurantAndOrderInfoSection(
                        order: controller.order!,
                        onCallTap: controller.makePhoneCall,
                        onMessageTap: controller.sendSMS,
                      ),
                ),
                text(
                  text:
                      'Please show your order ID at the counter to collect your food.',
                  size: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColor.black.withOpacity(0.6),
                ),
                10.h,
                GetBuilder<OrderDetailsController>(
                  id: 'order_details',
                  builder: (controller) {
                    return ResponsiveOrderSummaryWidget(
                      mainDishes: controller.getMainDishes(),
                      addOns: controller.getAddOns(),
                      totalAmount: controller.getTotalPrice(),
                      title: 'Order Items',
                      showMainDishesSection: true,
                      showAddOnsSection: true,
                      showTotalSection: true,
                      mainDishesTitle: 'Main Dishes',
                      addOnsTitle: 'Add-ons',
                      totalTitle: 'Total Amount',
                    );
                  },
                ),
                GetBuilder<OrderDetailsController>(
                  id: 'order_details',
                  builder:
                      (controller) => _buildAdditionalInfo(
                        controller.order!.additionalNotes,
                      ),
                ),
                GetBuilder<OrderDetailsController>(
                  id: 'order_details',
                  builder: (controller) {
                    final pricing = controller.order!.pricingDetails;
                    return PriceSummaryWidget(
                      subtotal: pricing.subtotal,
                      deliveryFee: pricing.deliveryFee,
                      taxAmount: pricing.taxAmount,
                      packingCharge: pricing.packingCharge,
                      promoDiscount: pricing.promoDiscount,
                      // appliedPromoCode: controller.order!.promoCode,
                      totalAmount: pricing.totalAmount,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: GetBuilder<OrderDetailsController>(
        id: 'order_details',
        builder: (controller) {
          if (controller.order == null) return const SizedBox.shrink();

          return Container(
            width: context.wp(100),
            color: AppColor.scaffoldColor,
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                button(
                  name: 'Cancel Order',
                  width: context.wp(100),
                  fontSize: 18,
                  height: 60,
                  fontWeight: FontWeight.w600,
                  borderRadius: BorderRadius.circular(100),
                  onTap:
                      controller.order!.canCancel
                          ? controller.cancelOrder
                          : null,
                  color:
                      controller.order!.canCancel
                          ? Color(0Xfffe6308).withOpacity(0.1)
                          : AppColor.black.withOpacity(0.1),
                  borderColor:
                      controller.order!.canCancel
                          ? Color(0Xfffe6308).withOpacity(0.1)
                          : AppColor.black.withOpacity(0.1),
                  textColor:
                      controller.order!.canCancel
                          ? Color(0Xfffe6308)
                          : AppColor.black.withOpacity(0.4),
                ),
                10.h,
                text(
                  text:
                      controller.order!.canCancel
                          ? 'Cancellation is allowed only before the restaurant accepts your order.'
                          : 'Order cannot be cancelled at this time.',
                  size: 14,
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

  Widget _buildAdditionalInfo(String? additionalNotes) {
    if (additionalNotes == null || additionalNotes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(text: 'Additional Notes', size: 18, fontWeight: FontWeight.w600),
          10.h,
          text(
            text: additionalNotes,
            size: 13,
            fontWeight: FontWeight.w300,
            color: AppColor.black.withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeEstimate(String estimatedTime) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.appPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SvgPicture.string(scooterSvg),
          14.w,
          Expanded(
            child: text(
              text: 'Estimated Delivery Time: $estimatedTime',
              fontWeight: FontWeight.w500,
              size: 14,
              color: AppColor.white,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final bg = AppColor.scaffoldColor;

    return AppBar(
      elevation: 0,
      backgroundColor: bg,
      centerTitle: true,
      leadingWidth: 80,
      title: text(text: 'Order Details', size: 18, fontWeight: FontWeight.w600),
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.white,
              border: Border.all(
                color: Colors.black.withOpacity(0.06),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: SvgPicture.string(arrowBack2),
          ),
        ),
      ),
    );
  }
}
