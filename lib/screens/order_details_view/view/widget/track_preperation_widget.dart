import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';

import '../../../../../core/util/app_color.dart';
import '../../../../../core/util/common_widgets.dart';
import '../../../orders/model/orders_api_model.dart';

class TrackPreparationWidget extends StatelessWidget {
  final List<TrackingStep> steps;
  final String vendorName;
  final VoidCallback? onTrackTap;

  const TrackPreparationWidget({
    super.key,
    required this.steps,
    required this.vendorName,
    this.onTrackTap,
  });

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      text: 'Track Preparation',
                      size: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    6.h,
                    text(
                      text: 'Real-time updates on your order status.',
                      size: 13,
                      fontWeight: FontWeight.w300,
                      color: AppColor.black.withOpacity(0.55),
                    ),
                  ],
                ),
              ),
              if (onTrackTap != null)
                button(
                  name: 'Track',
                  onTap: onTrackTap!,
                  width: 70,
                  height: 35,
                  borderRadius: BorderRadius.circular(60),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
            ],
          ),

          if (steps.isNotEmpty) ...[
            20.h,
            // ── Tracking steps ─────────────────────────────────────────────
            ...List.generate(steps.length, (i) {
              final step = steps[i];
              final isLast = i == steps.length - 1;
              return _buildStep(step, isLast: isLast);
            }),
          ],

          20.h,
          // ── Map placeholder ─────────────────────────────────────────────
          // NOTE FOR BACKEND: The Vendor model currently only returns
          // { id, name, gstPercentage }. To enable live map tracking here,
          // please include vendor/restaurant latitude & longitude in the
          // order details response (e.g. under `vendor.latitude` and
          // `vendor.longitude`).
          _buildMapPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        color: AppColor.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.black.withOpacity(0.06), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 28,
            color: AppColor.black.withOpacity(0.25),
          ),
          const SizedBox(height: 8),
          text(
            text: 'Live map not available',
            size: 13,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.35),
          ),
          const SizedBox(height: 4),
          text(
            text: 'Waiting for location data from server',
            size: 11,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.25),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(TrackingStep step, {required bool isLast}) {
    final isCompleted = step.completed ?? false;
    final isActive = step.active ?? false;

    // Dot colour
    final Color dotColor =
        isCompleted || isActive
            ? AppColor.appPrimary
            : AppColor.black.withOpacity(0.15);

    // Line colour
    final Color lineColor =
        isCompleted ? AppColor.appPrimary : AppColor.black.withOpacity(0.1);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline column ──────────────────────────────────────────────
          SizedBox(
            width: 24,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    border: Border.all(
                      color:
                          isActive && !isCompleted
                              ? AppColor.appPrimary
                              : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child:
                      isCompleted
                          ? const Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white,
                          )
                          : isActive
                          ? Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          )
                          : null,
                ),
                // Vertical line (except last step)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Step content ─────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text(
                    text: step.label ?? _formatStatus(step.status ?? ''),
                    size: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isActive
                            ? AppColor.appPrimary
                            : isCompleted
                            ? AppColor.black
                            : AppColor.black.withOpacity(0.4),
                  ),
                  if (step.description != null &&
                      step.description!.isNotEmpty) ...[
                    4.h,
                    text(
                      text: step.description!,
                      size: 12,
                      fontWeight: FontWeight.w300,
                      color: AppColor.black.withOpacity(0.5),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
