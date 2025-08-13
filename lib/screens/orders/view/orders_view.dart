import 'package:eatplek_app/core/util/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/util/common_widgets.dart';
import '../controller/orders_controller.dart';
import 'widget/orders_list.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrdersController>(
      init: OrdersController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColor.scaffoldColor,
          appBar: _buildAppBar(),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTabBarContainer(controller),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TabBarView(
                      controller: controller.tabController,
                      children: [
                        OrdersList(orderType: 'Delivery'),
                        OrdersList(orderType: 'Takeaway'),
                        OrdersList(orderType: 'Dining'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final bg = AppColor.scaffoldColor;

    return AppBar(
      elevation: 0,
      backgroundColor: bg,
      centerTitle: true,
      leadingWidth: 80,
      title: text(text: 'My Orders', size: 18, fontWeight: FontWeight.w600),
      // leading: GestureDetector(
      //   onTap: () => Get.back(),
      //   child: Center(
      //     child: Container(
      //       width: 44,
      //       height: 44,
      //       decoration: BoxDecoration(
      //         shape: BoxShape.circle,
      //         color: AppColor.white,
      //         border: Border.all(color: Colors.black.withOpacity(0.06), width: 1.5),
      //         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
      //       ),
      //       padding: const EdgeInsets.all(12),
      //       child: SvgPicture.string(arrowBack2),
      //     ),
      //   ),
      // ),
    );
  }

  Widget _buildTabBarContainer(OrdersController controller) {
    final border = AppColor.black.withOpacity(0.03);
    final indicatorBorder = AppColor.black.withOpacity(0.04);
    final unselected = AppColor.black.withOpacity(0.6);
    final bg = AppColor.scaffoldColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border, width: 1),
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0))],
      ),
      child: Theme(
        data: Theme.of(
          Get.context!,
        ).copyWith(splashColor: Colors.transparent, highlightColor: Colors.transparent, hoverColor: Colors.transparent),
        child: TabBar(
          controller: controller.tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: indicatorBorder, width: 1),
          ),
          labelColor: AppColor.black,
          unselectedLabelColor: unselected,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          dividerColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: const [Tab(text: 'Delivery'), Tab(text: 'Takeaway'), Tab(text: 'Dining')],
        ),
      ),
    );
  }
}
