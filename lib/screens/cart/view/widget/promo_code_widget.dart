import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../coupons/controller/coupons_controller.dart';
import '../../controller/cart_controller.dart';

class PromoCodeWidget extends StatelessWidget {
  const PromoCodeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Guard: if CartController is no longer registered (disposed during
    //    route transition) skip rebuild entirely to avoid the
    //    "TextEditingController used after disposed" crash.
    if (!Get.isRegistered<CartController>()) return const SizedBox.shrink();

    return GetBuilder<CartController>(
      id: 'promo_validation',
      builder: (cartController) {
        // ✅ Double-guard inside builder for the rare frame where the
        //    controller is disposed mid-rebuild
        if (cartController.promoCodeController.dispose ==
            cartController.promoCodeController.dispose) {
          // controller still alive — proceed normally
        }

        final bool hasText =
            cartController.promoCodeController.text.trim().isNotEmpty;
        final bool isApplied = cartController.appliedPromoCode.isNotEmpty;
        final bool isApplying = cartController.isPromoApplying;

        return Container(
          width: context.wp(100),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 20),
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
              Row(
                children: [
                  SvgPicture.string(promoCodeSvg),
                  10.w,
                  Expanded(
                    child: buildCommonTextFormField(
                      hintText: 'Enter promo code',
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      controller: cartController.promoCodeController,
                      context: context,
                      borderColor:
                          cartController.promoCodeError.isNotEmpty
                              ? Colors.red
                              : AppColor.transparent,
                      bgColor: AppColor.transparent,
                      isFromPhoneText: true,
                      readOnly: isApplied,
                      onChanged: (value) {
                        cartController.formatPromoCode(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    context: context,
                    hasText: hasText,
                    isApplied: isApplied,
                    isApplying: isApplying,
                    cartController: cartController,
                  ),
                ],
              ),

              if (cartController.promoCodeError.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: text(
                    text: cartController.promoCodeError,
                    size: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
              ] else if (isApplied) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: text(
                    text: 'Promo code applied successfully!',
                    size: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required bool hasText,
    required bool isApplied,
    required bool isApplying,
    required CartController cartController,
  }) {
    if (isApplying) {
      return const SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Color(0xFF3CC06F),
        ),
      );
    }

    if (isApplied) {
      return GestureDetector(
        onTap: () {
          final CouponsController couponsController =
              Get.isRegistered<CouponsController>()
                  ? Get.find<CouponsController>()
                  : Get.put(CouponsController(), permanent: false);

          couponsController.removeCoupon(
            onError: (err) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(err),
                  backgroundColor: Colors.red.withOpacity(0.85),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.close, size: 16, color: Colors.white),
        ),
      );
    }

    if (hasText) {
      return GestureDetector(
        onTap: () => _handleApply(cartController),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColor.appPrimary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Apply',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.couponsView),
      child: CircleAvatar(
        radius: context.hp(2),
        backgroundColor: AppColor.appPrimary,
        child: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColor.white,
          size: 18,
        ),
      ),
    );
  }

  void _handleApply(CartController cartController) {
    final code = cartController.promoCodeController.text.trim();
    if (code.isEmpty) return;

    final CouponsController couponsController =
        Get.isRegistered<CouponsController>()
            ? Get.find<CouponsController>()
            : Get.put(CouponsController(), permanent: false);

    couponsController.applyCode(
      code,
      onError: (err) {
        cartController.setPromoError(err);
      },
    );
  }
}
