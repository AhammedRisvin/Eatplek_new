import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../../core/util/common_widgets.dart';
import '../../../core/util/responsive_helper.dart';
import '../../../core/util/service_type.dart';
import '../../cart/view/widget/price_summary_widget.dart';
import '../../orders/model/orders_api_model.dart';
import '../controller/order_details_controller.dart';
import 'widget/restaurant_order_info_widget.dart';
import 'widget/track_preperation_widget.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GetBuilder<OrderDetailsController>(
      init: OrderDetailsController(),
      id: 'order_details',
      builder: (controller) {
        final order = controller.order;

        return Scaffold(
          backgroundColor: AppColor.scaffoldColor,
          appBar: _buildAppBar(context, responsive),
          body:
              order == null
                  ? emptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Order details not available',
                  )
                  : SingleChildScrollView(
                    padding: EdgeInsets.all(responsive.spacing16),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Tracking steps ───────────────────────────────
                        TrackPreparationWidget(
                              steps: controller.trackingSteps,
                              vendorName: order.vendor?.name ?? '',
                              onTrackTap: null,
                            )
                            .animate()
                            .fade(duration: 400.ms)
                            .slideY(begin: 0.05, end: 0, duration: 400.ms),

                        // ── Delivery time banner ─────────────────────────
                        if (ServiceType.same(
                              order.serviceType ?? '',
                              ServiceType.delivery,
                            ) &&
                            order.serviceDetails?.reachTime != null)
                          _buildTimeBanner(
                            order.serviceDetails!.reachTime!,
                            responsive,
                          ).animate().fade(duration: 350.ms, delay: 80.ms),

                        // ── Restaurant & order info ──────────────────────
                        RestaurantAndOrderInfoSection(
                          order: order,
                        ).animate().fade(duration: 350.ms, delay: 120.ms),

                        // ── Pickup note ──────────────────────────────────
                        if (ServiceType.same(
                          order.serviceType ?? '',
                          ServiceType.takeaway,
                        )) ...[
                          _buildPickupNote(
                            responsive,
                          ).animate().fade(duration: 350.ms, delay: 150.ms),
                          SizedBox(height: responsive.spacing10),
                        ],

                        // ── Cart items ───────────────────────────────────
                        _buildItemsCard(
                          controller,
                          responsive,
                        ).animate().fade(duration: 350.ms, delay: 180.ms),

                        // ── Additional notes ─────────────────────────────
                        if (order.notes?.toString().isNotEmpty ?? false)
                          _buildNotesCard(
                            order.notes.toString(),
                            responsive,
                          ).animate().fade(duration: 350.ms, delay: 210.ms),

                        // ── Price summary ────────────────────────────────
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
                          margin: EdgeInsets.only(bottom: responsive.spacing20),
                        ).animate().fade(duration: 350.ms, delay: 240.ms),
                      ],
                    ),
                  ),
          bottomNavigationBar:
              order == null
                  ? const SizedBox.shrink()
                  : _buildBottomBar(context, controller, responsive),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColor.scaffoldColor,
      centerTitle: true,
      leadingWidth: responsive.spacing80,
      title: text(
        text: 'Order Details',
        size: responsive.fontSize18,
        fontWeight: FontWeight.w700,
      ),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Container(
            width: responsive.spacing40,
            height: responsive.spacing40,
            padding: EdgeInsets.all(responsive.spacing10),
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
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SvgPicture.string(arrowBack2),
          ),
        ),
      ),
    );
  }

  // ── ETA banner ────────────────────────────────────────────────────────────
  Widget _buildTimeBanner(DateTime reachTime, ResponsiveHelper responsive) {
    final diff = reachTime.difference(DateTime.now()).inMinutes;
    final label = diff > 0 ? 'Arriving in $diff mins' : 'Arriving soon';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.spacing16),
      margin: EdgeInsets.only(bottom: responsive.spacing12),
      decoration: BoxDecoration(
        color: AppColor.appPrimary,
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColor.appPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.string(scooterSvg),
          SizedBox(width: responsive.spacing12),
          Expanded(
            child: text(
              text: 'Estimated Delivery: $label',
              fontWeight: FontWeight.w600,
              size: responsive.fontSize14,
              color: AppColor.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Pickup note ───────────────────────────────────────────────────────────
  Widget _buildPickupNote(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing14),
      margin: EdgeInsets.only(bottom: responsive.spacing12),
      decoration: BoxDecoration(
        color: AppColor.appPrimary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
        border: Border.all(color: AppColor.appPrimary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: responsive.fontSize16,
            color: AppColor.appPrimary,
          ),
          SizedBox(width: responsive.spacing10),
          Expanded(
            child: text(
              text:
                  'Please show your order ID at the counter to collect your food.',
              size: responsive.fontSize12,
              fontWeight: FontWeight.w400,
              color: AppColor.appPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // ── Order items card ──────────────────────────────────────────────────────
  Widget _buildItemsCard(
    OrderDetailsController controller,
    ResponsiveHelper responsive,
  ) {
    final items = controller.getCartItems();
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.spacing20),
      margin: EdgeInsets.only(bottom: responsive.spacing12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        border: Border.all(color: AppColor.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fastfood_rounded,
                size: responsive.fontSize16,
                color: AppColor.appPrimary,
              ),
              SizedBox(width: responsive.spacing8),
              text(
                text: 'Order Items',
                size: responsive.fontSize16,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          SizedBox(height: responsive.spacing16),
          ...items.map((item) => _buildItemRow(item, responsive)),
        ],
      ),
    );
  }

  Widget _buildItemRow(Item item, ResponsiveHelper responsive) {
    final addOnCount =
        (item.addOns?.length ?? 0) + (item.customizations?.length ?? 0);

    return Padding(
      padding: EdgeInsets.only(bottom: responsive.spacing14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
            child: image(
              url: item.foodImage ?? '',
              width: responsive.spacing55,
              height: responsive.spacing55,
            ),
          ),
          SizedBox(width: responsive.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(
                  text: item.foodName ?? '—',
                  size: responsive.fontSize13,
                  fontWeight: FontWeight.w500,
                  maxLines: 2,
                  overFlow: TextOverflow.ellipsis,
                ),
                if (addOnCount > 0) ...[
                  SizedBox(height: responsive.spacing3),
                  text(
                    text: '$addOnCount add-on${addOnCount > 1 ? 's' : ''}',
                    size: responsive.fontSize11,
                    fontWeight: FontWeight.w400,
                    color: AppColor.black.withOpacity(0.45),
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
                size: responsive.fontSize12,
                fontWeight: FontWeight.w500,
                color: AppColor.black.withOpacity(0.45),
              ),
              SizedBox(height: responsive.spacing3),
              text(
                text: 'Rs.${item.itemTotal ?? item.effectivePrice ?? 0}',
                size: responsive.fontSize13,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Additional notes ──────────────────────────────────────────────────────
  Widget _buildNotesCard(String notes, ResponsiveHelper responsive) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.spacing16),
      margin: EdgeInsets.only(bottom: responsive.spacing12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        border: Border.all(color: AppColor.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                size: responsive.fontSize16,
                color: AppColor.appPrimary,
              ),
              SizedBox(width: responsive.spacing8),
              text(
                text: 'Additional Notes',
                size: responsive.fontSize15,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          SizedBox(height: responsive.spacing10),
          text(
            text: notes,
            size: responsive.fontSize13,
            fontWeight: FontWeight.w300,
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
    ResponsiveHelper responsive,
  ) {
    final canCancel = controller.canCancel;

    return Container(
      color: AppColor.scaffoldColor,
      padding: EdgeInsets.fromLTRB(
        responsive.spacing20,
        responsive.spacing16,
        responsive.spacing20,
        responsive.spacing20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            name: 'Cancel Order',
            width: double.infinity,
            fontSize: responsive.fontSize16,
            height: responsive.buttonHeight,
            fontWeight: FontWeight.w600,
            borderRadius: BorderRadius.circular(responsive.spacing100),
            onTap: canCancel ? controller.cancelOrder : null,
            color:
                canCancel
                    ? const Color(0xFFFE6308).withOpacity(0.1)
                    : AppColor.black.withOpacity(0.06),
            borderColor:
                canCancel
                    ? const Color(0xFFFE6308).withOpacity(0.1)
                    : AppColor.black.withOpacity(0.06),
            textColor:
                canCancel
                    ? const Color(0xFFFE6308)
                    : AppColor.black.withOpacity(0.35),
          ),
          SizedBox(height: responsive.spacing8),
          text(
            text:
                canCancel
                    ? 'Cancellation allowed before restaurant accepts your order.'
                    : 'Order cannot be cancelled at this time.',
            size: responsive.fontSize12,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
