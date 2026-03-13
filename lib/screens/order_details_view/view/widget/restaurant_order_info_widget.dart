import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../core/util/app_color.dart';
import '../../../../../core/util/assets.dart';
import '../../../../../core/util/common_widgets.dart';
import '../../../orders/model/orders_api_model.dart';
import '../../controller/order_details_controller.dart';

class RestaurantAndOrderInfoSection extends StatelessWidget {
  final SingleOrder order;

  const RestaurantAndOrderInfoSection({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final vendor = order.vendor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 10),
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
          text(
            text: 'Restaurant & Order Info',
            size: 18,
            fontWeight: FontWeight.w600,
          ),
          18.h,

          // ── Vendor row ─────────────────────────────────────────────────
          Row(
            children: [
              // Vendor icon placeholder (no image in Vendor model)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColor.appPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.store_outlined,
                    color: AppColor.appPrimary,
                    size: 24,
                  ),
                ),
              ),
              14.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      text: vendor?.name ?? '—',
                      size: 14,
                      fontWeight: FontWeight.w500,
                      maxLines: 2,
                      overFlow: TextOverflow.ellipsis,
                    ),
                    if (order.serviceDetails?.address != null) ...[
                      4.h,
                      text(
                        text: order.serviceDetails!.address.toString(),
                        size: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColor.black.withOpacity(0.4),
                        maxLines: 2,
                        overFlow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Message + Call — only shown if phone is available
              if (order.serviceDetails?.phoneNumber != null) ...[
                GetBuilder<OrderDetailsController>(
                  builder:
                      (ctrl) => GestureDetector(
                        onTap:
                            () => ctrl.sendSMS(
                              order.serviceDetails!.phoneNumber.toString(),
                            ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: SvgPicture.string(messageSvg),
                        ),
                      ),
                ),
                GetBuilder<OrderDetailsController>(
                  builder:
                      (ctrl) => GestureDetector(
                        onTap:
                            () => ctrl.makePhoneCall(
                              order.serviceDetails!.phoneNumber.toString(),
                            ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: SvgPicture.string(callSvg),
                        ),
                      ),
                ),
              ],
            ],
          ),
          20.h,

          // ── Order ID ───────────────────────────────────────────────────
          _buildInfoRow('Order ID', order.id ?? '—'),
          14.h,

          // ── Order Date & Time ──────────────────────────────────────────
          GetBuilder<OrderDetailsController>(
            builder:
                (ctrl) => _buildInfoRow(
                  'Order Date & Time',
                  ctrl.getFormattedOrderDateTime(),
                ),
          ),
          14.h,

          // ── Service Type ───────────────────────────────────────────────
          _buildInfoRow(
            'Service Type',
            _formatServiceType(order.serviceType ?? ''),
          ),
          14.h,

          // ── Payment Status ─────────────────────────────────────────────
          _buildInfoRow(
            'Payment',
            [
              order.paymentStatus,
              order.paymentDetails?.paymentMethod?.toString(),
            ].where((v) => v != null && v.toString().isNotEmpty).join(' · '),
          ),

          // ── Pickup / reach time (takeaway / dine-in) ───────────────────
          if (order.serviceDetails?.reachTime != null) ...[
            14.h,
            _buildInfoRow(
              'Reach Time',
              _formatDateTime(order.serviceDetails!.reachTime),
            ),
          ],

          // ── Notes ──────────────────────────────────────────────────────
          if (order.notes != null && order.notes.toString().isNotEmpty) ...[
            14.h,
            _buildInfoRow('Notes', order.notes.toString()),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(
          text: label,
          size: 14,
          fontWeight: FontWeight.w400,
          color: AppColor.black.withOpacity(0.6),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: text(
            text: value.isEmpty ? '—' : value,
            size: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.black,
            textAlign: TextAlign.right,
            maxLines: 2,
            overFlow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatServiceType(String type) {
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    // e.g. "21-09-2025, 11:30 AM"
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$d-$mo-$y, $h:$min $ampm';
  }
}
