import 'dart:async';
import 'dart:developer';

import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../../core/util/common_widgets.dart';
import '../../restaurant_detail_view/controller/restaurant_detail_view_controller.dart';
import '../../restaurant_detail_view/model/restaurent_details_model.dart';
import '../../restaurant_detail_view/view/widget/quantity_control_widget.dart';
import 'widget/dotted_line_painter.dart';

class FoodDetailsView extends StatefulWidget {
  const FoodDetailsView({super.key});

  @override
  State<FoodDetailsView> createState() => _FoodDetailsViewState();
}

class _FoodDetailsViewState extends State<FoodDetailsView> {
  final ScrollController _scrollController = ScrollController();
  late PageController _bannerController;
  bool _isScrolled = false;
  bool _isPreviewSheetOpen = false;
  int _currentBannerIndex = 0;
  late Timer _bannerAutoScrollTimer;

  // Local variables extracted from arguments
  late String foodName;
  late String foodImage;
  late String foodId;
  late int? foodPrice;
  late int? discountPrice;
  late int? actualPrice;
  late List<Customization>? customizations;
  late List<AddOn>? addOns;

  @override
  void initState() {
    super.initState();
    _initializeScrollListener();
    _extractArguments();
    // Initialize banner controller
    _bannerController = PageController(initialPage: 0);
    // Start auto-scroll timer
    _startBannerAutoScroll();
    // Sync with controller state after arguments extraction
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncControllerState();
    });
  }

  /// ✨ Start auto-scroll timer for banners
  void _startBannerAutoScroll() {
    _bannerAutoScrollTimer = Timer.periodic(Duration(seconds: 4), (_) {
      if (_bannerController.hasClients) {
        final nextPage = (_currentBannerIndex + 1) % 3; // Assuming max 3 banners, cycle back
        _bannerController.animateToPage(nextPage, duration: Duration(milliseconds: 800), curve: Curves.easeInOut);
      }
    });
  }

  void _extractArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      foodName = args['foodName'] ?? '';
      foodImage = args['foodImage'] ?? '';
      foodId = args['foodId'] ?? '';
      foodPrice = args['foodPrice'];
      discountPrice = args['discountPrice'];
      actualPrice = args['actualPrice'];
      customizations = args['customizations'];
      addOns = args['addOns'];
    }
  }

  /// Sync controller state - ensures selectedFoodItem is set and tracked
  void _syncControllerState() {
    final controller = Get.find<RestaurantDetailViewController>();

    // If no food is selected in controller OR selected food ID doesn't match current food
    if (controller.selectedFoodItem == null || controller.selectedFoodItem!.foodId != foodId) {
      log('🔄 Syncing controller state for food: $foodId');

      // Create a Food object to set as selected in controller
      final food = Food(
        foodId: foodId,
        foodName: foodName,
        foodImage: foodImage,
        foodPrice: foodPrice?.toDouble(),
        discountPrice: discountPrice?.toDouble(),
        actualPrice: actualPrice?.toDouble(),
        customizations: customizations,
        addOns: addOns,
      );

      controller.selectFoodItem(food);
    }
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
    _bannerController.dispose(); // ✨ Dispose banner controller
    _bannerAutoScrollTimer.cancel(); // ✨ Cancel auto-scroll timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantDetailViewController>(
      builder:
          (controller) => Scaffold(
            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  _buildBackgroundImage(),
                  _buildCollapsibleAppBar(),
                  _buildMainContent(controller),
                  _buildBottomCartButton(controller),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildBackgroundImage() {
    if (_isScrolled) return SizedBox();

    return Container(
      width: context.wp(100),
      height: 343,
      decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(foodImage), fit: BoxFit.cover)),
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
        child: IconButton(
          onPressed: () {
            // Get.find<RestaurantDetailViewController>().resetAllSelections();
            Get.back();
          },
          icon: SvgPicture.string(arrowBack),
        ),
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
          decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(foodImage), fit: BoxFit.cover)),
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
                Expanded(
                  child: text(
                    text: foodName,
                    color: AppColor.white,
                    size: 16,
                    fontWeight: FontWeight.w600,
                    maxLines: 1,
                    overFlow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(RestaurantDetailViewController controller) {
    final hasCustomizations = customizations != null && customizations!.isNotEmpty;
    final hasAddOns = addOns != null && addOns!.isNotEmpty;

    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      top: _isScrolled ? 120 - 20 : 343 - 20,
      left: 0,
      right: 0,
      bottom: 100,
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
              // ✨ NEW: Banners carousel
              _buildBannersCarousel(),
              20.h,
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text(
                          text: foodName,
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
                  // Show quantity control if no customizations
                  if (!hasCustomizations) _buildQuantityControl(controller),
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
              10.h,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  height: 1,
                  width: double.infinity,
                  child: CustomPaint(painter: DottedLinePainter(color: AppColor.black.withOpacity(0.1))),
                ),
              ),
              20.h,
              // Customizations section
              if (hasCustomizations) ...[_buildCustomizationsSectionDetail(controller), 20.h],
              // Add-ons section
              if (hasAddOns) ...[
                text(text: 'Add Ons', size: 16, fontWeight: FontWeight.w600),
                10.h,
                _buildAddOnsSectionDetail(controller),
              ],
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// ✨ Banners carousel widget
  Widget _buildBannersCarousel() {
    // Get restaurant banners from controller if available, otherwise use food image as fallback
    final controller = Get.find<RestaurantDetailViewController>();
    final banners = controller.banners.isNotEmpty ? controller.banners : [foodImage];

    if (banners.isEmpty) return SizedBox();

    return Column(
      children: [
        // ✨ PageView carousel
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _bannerController,
              onPageChanged: (index) {
                setState(() => _currentBannerIndex = index % banners.length);
              },
              itemBuilder: (context, index) {
                final bannerUrl = banners[index % banners.length];
                return image(
                  url: bannerUrl,
                  height: 180,
                  width: context.wp(100),
                  borderRadius: BorderRadius.circular(20),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControl(RestaurantDetailViewController controller) {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'food_quantity_widget',
      builder: (controller) {
        final quantity = controller.getCustomizationCount(foodId);
        return QuantityControlWidget(
          quantity: quantity,
          onIncrease: () => controller.toggleCustomization(''),
          onDecrease: controller.decreaseCustomization,
          showRemoveButton: quantity > 0,
          buttonSize: quantity > 0 ? 40 : 60,
          iconSize: 18,
          addButtonText: quantity == 0 ? 'ADD' : null,
        );
      },
    );
  }

  Widget _buildCustomizationsSectionDetail(RestaurantDetailViewController controller) {
    if (customizations == null || customizations!.isEmpty) {
      return SizedBox();
    }

    return GetBuilder<RestaurantDetailViewController>(
      id: 'customization_widget',
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 16,
                  width: 4,
                  decoration: BoxDecoration(color: AppColor.appPrimary, borderRadius: BorderRadius.circular(100)),
                  margin: EdgeInsets.only(right: 6),
                ),
                text(text: 'Customize Your Food', size: 16, fontWeight: FontWeight.w600),
              ],
            ),
            10.h,
            ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final customization = customizations![index];
                return _buildCustomizationTileDetail(controller, customization);
              },
              separatorBuilder: (context, index) => 16.h,
              itemCount: customizations!.length,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomizationTileDetail(RestaurantDetailViewController controller, Customization customization) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColor.white,
        boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(text: customization.name ?? '', size: 14, fontWeight: FontWeight.w600, color: AppColor.black),
                4.h,
                text(
                  text: '₹ ${customization.price?.toInt() ?? 0}',
                  size: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColor.black.withOpacity(0.6),
                ),
              ],
            ),
          ),
          GetBuilder<RestaurantDetailViewController>(
            id: 'customization_widget',
            builder: (controller) {
              final quantity = controller.getCustomizationCount(foodId);
              return QuantityControlWidget(
                quantity: quantity,
                onIncrease: () => controller.toggleCustomization(customization.customizationId ?? ''),
                onDecrease: controller.decreaseCustomization,
                showRemoveButton: quantity > 0,
                buttonSize: 32,
                iconSize: 14,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnsSectionDetail(RestaurantDetailViewController controller) {
    if (addOns == null || addOns!.isEmpty) {
      return SizedBox();
    }

    return GetBuilder<RestaurantDetailViewController>(
      id: 'addons_list',
      builder: (controller) {
        return ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final addOn = addOns![index];
            return _buildAddOnTileDetail(controller, addOn);
          },
          separatorBuilder: (context, index) => 16.h,
          itemCount: addOns!.length,
        );
      },
    );
  }

  Widget _buildAddOnTileDetail(RestaurantDetailViewController controller, AddOn addOn) {
    return GestureDetector(
      onTap: () => controller.toggleAddOn(addOn.addOnId ?? ''),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColor.white,
          boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            image(url: addOn.image ?? '', height: 40, width: 40, borderRadius: BorderRadius.circular(4)),
            16.w,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text(
                    text: addOn.name ?? '',
                    size: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black,
                    maxLines: 1,
                    overFlow: TextOverflow.ellipsis,
                  ),
                  4.h,
                  text(
                    text: '₹ ${addOn.price?.toInt() ?? 0}',
                    size: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColor.black.withOpacity(0.6),
                  ),
                ],
              ),
            ),
            Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                color: controller.isAddOnSelected(addOn.addOnId ?? '') ? AppColor.appPrimary : AppColor.white,
                border: Border.all(
                  color:
                      controller.isAddOnSelected(addOn.addOnId ?? '')
                          ? AppColor.appPrimary
                          : AppColor.appPrimary.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child:
                  controller.isAddOnSelected(addOn.addOnId ?? '')
                      ? Icon(Icons.done, color: AppColor.white, size: 13)
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  // Bottom cart button - fixed at bottom
  Widget _buildBottomCartButton(RestaurantDetailViewController controller) {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'total_price',
      builder: (controller) {
        final quantity = controller.getCustomizationCount(foodId);
        if (quantity == 0) {
          return SizedBox.shrink();
        }

        final hasSelectedAddOns = controller.getSelectedAddOns(foodId).isNotEmpty;

        return AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          bottom: 0,
          left: 0,
          right: 0,
          height: 100,
          child: Container(
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
                              onTap: () {
                                setState(() => _isPreviewSheetOpen = !_isPreviewSheetOpen);
                                _showPreviewBottomSheet(controller);
                              },
                              child: AnimatedRotation(
                                turns: _isPreviewSheetOpen ? 0.5 : 0.0,
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
                  onTap: () {
                    controller.logAndAddToCartFromFoodDetails();
                    Get.back();
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
          ),
        );
      },
    );
  }

  // Preview bottom sheet - read-only summary (starts above cart widget)
  void _showPreviewBottomSheet(RestaurantDetailViewController controller) {
    final foodItem = controller.selectedFoodItem;
    if (foodItem == null) return;

    final selectedAddOns = controller.getSelectedAddOns(foodId);
    final hasCustomizations = customizations != null && customizations!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.scaffoldColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.8, // ✨ Starts above cart widget, doesn't cover it
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
                    _buildHandleBar(),
                    _buildPreviewHeader(),
                    Divider(color: AppColor.black.withOpacity(0.1), thickness: 1.5),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            20.h,
                            _buildPreviewFoodItem(foodItem),
                            20.h,
                            if (hasCustomizations) ...[_buildPreviewCustomizationsSection(), 20.h],
                            if (selectedAddOns.isNotEmpty) ...[_buildPreviewAddOnsSection(selectedAddOns), 20.h],
                            _buildPreviewPriceSummary(controller),
                            40.h,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    ).then((_) {
      // ✨ Reset arrow rotation when sheet closes
      setState(() => _isPreviewSheetOpen = false);
    });
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

  Widget _buildPreviewHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(text: 'Order Summary', size: 18, fontWeight: FontWeight.w600),
          6.h,
          text(
            text: 'Review your selected items.',
            size: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewFoodItem(Food foodItem) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColor.white,
        boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          image(url: foodItem.foodImage ?? '', height: 50, width: 50, borderRadius: BorderRadius.circular(4)),
          16.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(
                  text: foodItem.foodName ?? '',
                  size: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black,
                  maxLines: 1,
                  overFlow: TextOverflow.ellipsis,
                ),
                4.h,
                Row(
                  children: [
                    text(
                      text: '₹${(foodItem.discountPrice ?? foodItem.foodPrice ?? 0).toInt()}',
                      size: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                    ),
                    8.w,
                    GetBuilder<RestaurantDetailViewController>(
                      id: 'food_quantity_widget',
                      builder: (controller) {
                        final qty = controller.getCustomizationCount(foodId);
                        return text(
                          text: '× $qty',
                          size: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColor.black.withOpacity(0.6),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          GetBuilder<RestaurantDetailViewController>(
            id: 'total_price',
            builder: (controller) {
              final qty = controller.getCustomizationCount(foodId);
              final price = (foodItem.discountPrice ?? foodItem.foodPrice ?? 0) * qty;
              return text(text: '₹$price', size: 14, fontWeight: FontWeight.w600, color: AppColor.appPrimary);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCustomizationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(text: 'Customizations', size: 14, fontWeight: FontWeight.w600),
        10.h,
        Container(
          width: Get.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColor.white,
            boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
          ),
          padding: EdgeInsets.all(12),
          child: text(
            text: customizations?.map((c) => '${c.name}').join(', ') ?? 'None',
            size: 13,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewAddOnsSection(List<AddOn> selectedAddOns) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(text: 'Add-Ons', size: 14, fontWeight: FontWeight.w600),
        10.h,
        ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final addOn = selectedAddOns[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColor.white,
                boxShadow: [
                  BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0)),
                ],
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  image(url: addOn.image ?? '', height: 40, width: 40, borderRadius: BorderRadius.circular(4)),
                  12.w,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text(
                          text: addOn.name ?? '',
                          size: 12,
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                          overFlow: TextOverflow.ellipsis,
                        ),
                        2.h,
                        text(
                          text: '₹${addOn.price?.toInt() ?? 0}',
                          size: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColor.black.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColor.appPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: text(text: '✓', size: 12, fontWeight: FontWeight.w600, color: AppColor.appPrimary),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => 8.h,
          itemCount: selectedAddOns.length,
        ),
      ],
    );
  }

  Widget _buildPreviewPriceSummary(RestaurantDetailViewController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(text: 'Price Breakdown', size: 14, fontWeight: FontWeight.w600),
        12.h,
        Container(
          width: Get.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColor.white,
            boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
          ),
          padding: EdgeInsets.all(12),
          child: GetBuilder<RestaurantDetailViewController>(
            id: 'total_price',
            builder: (controller) {
              final basePrice = controller.getBasePrice();
              final quantity = controller.getCustomizationCount(foodId);
              final foodTotal = basePrice * quantity;
              final addOnsTotal = controller.getAddOnsPrice();
              final totalPrice = controller.getTotalPrice();

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text(
                        text: 'Food × $quantity',
                        size: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColor.black.withOpacity(0.6),
                      ),
                      text(text: '₹${foodTotal.toStringAsFixed(0)}', size: 12, fontWeight: FontWeight.w600),
                    ],
                  ),
                  if (addOnsTotal > 0) ...[
                    8.h,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        text(
                          text: 'Add-Ons',
                          size: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColor.black.withOpacity(0.6),
                        ),
                        text(text: '₹${addOnsTotal.toStringAsFixed(0)}', size: 12, fontWeight: FontWeight.w600),
                      ],
                    ),
                    8.h,
                    Divider(color: AppColor.black.withOpacity(0.1)),
                  ],
                  8.h,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text(text: 'Total', size: 13, fontWeight: FontWeight.w700),
                      text(
                        text: '₹${totalPrice.toStringAsFixed(0)}',
                        size: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColor.appPrimary,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
