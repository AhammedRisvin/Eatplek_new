import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';
import '../../model/invite_model.dart';

class InviteBottomSheet extends StatefulWidget {
  final InviteData invite;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const InviteBottomSheet({
    super.key,
    required this.invite,
    required this.onAccept,
    required this.onDecline,
  });

  static void show({
    required InviteData invite,
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
    Get.bottomSheet(
      InviteBottomSheet(
        invite: invite,
        onAccept: onAccept,
        onDecline: onDecline,
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  @override
  State<InviteBottomSheet> createState() => _InviteBottomSheetState();
}

class _InviteBottomSheetState extends State<InviteBottomSheet> {
  bool _isLoading = false;

  void _handleAccept() {
    setState(() => _isLoading = true);
    widget.onAccept();
  }

  void _handleDecline() {
    setState(() => _isLoading = true);
    widget.onDecline();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final inviterName = widget.invite.inviter?.name ?? 'Someone';
    final vendorName = widget.invite.vendor?.name ?? 'a restaurant';
    final serviceType = widget.invite.cart?.serviceType ?? '';
    final itemCount = widget.invite.cart?.itemCount ?? 0;
    final grandTotal = widget.invite.cart?.grandTotal ?? 0;

    return Container(
      width: responsive.screenWidth,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        color: AppColor.scaffoldColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Gradient header ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            height: responsive.screenHeight * 0.22,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Get.theme.primaryColor.withOpacity(0.15),
                  AppColor.scaffoldColor,
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: responsive.spacing80,
                height: responsive.spacing80,
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.group_rounded,
                  color: Get.theme.primaryColor,
                  size: responsive.spacing40,
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.spacing24),
            child: Column(
              children: [
                // Title
                text(
                  text: 'Order Invitation Received',
                  size: responsive.fontSize20,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: responsive.spacing8),

                // Subtitle — "Akshar Kannur has invited you..."
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: inviterName,
                        style: TextStyle(
                          fontSize: responsive.fontSize14,
                          fontWeight: FontWeight.w600,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                      TextSpan(
                        text: ' has invited you to join their food order.',
                        style: TextStyle(
                          fontSize: responsive.fontSize14,
                          fontWeight: FontWeight.w400,
                          color: AppColor.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: responsive.spacing20),

                // ── Cart info card ────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(responsive.spacing16),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(
                      responsive.largeBorderRadius,
                    ),
                    border: Border.all(color: AppColor.black.withOpacity(0.06)),
                  ),
                  child: Column(
                    children: [
                      _infoRow(
                        responsive,
                        icon: Icons.storefront_rounded,
                        label: 'Restaurant',
                        value: vendorName,
                      ),
                      if (serviceType.isNotEmpty) ...[
                        Divider(
                          color: AppColor.black.withOpacity(0.06),
                          height: responsive.spacing20,
                        ),
                        _infoRow(
                          responsive,
                          icon: Icons.receipt_long_rounded,
                          label: 'Service',
                          value: serviceType,
                        ),
                      ],
                      if (itemCount > 0) ...[
                        Divider(
                          color: AppColor.black.withOpacity(0.06),
                          height: responsive.spacing20,
                        ),
                        _infoRow(
                          responsive,
                          icon: Icons.shopping_bag_outlined,
                          label: 'Items',
                          value: '$itemCount item${itemCount > 1 ? 's' : ''}',
                        ),
                      ],
                      if (grandTotal > 0) ...[
                        Divider(
                          color: AppColor.black.withOpacity(0.06),
                          height: responsive.spacing20,
                        ),
                        _infoRow(
                          responsive,
                          icon: Icons.currency_rupee_rounded,
                          label: 'Total so far',
                          value: '₹${grandTotal.toStringAsFixed(0)}',
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: responsive.spacing24),

                // ── Buttons / Loading ─────────────────────────────────
                if (_isLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: responsive.spacing12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: responsive.spacing20,
                          height: responsive.spacing20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Get.theme.primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(width: responsive.spacing12),
                        text(
                          text: 'Please wait...',
                          size: responsive.fontSize14,
                          fontWeight: FontWeight.w500,
                          color: AppColor.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      // Decline
                      Expanded(
                        child: GestureDetector(
                          onTap: _handleDecline,
                          child: Container(
                            height: responsive.buttonHeight,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0EE),
                              borderRadius: BorderRadius.circular(
                                responsive.spacing40,
                              ),
                            ),
                            child: Center(
                              child: text(
                                text: 'Decline Invitation',
                                size: responsive.fontSize14,
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: responsive.spacing12),

                      // Accept
                      Expanded(
                        child: button(
                          name: 'Accept Order',
                          width: double.infinity,
                          fontSize: responsive.fontSize14,
                          height: responsive.buttonHeight,
                          fontWeight: FontWeight.w600,
                          borderRadius: BorderRadius.circular(
                            responsive.spacing40,
                          ),
                          onTap: _handleAccept,
                        ),
                      ),
                    ],
                  ),

                SizedBox(
                  height: responsive.bottomPadding + responsive.spacing20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    ResponsiveHelper responsive, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: responsive.spacing32,
          height: responsive.spacing32,
          decoration: BoxDecoration(
            color: Get.theme.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(responsive.spacing8),
          ),
          child: Icon(
            icon,
            size: responsive.spacing16,
            color: Get.theme.primaryColor,
          ),
        ),
        SizedBox(width: responsive.spacing12),
        Expanded(
          child: text(
            text: label,
            size: responsive.fontSize13,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.5),
          ),
        ),
        text(
          text: value,
          size: responsive.fontSize13,
          fontWeight: FontWeight.w600,
          color: AppColor.black,
        ),
      ],
    );
  }
}
