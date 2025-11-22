import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:svg_flutter/svg.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../../core/util/common_widgets.dart';
import '../../cart/view/widget/dotted_line_painter.dart';

class OrderSuccessView extends StatefulWidget {
  const OrderSuccessView({super.key});

  @override
  State<OrderSuccessView> createState() => _OrderSuccessViewState();
}

class _OrderSuccessViewState extends State<OrderSuccessView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        title: text(text: 'Success', size: 18, fontWeight: FontWeight.w600),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withOpacity(0.06), width: 1.5),
              ),
              child: SvgPicture.string(arrowBack2),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(children: [OrderSuccessSection(), TrackYourOrderSection(), OrderSummarySection()]),
      ),
      bottomNavigationBar: Container(
        width: context.wp(100),
        color: AppColor.scaffoldColor,
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
        child: Row(
          children: [
            Expanded(
              child: button(
                name: 'Go Home',
                fontSize: 18,
                height: 60,
                fontWeight: FontWeight.w600,
                borderRadius: BorderRadius.circular(100),
                onTap: () {},
                color: AppColor.transparent,
                borderColor: AppColor.black.withOpacity(0.2),
                textColor: AppColor.black.withOpacity(0.6),
              ),
            ),
            20.w,
            Expanded(
              child: button(
                name: 'Confirm Order',
                fontSize: 18,
                height: 60,
                fontWeight: FontWeight.w600,
                borderRadius: BorderRadius.circular(100),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderSummarySection extends StatelessWidget {
  const OrderSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.wp(100),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          20.h,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                image(
                  url: 'https://picsum.photos/250?image=30',
                  width: 50,
                  height: 50,
                  borderRadius: BorderRadius.circular(6),
                ),
                16.w,
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: text(
                              text: 'Classic Chicken Burger',
                              size: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColor.black,
                              maxLines: 1,
                              overFlow: TextOverflow.ellipsis,
                            ),
                          ),
                          text(
                            text: '07-06-2025',
                            size: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColor.black.withOpacity(0.4),
                          ),
                        ],
                      ),
                      4.h,
                      Row(
                        children: [
                          Expanded(
                            child: text(
                              text: 'Order ID:456789',
                              size: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColor.black.withOpacity(0.4),
                            ),
                          ),
                          text(
                            text: '11:00 AM',
                            size: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColor.black.withOpacity(0.4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          20.h,
          Container(
            width: context.wp(100),
            color: AppColor.appPrimary,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            margin: EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text(text: 'Arrival Time', size: 16, fontWeight: FontWeight.w600, color: AppColor.white),
                text(text: '20 Mins', size: 16, fontWeight: FontWeight.w600, color: AppColor.white),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              return Row(
                children: [
                  image(
                    url: 'https://picsum.photos/250?image=30',
                    width: 50,
                    height: 50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  16.w,
                  Expanded(
                    child: text(
                      text: 'Classic Chicken Burger',
                      size: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColor.black,
                      maxLines: 1,
                      overFlow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) => 20.h,
            itemCount: 2,
          ),
          20.h,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              height: 1,
              width: double.infinity,
              child: CustomPaint(painter: DottedLinePainter(color: AppColor.black.withOpacity(0.1))),
            ),
          ),
          20.h,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text(text: 'Subtotal', size: 16, fontWeight: FontWeight.w500, color: AppColor.black.withOpacity(0.6)),
                text(text: 'Rs.357', size: 16, fontWeight: FontWeight.w500, color: AppColor.black),
              ],
            ),
          ),
          20.h,
        ],
      ),
    );
  }
}

class TrackYourOrderSection extends StatelessWidget {
  const TrackYourOrderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.wp(100),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.appPrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0))],
      ),
      child: Row(
        children: [
          SvgPicture.string(trackSvg2),
          16.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(text: 'Track Your Order', size: 18, fontWeight: FontWeight.w600, color: AppColor.white),
                6.h,
                text(
                  text: 'Know exactly when your food will arrive.',
                  size: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColor.white.withOpacity(0.8),
                ),
              ],
            ),
          ),
          button(
            name: 'Track',
            color: AppColor.white,
            textColor: AppColor.black,
            borderRadius: BorderRadius.circular(100),
            width: 62,
            height: 30,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class OrderSuccessSection extends StatelessWidget {
  const OrderSuccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.wp(100),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 22),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0))],
      ),
      child: Column(
        children: [
          image(
            url: 'https://picsum.photos/250?image=30',
            width: 130,
            height: 130,
            borderRadius: BorderRadius.circular(10),
          ),
          20.h,
          text(text: 'Order Placed Successfully!', size: 20, fontWeight: FontWeight.w600),
          6.h,
          text(
            text: 'Your delicious meal is on its way. You’ll receive a notification once it\'s out for delivery.".',
            size: 16,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
