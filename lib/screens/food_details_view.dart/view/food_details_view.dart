import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../restaurant_detail_view/view/widget/quantity_control_widget.dart';
import '../controller/food_details_view_controller.dart';
import 'widget/dotted_line_painter.dart';

class FoodDetailsView extends StatefulWidget {
  const FoodDetailsView({super.key});

  @override
  State<FoodDetailsView> createState() => _FoodDetailsViewState();
}

class _FoodDetailsViewState extends State<FoodDetailsView> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isBottomSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _initializeScrollListener();
  }

  void _initializeScrollListener() {
    _scrollController.addListener(() {
      const double scrollThreshold = 100;
      final bool shouldBeScrolled = _scrollController.offset > scrollThreshold;

      if (shouldBeScrolled != _isScrolled) {
        setState(() {
          _isScrolled = shouldBeScrolled;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showSelectedAddOnsBottomSheet() {
    setState(() {
      _isBottomSheetOpen = true;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.scaffoldColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      isScrollControlled: true,
      builder: (context) => SelectedFoodAddOnsWidget(),
    ).whenComplete(() {
      setState(() {
        _isBottomSheetOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FoodDetailsViewController>(
      init: FoodDetailsViewController(),
      builder:
          (controller) => Scaffold(
            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [_buildBackgroundImage(), _buildCollapsibleAppBar(), _buildMainContent(controller)],
              ),
            ),
            bottomNavigationBar: _buildBottomCartButton(controller),
          ),
    );
  }

  Widget _buildBackgroundImage() {
    if (_isScrolled) return SizedBox();

    return Container(
      width: context.wp(100),
      height: 343,
      decoration: BoxDecoration(
        image: DecorationImage(image: NetworkImage('https://picsum.photos/250?image=30'), fit: BoxFit.cover),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [20.h, _buildBackButton()]),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColor.white.withOpacity(0.4)),
        ),
        child: IconButton(onPressed: () => Get.back(), icon: SvgPicture.string(arrowBack)),
      ),
    );
  }

  Widget _buildCollapsibleAppBar() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      top: 0,
      left: 0,
      right: 0,
      height: _isScrolled ? 120 : 0,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: _isScrolled ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: NetworkImage('https://picsum.photos/250?image=30'), fit: BoxFit.cover),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 30),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColor.white.withOpacity(0.4)),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Get.back(),
                    icon: SvgPicture.string(arrowBack),
                  ),
                ),
                16.w,
                text(text: 'Nibraz Restaurant', color: AppColor.white, size: 16, fontWeight: FontWeight.w600),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(FoodDetailsViewController controller) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      top: _isScrolled ? 120 - 20 : 343 - 20, // 20px overlap
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.scaffoldColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              20.h,
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text(
                          text: 'Classic Chicken Burger',
                          size: 20,
                          fontWeight: FontWeight.w600,
                          maxLines: 2,
                          overFlow: TextOverflow.ellipsis,
                        ),
                        10.h,
                        Row(
                          children: [
                            SvgPicture.string(locationUnFilled),
                            8.w,
                            text(
                              text: '12 KM',
                              color: AppColor.black.withOpacity(0.6),
                              size: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            10.w,
                            CircleAvatar(radius: 3, backgroundColor: AppColor.black.withOpacity(0.4)),
                            10.w,
                            SvgPicture.string(deliveryBike),
                            8.w,
                            text(
                              text: '25–35 mins',
                              color: AppColor.black.withOpacity(0.6),
                              size: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildQuantityControls(controller),
                ],
              ),
              3.h,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [text(text: 'Non - veg', size: 14, fontWeight: FontWeight.w500, color: Color(0XFFFF6E00))],
              ),
              20.h,
              Row(
                children: [
                  Container(
                    height: 16,
                    width: 4,
                    decoration: BoxDecoration(color: AppColor.appPrimary, borderRadius: BorderRadius.circular(100)),
                    margin: EdgeInsets.only(right: 6),
                  ),
                  text(text: 'About The Food', size: 16, fontWeight: FontWeight.w600, color: AppColor.black),
                ],
              ),
              10.h,
              text(
                text:
                    '''Juicy grilled chicken patty layered with fresh lettuce, creamy mayo, and melted cheese, all tucked inside a soft sesame bun. A timeless favorite made to satisfy every craving.''',
                size: 14,
                fontWeight: FontWeight.w400,
                color: AppColor.black.withOpacity(0.6),
                textAlign: TextAlign.justify,
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
              text(text: 'Customize Your Burger', size: 16, fontWeight: FontWeight.w600),
              20.h,
              GetBuilder<FoodDetailsViewController>(
                id: 'addons',
                builder: (controller) {
                  return ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final addOn = controller.availableAddOns[index];
                      return AddOnSelectionWidget(
                        id: addOn.id,
                        name: addOn.name,
                        price: '₹ ${addOn.price.toInt()}',
                        imageUrl: addOn.imageUrl,
                        isSelected: addOn.isSelected,
                        onTap: () => controller.toggleAddOn(addOn.id),
                        margin: 0,
                      );
                    },
                    separatorBuilder: (context, index) => 20.h,
                    itemCount: controller.availableAddOns.length,
                  );
                },
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityControls(FoodDetailsViewController controller) {
    return GetBuilder<FoodDetailsViewController>(
      id: 'quantity',
      builder: (controller) {
        return QuantityControlWidget(
          quantity: controller.quantity,
          onIncrease: controller.incrementQuantity,
          onDecrease: controller.decrementQuantity,
          showRemoveButton: controller.quantity > 0,
          buttonSize: controller.quantity > 0 ? 40 : 60,
          iconSize: 18,
          addButtonText: controller.quantity == 0 ? 'ADD' : null,
        );
      },
    );
  }

  Widget _buildBottomCartButton(FoodDetailsViewController controller) {
    return GetBuilder<FoodDetailsViewController>(
      id: 'cart',
      builder: (controller) {
        if (controller.quantity == 0) {
          return SizedBox.shrink();
        }

        final hasSelectedAddOns = controller.getSelectedAddOns().isNotEmpty;

        return Container(
          width: Get.width,
          decoration: BoxDecoration(
            color: AppColor.white,
            border: BorderDirectional(top: BorderSide(color: AppColor.black.withOpacity(0.1), width: 1)),
            boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.08), blurRadius: 14, offset: Offset(0, -2))],
          ),
          padding: EdgeInsets.only(top: 11, left: 16, right: 16, bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        text(
                          text: 'Total Amount',
                          size: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColor.black.withOpacity(0.6),
                        ),
                        if (hasSelectedAddOns) ...[
                          4.w,
                          GestureDetector(
                            onTap: _showSelectedAddOnsBottomSheet,
                            child: AnimatedRotation(
                              turns: _isBottomSheetOpen ? 0.5 : 0.0,
                              duration: Duration(milliseconds: 300),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColor.black.withOpacity(0.6),
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    text(
                      text: '₹${controller.getTotalPrice().toStringAsFixed(0)}',
                      size: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                    ),
                  ],
                ),
              ),
              button(
                name: 'Add to Cart',
                onTap: controller.addToCart,
                width: 125,
                height: 50,
                color: AppColor.appPrimary,
                textColor: AppColor.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                borderRadius: BorderRadius.circular(100),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SelectedFoodAddOnsWidget extends StatelessWidget {
  const SelectedFoodAddOnsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FoodDetailsViewController>(
      builder: (controller) {
        final selectedAddOns = controller.getSelectedAddOns();

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColor.scaffoldColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  _buildHandleBar(),

                  // Header
                  _buildHeader(),

                  // Divider
                  Divider(color: AppColor.black.withOpacity(0.06), thickness: 1),

                  // Selected food item with quantity controls
                  _buildSelectedFoodItem(controller),

                  // Selected add-ons section
                  if (selectedAddOns.isNotEmpty) ...[
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSelectedAddOnsHeader(),
                            20.h,
                            _buildSelectedAddOnsList(controller, selectedAddOns),
                            100.h, // Extra space for scrolling
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Center(
                        child: text(text: 'No add-ons selected', size: 16, color: AppColor.black.withOpacity(0.5)),
                      ),
                    ),
                  ],

                  // Bottom checkout section
                  _buildCheckoutSection(controller),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHandleBar() {
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: 120,
          height: 4,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), color: Color(0XFFD9D9D9)),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(text: 'Your Cart Summary', size: 18, fontWeight: FontWeight.w600),
          6.h,
          text(
            text: 'Your selected items and add-ons at a glance.',
            size: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFoodItem(FoodDetailsViewController controller) {
    return GetBuilder<FoodDetailsViewController>(
      id: 'quantity',
      builder: (controller) {
        return Container(
          width: Get.width,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColor.white),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 17),
          child: Row(
            children: [
              image(
                url: 'https://picsum.photos/250?image=30',
                height: 40,
                width: 40,
                borderRadius: BorderRadius.circular(4),
              ),
              20.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      text: 'Classic Chicken Burger',
                      size: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                      maxLines: 1,
                      overFlow: TextOverflow.ellipsis,
                    ),
                    4.h,
                    text(text: '₹ 299', size: 12, fontWeight: FontWeight.w500, color: AppColor.black.withOpacity(0.6)),
                  ],
                ),
              ),
              QuantityControlWidget(
                quantity: controller.quantity,
                onIncrease: controller.incrementQuantity,
                onDecrease: controller.decrementQuantity,
                showRemoveButton: true,
                buttonSize: 28,
                iconSize: 14,
                margin: EdgeInsets.only(right: 7),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedAddOnsHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(text: 'Selected Add Ons', size: 18, fontWeight: FontWeight.w600),
          6.h,
          text(
            text: 'Your chosen add-ons for this item.',
            size: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedAddOnsList(FoodDetailsViewController controller, List selectedAddOns) {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final addOn = selectedAddOns[index];
        return GetBuilder<FoodDetailsViewController>(
          id: 'addons',
          builder: (controller) {
            return AddOnSelectionWidget(
              id: addOn.id,
              name: addOn.name,
              price: '₹ ${addOn.price.toInt()}',
              imageUrl: addOn.imageUrl,
              isSelected: addOn.isSelected,
              onTap: () => controller.toggleAddOn(addOn.id),
            );
          },
        );
      },
      separatorBuilder: (context, index) => 20.h,
      itemCount: selectedAddOns.length,
    );
  }

  Widget _buildCheckoutSection(FoodDetailsViewController controller) {
    return GetBuilder<FoodDetailsViewController>(
      id: 'cart',
      builder: (controller) {
        return Container(
          width: Get.width,
          decoration: BoxDecoration(
            color: AppColor.white,
            border: BorderDirectional(top: BorderSide(color: AppColor.black.withOpacity(0.1), width: 1)),
            boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.08), blurRadius: 14, offset: Offset(0, -2))],
          ),
          padding: EdgeInsets.only(top: 11, left: 16, right: 16, bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      text: 'Total Amount',
                      size: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColor.black.withOpacity(0.6),
                    ),
                    text(
                      text: '₹${controller.getTotalPrice().toStringAsFixed(0)}',
                      size: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                    ),
                  ],
                ),
              ),
              button(
                name: 'Add to Cart',
                onTap: () {
                  controller.addToCart();
                  Get.back(); // Close the bottom sheet
                },
                width: 125,
                height: 50,
                color: AppColor.appPrimary,
                textColor: AppColor.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                borderRadius: BorderRadius.circular(100),
              ),
            ],
          ),
        );
      },
    );
  }
}
