import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../controller/orders_controller.dart';
import 'widget/orders_list.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  late List<GlobalKey> _tabKeys;
  final ScrollController _tabScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabKeys = List.generate(5, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  void _scrollToTab(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_tabScrollController.hasClients) return;
      final key = _tabKeys[index];
      final ctx = key.currentContext;
      if (ctx == null) return;
      final pillBox = ctx.findRenderObject() as RenderBox?;
      if (pillBox == null) return;
      final scrollBox =
          _tabScrollController.position.context.storageContext
                  .findRenderObject()
              as RenderBox?;
      if (scrollBox == null) return;
      final pillOffset = pillBox.localToGlobal(
        Offset.zero,
        ancestor: scrollBox,
      );
      final pillLeft = pillOffset.dx;
      final pillWidth = pillBox.size.width;
      final viewportWidth = scrollBox.size.width;
      final currentScroll = _tabScrollController.offset;
      const peekWidth = 30.0;
      const edgePadding = 16.0;
      double targetScroll = currentScroll;
      if (pillLeft + pillWidth > viewportWidth - peekWidth) {
        targetScroll =
            currentScroll + (pillLeft + pillWidth) - viewportWidth + peekWidth;
      } else if (pillLeft < edgePadding) {
        targetScroll = currentScroll + pillLeft - edgePadding;
      }
      _tabScrollController.animateTo(
        targetScroll.clamp(0.0, _tabScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  _buildTabBar(controller, context)
                      .animate()
                      .fade(duration: 350.ms)
                      .slideY(
                        begin: -0.1,
                        end: 0,
                        duration: 350.ms,
                        curve: Curves.easeOut,
                      ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashFactory: NoSplash.splashFactory,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: TabBarView(
                        controller: controller.tabController,
                        children: List.generate(
                          controller.tabs.length,
                          (index) => GetBuilder<OrdersController>(
                            id: 'orders_tab_$index',
                            builder:
                                (ctrl) => OrdersList(
                                  controller: ctrl,
                                  tabIndex: index,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColor.scaffoldColor,
      centerTitle: true,
      title: text(
        text: 'My Orders',
        size: 18,
        fontWeight: FontWeight.w700,
        color: AppColor.black,
      ),
    );
  }

  Widget _buildTabBar(OrdersController controller, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColor.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 20),
        ],
      ),
      child: GetBuilder<OrdersController>(
        id: 'tab_bar',
        builder:
            (ctrl) => SingleChildScrollView(
              controller: _tabScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(ctrl.tabs.length, (index) {
                  final isSelected = ctrl.tabController.index == index;
                  final label = ctrl.tabs[index]['label']!;

                  return GestureDetector(
                    key: _tabKeys[index],
                    onTap: () {
                      ctrl.tabController.animateTo(index);
                      _scrollToTab(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColor.appPrimary
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: AppColor.appPrimary.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                                : null,
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected
                                  ? AppColor.white
                                  : AppColor.black.withOpacity(0.55),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
      ),
    );
  }
}
