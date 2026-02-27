import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/responsive_helper.dart';

class ResponsiveOrderRejectedSheet extends StatelessWidget {
  final dynamic selectedPaymentMethod;
  final String? rejectionReason;

  const ResponsiveOrderRejectedSheet({super.key, required this.selectedPaymentMethod, this.rejectionReason});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      width: responsive.widthPercent(100),
      padding: responsive.bottomSheetPadding,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Drag indicator
            Align(
              alignment: Alignment.center,
              child: Container(
                width: responsive.spacing120,
                height: responsive.spacing4,
                margin: EdgeInsets.only(bottom: responsive.spacing10),
                decoration: BoxDecoration(
                  color: const Color(0XFFD9D9D9),
                  borderRadius: BorderRadius.circular(responsive.extraLargeBorderRadius),
                ),
              ),
            ),
            SizedBox(height: responsive.spacing30),

            // ✅ Payment method image
            image(
              url: selectedPaymentMethod['imageUrl'],
              width: responsive.iconSizeXXL,
              height: responsive.iconSizeXXL,
              borderRadius: BorderRadius.circular(responsive.inputBorderRadius),
            ),
            SizedBox(height: responsive.spacing30),

            // ✅ Title
            text(
              text: 'Order Rejected',
              size: responsive.fontSize22,
              fontWeight: FontWeight.w600,
              color: AppColor.black,
            ),
            SizedBox(height: responsive.spacing10),

            // ✅ Description
            text(
              text: 'Unfortunately, the restaurant has rejected your order. Please try another restaurant.',
              size: responsive.fontSize16,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.4),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.spacing20),

            // ✅ Rejection Reason Box (if reason exists)
            if (rejectionReason != null && rejectionReason!.isNotEmpty)
              Container(
                width: responsive.widthPercent(100),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
                  border: Border.all(color: AppColor.black.withOpacity(0.1)),
                  color: Colors.red.withOpacity(0.05),
                ),
                padding: responsive.containerPaddingSmall,
                margin: EdgeInsets.only(bottom: responsive.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: responsive.iconSizeSmall, color: Colors.red),
                        SizedBox(width: responsive.spacing10),
                        text(
                          text: 'Rejection Reason',
                          size: responsive.fontSize16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.black,
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.spacing10),
                    text(
                      text: rejectionReason!,
                      size: responsive.fontSize13,
                      fontWeight: FontWeight.w400,
                      color: AppColor.black.withOpacity(0.7),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),

            // ✅ Order Again Button
            button(
              name: 'Order Again',
              width: responsive.widthPercent(100),
              height: responsive.formFieldHeight,
              borderRadius: BorderRadius.circular(responsive.extraLargeBorderRadius),
              fontSize: responsive.fontSize18,
              fontWeight: FontWeight.w600,
              onTap: () {
                // ✅ Handle order again - navigate back to cart or home
                Navigator.of(context).pop();
              },
            ),
            SizedBox(height: responsive.spacing10),
          ],
        ),
      ),
    );
  }
}
