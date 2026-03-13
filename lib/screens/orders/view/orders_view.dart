import 'package:eatplek_app/core/util/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/util/common_widgets.dart';
import '../controller/orders_controller.dart';
import 'widget/orders_list.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  // One GlobalKey per tab pill — used to measure each pill's position/size
  late List<GlobalKey> _tabKeys;

  // ScrollController for the horizontal pill row
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

  /// Auto-scrolls the pill row so the selected tab is fully visible.
  /// Leaves a 30 px "peek" of the adjacent pill as a scroll hint.
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

      const double peekWidth = 30.0; // peek of next pill on the right
      const double edgePadding = 16.0; // breathing room on the left

      double targetScroll = currentScroll;

      if (pillLeft + pillWidth > viewportWidth - peekWidth) {
        // Pill bleeds off the right → scroll right
        targetScroll =
            currentScroll + (pillLeft + pillWidth) - viewportWidth + peekWidth;
      } else if (pillLeft < edgePadding) {
        // Pill bleeds off the left → scroll left
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
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTabContainer(controller, context),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
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
      backgroundColor: AppColor.scaffoldColor,
      centerTitle: true,
      leadingWidth: 80,
      title: text(text: 'My Orders', size: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTabContainer(OrdersController controller, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColor.black.withOpacity(0.03), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: GetBuilder<OrdersController>(
          id: 'tab_bar',
          builder: (ctrl) {
            return SingleChildScrollView(
              controller: _tabScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(ctrl.tabs.length, (index) {
                  final isSelected = ctrl.tabController.index == index;
                  final label = ctrl.tabs[index]['label']!;

                  return InkWell(
                    key: _tabKeys[index],
                    onTap: () {
                      ctrl.tabController.animateTo(index);
                      _scrollToTab(index);
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    borderRadius: BorderRadius.circular(100),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColor.scaffoldColor
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                        border:
                            isSelected
                                ? Border.all(
                                  color: AppColor.black.withOpacity(0.04),
                                  width: 1,
                                )
                                : null,
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected
                                  ? AppColor.black
                                  : AppColor.black.withOpacity(0.6),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}
