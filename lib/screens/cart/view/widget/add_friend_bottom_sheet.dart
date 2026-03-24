import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';
import '../../controller/cart_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ADD FRIEND BOTTOM SHEET  (Image 2)
// ─────────────────────────────────────────────────────────────────────────────

class AddFriendToCartBottomSheet extends StatefulWidget {
  const AddFriendToCartBottomSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const AddFriendToCartBottomSheet(),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  @override
  State<AddFriendToCartBottomSheet> createState() =>
      _AddFriendToCartBottomSheetState();
}

class _AddFriendToCartBottomSheetState
    extends State<AddFriendToCartBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();
  String _phoneError = '';
  bool _isSending = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool _validate() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _phoneError = 'Please enter a mobile number');
      return false;
    }
    if (phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      setState(() => _phoneError = 'Enter a valid 10-digit mobile number');
      return false;
    }
    setState(() => _phoneError = '');
    return true;
  }

  Future<void> _sendInvitation() async {
    if (!_validate()) return;

    setState(() => _isSending = true);

    final CartController cartController = Get.find<CartController>();
    final success = await cartController.sendInvite(
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (success) {
      // Close add friend sheet then show success sheet
      Navigator.of(Get.context!).pop();
      InvitationSentBottomSheet.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      width: responsive.screenWidth,
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: responsive.spacing20,
        right: responsive.spacing20,
        top: responsive.spacing16,
        bottom: responsive.spacing20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: responsive.spacing120,
              height: responsive.spacing4,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(
                  responsive.largeBorderRadius,
                ),
              ),
            ),
          ),
          SizedBox(height: responsive.spacing16),

          text(
            text: 'Add Friend to this Order',
            size: responsive.fontSize16,
            fontWeight: FontWeight.w700,
            color: AppColor.black,
          ),
          SizedBox(height: responsive.spacing4),
          text(
            text: 'Enter Friend\'s Registered Mobile Number',
            size: responsive.fontSize13,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.5),
          ),
          SizedBox(height: responsive.spacing20),

          // Phone input with +91 prefix
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildCommonTextFormField(
                context: context,
                controller: _phoneController,
                hintText: 'Enter Registered Number',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixIcon: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing12,
                    vertical: responsive.spacing14,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      text(
                        text: '+91',
                        size: responsive.fontSize14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.black,
                      ),
                      SizedBox(width: responsive.spacing8),
                      Container(
                        width: 1,
                        height: responsive.spacing20,
                        color: AppColor.black.withOpacity(0.15),
                      ),
                    ],
                  ),
                ),
                onChanged: (_) {
                  if (_phoneError.isNotEmpty) {
                    setState(() => _phoneError = '');
                  }
                },
              ),
              if (_phoneError.isNotEmpty) ...[
                SizedBox(height: responsive.spacing4),
                Padding(
                  padding: EdgeInsets.only(left: responsive.spacing4),
                  child: Text(
                    _phoneError,
                    style: TextStyle(
                      fontSize: responsive.fontSize12,
                      fontWeight: FontWeight.w400,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: responsive.spacing24),

          button(
            name: _isSending ? 'Sending...' : 'Send Invitation',
            width: responsive.screenWidth,
            fontSize: responsive.fontSize16,
            height: responsive.buttonHeight,
            fontWeight: FontWeight.w600,
            borderRadius: BorderRadius.circular(responsive.spacing40),
            onTap: _isSending ? null : _sendInvitation,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INVITATION SENT BOTTOM SHEET  (Image 3)
// ─────────────────────────────────────────────────────────────────────────────

class InvitationSentBottomSheet extends StatelessWidget {
  const InvitationSentBottomSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const InvitationSentBottomSheet(),
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      width: responsive.screenWidth,
      padding: EdgeInsets.only(
        left: responsive.spacing24,
        right: responsive.spacing24,
        top: responsive.spacing20,
        bottom: responsive.bottomPadding + responsive.spacing32,
      ),
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: responsive.spacing120,
            height: responsive.spacing4,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
            ),
          ),
          SizedBox(height: responsive.spacing32),

          // Success icon
          Container(
            width: responsive.spacing80,
            height: responsive.spacing80,
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: Get.theme.primaryColor,
              size: responsive.spacing40,
            ),
          ),
          SizedBox(height: responsive.spacing20),

          text(
            text: 'Invitation sent successfully',
            size: responsive.fontSize18,
            fontWeight: FontWeight.w700,
            color: AppColor.black,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing10),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
            child: text(
              text:
                  'Your friend has been invited to join this order. They will receive a notification to accept or decline.',
              size: responsive.fontSize13,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.5),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: responsive.spacing32),
        ],
      ),
    );
  }
}
