import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ShimmerEffect;
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:svg_flutter/svg.dart';

import '../../../cart/view/widget/dotted_line_painter.dart';
import '../../controller/orders_controller.dart';
import '../../model/orders_api_model.dart';

class OrdersList extends StatelessWidget {
  final OrdersController controller;
  final int tabIndex;

  const OrdersList({
    super.key,
    required this.controller,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.isInitialLoadingForTab(tabIndex)) {
      return _buildSkeletonList();
    }
    if (controller.hasErrorForTab(tabIndex)) {
      return errorState(
        message: controller.errorMessageForTab(tabIndex),
        onRetry: () => controller.retryFetch(tabIndex),
      );
    }
    if (controller.isEmptyForTab(tabIndex)) {
      return emptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No Orders Yet',
        subtitle: 'Your orders will appear here once placed.',
      );
    }

    final orders = controller.ordersForTab(tabIndex);

    return ListView.builder(
      controller: controller.scrollControllers[tabIndex],
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      itemCount:
          orders.length + (controller.isLoadingMoreForTab(tabIndex) ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == orders.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOrderCard(orders[index], index),
        );
      },
    );
  }

  Widget _buildOrderCard(SingleOrder order, int index) {
    final vendor = order.vendor;
    final items = order.cartSnapshot?.items ?? [];
    final firstItem = items.isNotEmpty ? items.first : null;
    final totals = order.cartSnapshot?.totals ?? order.amountSummary;

    return Container(
          width: Get.width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColor.black.withOpacity(0.04)),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.05),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Vendor name + status badge ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.string(hotelNameSvg, width: 16, height: 16),
                      const SizedBox(width: 8),
                      text(
                        text: vendor?.name ?? 'Restaurant',
                        size: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColor.black,
                      ),
                    ],
                  ),
                  statusBadge(order.orderStatus ?? 'Pending'),
                ],
              ),
              const SizedBox(height: 14),

              // ── Item image + details ───────────────────────────────────────
              Row(
                children: [
                  image(
                    url: firstItem?.foodImage ?? '',
                    height: 72,
                    width: 72,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text(
                          text: firstItem?.foodName ?? '—',
                          size: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColor.black,
                          maxLines: 2,
                          overFlow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (items.length > 1)
                          text(
                            text:
                                '+${items.length - 1} more item${items.length > 2 ? 's' : ''}',
                            size: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColor.black.withOpacity(0.45),
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            text(
                              text: '₹${totals?.grandTotal ?? 0}',
                              size: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColor.black,
                            ),
                            const SizedBox(width: 8),
                            text(
                              text:
                                  '· ${firstItem?.quantity ?? 1} item${(firstItem?.quantity ?? 1) > 1 ? 's' : ''}',
                              size: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColor.black.withOpacity(0.45),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Dotted divider ─────────────────────────────────────────────
              SizedBox(
                height: 1,
                width: double.infinity,
                child: CustomPaint(
                  painter: DottedLinePainter(
                    color: AppColor.black.withOpacity(0.1),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Action button ──────────────────────────────────────────────
              _buildActionButton(order),

              if (_isPending(order.orderStatus)) ...[
                const SizedBox(height: 8),
                Center(
                  child: text(
                    text: 'Waiting for restaurant confirmation...',
                    size: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColor.black.withOpacity(0.45),
                  ),
                ),
              ],
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fade(duration: 300.ms, curve: Curves.easeOut)
        .slideY(begin: 0.06, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildActionButton(SingleOrder order) {
    final isPending = _isPending(order.orderStatus);
    return button(
      name: isPending ? 'Refresh Status' : 'View Details',
      height: 44,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      borderRadius: BorderRadius.circular(10),
      color:
          isPending
              ? AppColor.appPrimary.withOpacity(0.08)
              : AppColor.appPrimary,
      borderColor:
          isPending
              ? AppColor.appPrimary.withOpacity(0.2)
              : AppColor.appPrimary,
      textColor: isPending ? AppColor.appPrimary : AppColor.white,
      onTap: () {
        if (!isPending) controller.viewOrderDetails(order);
      },
    );
  }

  bool _isPending(String? status) => status?.toLowerCase() == 'pending';

  // ── Skeleton ──────────────────────────────────────────────────────────────
  Widget _buildSkeletonList() {
    return Skeletonizer(
      enabled: true,
      effect: const ShimmerEffect(
        baseColor: Color(0xFFEEEEEE),
        highlightColor: Color(0xFFF8F8F8),
        duration: Duration(milliseconds: 1200),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 4,
        itemBuilder:
            (_, __) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSkeletonCard(),
            ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColor.black.withOpacity(0.04), blurRadius: 16),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 70,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, color: Colors.grey.shade200),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 12,
                      color: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 60,
                      height: 16,
                      color: Colors.grey.shade200,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 14),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
