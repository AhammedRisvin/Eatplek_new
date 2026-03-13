import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
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
    // ── Skeleton initial load ─────────────────────────────────────────────
    if (controller.isInitialLoadingForTab(tabIndex)) {
      return _buildSkeletonList();
    }

    // ── Error state ───────────────────────────────────────────────────────
    if (controller.hasErrorForTab(tabIndex)) {
      return _buildErrorState();
    }

    // ── Empty state ───────────────────────────────────────────────────────
    if (controller.isEmptyForTab(tabIndex)) {
      return _buildEmptyState();
    }

    final orders = controller.ordersForTab(tabIndex);

    return ListView.builder(
      controller: controller.scrollControllers[tabIndex],
      padding: EdgeInsets.zero,
      itemCount:
          orders.length + (controller.isLoadingMoreForTab(tabIndex) ? 1 : 0),
      itemBuilder: (context, index) {
        // Bottom load-more indicator
        if (index == orders.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          );
        }

        final order = orders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOrderCard(order),
        );
      },
    );
  }

  // ─── Order Card ───────────────────────────────────────────────────────────
  Widget _buildOrderCard(SingleOrder order) {
    final vendor = order.vendor;
    final cartSnapshot = order.cartSnapshot;
    final items = cartSnapshot?.items ?? [];
    final firstItem = items.isNotEmpty ? items.first : null;
    final totals = cartSnapshot?.totals ?? order.amountSummary;

    return Container(
      width: Get.width,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hotel / Vendor header ────────────────────────────────────────
          Row(
            children: [
              SvgPicture.string(hotelNameSvg),
              const SizedBox(width: 10),
              text(
                text: vendor?.name ?? 'Restaurant',
                size: 14,
                fontWeight: FontWeight.w500,
                color: AppColor.black,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Item image + details ─────────────────────────────────────────
          Row(
            children: [
              // Food image
              image(
                url: firstItem?.foodImage ?? '',
                height: 80,
                width: 80,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + quantity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: text(
                            text: firstItem?.foodName ?? '—',
                            size: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.black,
                            maxLines: 2,
                            overFlow: TextOverflow.ellipsis,
                          ),
                        ),
                        text(
                          text: 'QTY : ${firstItem?.quantity ?? 1}',
                          size: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColor.black.withOpacity(0.6),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Food type / category
                    text(
                      text: firstItem?.foodType ?? '',
                      size: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColor.black.withOpacity(0.6),
                    ),

                    // Price + Status badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        text(
                          text: 'Rs.${totals?.grandTotal ?? 0}',
                          size: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColor.black,
                        ),
                        _buildStatusBadge(order.orderStatus ?? 'Pending'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Dotted divider ───────────────────────────────────────────────
          SizedBox(
            height: 1,
            width: double.infinity,
            child: CustomPaint(
              painter: DottedLinePainter(
                color: AppColor.black.withOpacity(0.1),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Add-ons / customizations count ───────────────────────────────
          _buildAddOnsSection(firstItem),
          const SizedBox(height: 16),

          // ── Action button ────────────────────────────────────────────────
          _buildActionButton(order),

          // ── Waiting text for pending orders ──────────────────────────────
          if (_isPending(order.orderStatus)) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: text(
                text: 'Waiting for Restaurant Confirmation...',
                size: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: AppColor.appPrimary.withOpacity(0.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          text(
            text: 'Status : ',
            size: 12,
            fontWeight: FontWeight.w500,
            color: AppColor.black,
          ),
          text(
            text: _formatStatus(status),
            size: 12,
            fontWeight: FontWeight.w500,
            color: AppColor.appPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnsSection(Item? item) {
    final addOnCount =
        (item?.addOns?.length ?? 0) + (item?.customizations?.length ?? 0);
    return text(
      text: 'Add Ons ($addOnCount)',
      size: 16,
      fontWeight: FontWeight.w600,
      color: AppColor.black,
    );
  }

  Widget _buildActionButton(SingleOrder order) {
    final isPending = _isPending(order.orderStatus);
    return button(
      name: isPending ? 'Refresh' : 'View Details',
      onTap: () {
        if (!isPending) {
          controller.viewOrderDetails(order);
        }
      },
      height: 43,
      borderRadius: BorderRadius.circular(6),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  bool _isPending(String? status) {
    return status?.toLowerCase() == 'pending';
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  // ── Skeleton (Skeletonizer) ───────────────────────────────────────────────
  Widget _buildSkeletonList() {
    return Skeletonizer(
      enabled: true,
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vendor row
          Row(
            children: [
              Container(width: 20, height: 20, color: Colors.grey[300]),
              const SizedBox(width: 10),
              Container(width: 120, height: 14, color: Colors.grey[300]),
            ],
          ),
          const SizedBox(height: 16),
          // Item row
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Container(width: 100, height: 12, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 60,
                          height: 18,
                          color: Colors.grey[300],
                        ),
                        Container(
                          width: 100,
                          height: 32,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Container(width: 100, height: 16, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          text(
            text: 'Something went wrong',
            size: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.black.withOpacity(0.7),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: text(
              text: controller.errorMessageForTab(tabIndex),
              size: 14,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          button(
            name: 'Retry',
            width: Get.width * 0.5,
            height: 46,
            fontWeight: FontWeight.w600,
            borderRadius: BorderRadius.circular(100),
            onTap: () => controller.retryFetch(tabIndex),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 72,
            color: AppColor.black.withOpacity(0.15),
          ),
          const SizedBox(height: 16),
          text(
            text: 'No Orders Yet',
            size: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.black.withOpacity(0.6),
          ),
          const SizedBox(height: 8),
          text(
            text: 'Your orders will appear here once placed.',
            size: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}
