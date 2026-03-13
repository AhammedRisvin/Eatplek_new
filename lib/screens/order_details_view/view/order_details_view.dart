import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../../core/util/common_widgets.dart';
import '../../cart/view/widget/price_summary_widget.dart';
import '../../orders/model/orders_api_model.dart';
import '../controller/order_details_controller.dart';
import 'widget/restaurant_order_info_widget.dart';
import 'widget/track_preperation_widget.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderDetailsController>(
      init: OrderDetailsController(),
      id: 'order_details',
      builder: (controller) {
        final order = controller.order;

        return Scaffold(
          backgroundColor: AppColor.scaffoldColor,
          appBar: _buildAppBar(context),
          body:
              order == null
                  ? _buildNoOrder(controller)
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Tracking steps ─────────────────────────────────
                        TrackPreparationWidget(
                          steps: controller.trackingSteps,
                          vendorName: order.vendor?.name ?? '',
                          onTrackTap: null, // extend later if needed
                        ),

                        // ── Estimated time banner (delivery only) ──────────
                        if (order.serviceType == 'delivery' &&
                            order.serviceDetails?.reachTime != null)
                          _buildTimeEstimateBanner(
                            order.serviceDetails!.reachTime!,
                          ),

                        // ── Restaurant & order info ─────────────────────────
                        RestaurantAndOrderInfoSection(order: order),

                        // ── Pickup note for takeaway ────────────────────────
                        if (order.serviceType == 'takeaway') ...[
                          text(
                            text:
                                'Please show your order ID at the counter to collect your food.',
                            size: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColor.black.withOpacity(0.6),
                          ),
                          10.h,
                        ],

                        // ── Cart items ──────────────────────────────────────
                        _buildCartItemsSection(controller),

                        // ── Additional notes ────────────────────────────────
                        if (order.notes != null &&
                            order.notes.toString().isNotEmpty)
                          _buildAdditionalNotesCard(order.notes.toString()),

                        // ── Price summary ───────────────────────────────────
                        PriceSummaryWidget(
                          subtotal: controller.subTotal,
                          deliveryFee: null,
                          taxAmount: controller.taxAmount,
                          packingCharge: controller.packingCharge,
                          promoDiscount:
                              controller.couponDiscount > 0
                                  ? controller.couponDiscount
                                  : controller.discountTotal,
                          totalAmount: controller.grandTotal,
                        ),

                        // Bottom nav breathing room
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          bottomNavigationBar:
              order == null
                  ? const SizedBox.shrink()
                  : _buildBottomBar(context, controller),
        );
      },
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColor.scaffoldColor,
      centerTitle: true,
      leadingWidth: 80,
      title: text(text: 'Order Details', size: 18, fontWeight: FontWeight.w600),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
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

  // ── Delivery time banner ──────────────────────────────────────────────────
  Widget _buildTimeEstimateBanner(DateTime reachTime) {
    final now = DateTime.now();
    final diff = reachTime.difference(now);
    final minsLeft = diff.inMinutes;
    final label = minsLeft > 0 ? 'Arriving in $minsLeft mins' : 'Arriving soon';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 10),
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
              text: 'Estimated Delivery Time: $label',
              fontWeight: FontWeight.w500,
              size: 14,
              color: AppColor.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Cart items card ───────────────────────────────────────────────────────
  Widget _buildCartItemsSection(OrderDetailsController controller) {
    final items = controller.getCartItems();
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03), width: 1),
        boxShadow: [
          BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(text: 'Order Items', size: 18, fontWeight: FontWeight.w600),
          16.h,
          ...items.map((item) => _buildItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildItemRow(Item item) {
    final addOnCount =
        (item.addOns?.length ?? 0) + (item.customizations?.length ?? 0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          image(
            url: item.foodImage ?? '',
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(10),
          ),
          14.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(
                  text: item.foodName ?? '—',
                  size: 14,
                  fontWeight: FontWeight.w500,
                  maxLines: 2,
                  overFlow: TextOverflow.ellipsis,
                ),
                if (addOnCount > 0) ...[
                  4.h,
                  text(
                    text: 'Add-ons ($addOnCount)',
                    size: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColor.black.withOpacity(0.5),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              text(
                text: 'x${item.quantity ?? 1}',
                size: 13,
                fontWeight: FontWeight.w500,
                color: AppColor.black.withOpacity(0.5),
              ),
              4.h,
              text(
                text: 'Rs.${item.itemTotal ?? item.effectivePrice ?? 0}',
                size: 14,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Additional notes card ─────────────────────────────────────────────────
  Widget _buildAdditionalNotesCard(String notes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03), width: 1),
        boxShadow: [
          BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          text(text: 'Additional Notes', size: 18, fontWeight: FontWeight.w600),
          10.h,
          text(
            text: notes,
            size: 13,
            fontWeight: FontWeight.w300,
            color: AppColor.black.withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  // ── No order / error state ────────────────────────────────────────────────
  Widget _buildNoOrder(OrderDetailsController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColor.black.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          text(
            text: 'Order details not available',
            size: 16,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar(
    BuildContext context,
    OrderDetailsController controller,
  ) {
    final canCancel = controller.canCancel;

    return Container(
      width: double.infinity,
      color: AppColor.scaffoldColor,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            name: 'Cancel Order',
            width: double.infinity,
            fontSize: 18,
            height: 60,
            fontWeight: FontWeight.w600,
            borderRadius: BorderRadius.circular(100),
            onTap: canCancel ? controller.cancelOrder : null,
            color:
                canCancel
                    ? const Color(0xFFFE6308).withOpacity(0.1)
                    : AppColor.black.withOpacity(0.1),
            borderColor:
                canCancel
                    ? const Color(0xFFFE6308).withOpacity(0.1)
                    : AppColor.black.withOpacity(0.1),
            textColor:
                canCancel
                    ? const Color(0xFFFE6308)
                    : AppColor.black.withOpacity(0.4),
          ),
          10.h,
          text(
            text:
                canCancel
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
  }
}
