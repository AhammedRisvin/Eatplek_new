// import 'dart:developer';

// import 'package:fittor/fittor.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';

// import '../../../core/util/app_color.dart';
// import '../../../core/util/assets.dart';
// import '../../../core/util/common_widgets.dart';
// import '../../restaurant_detail_view/controller/restaurant_detail_view_controller.dart';
// import '../../restaurant_detail_view/model/restaurent_details_model.dart';
// import 'widget/food_about_section.dart';
// import 'widget/food_add_ones_section.dart';
// import 'widget/food_bottom_cart_button.dart';
// import 'widget/food_customization_section.dart';
// import 'widget/food_info.dart';
// import 'widget/preview_order_bottom_sheet.dart';

// class FoodDetailsView extends StatefulWidget {
//   const FoodDetailsView({super.key});

//   @override
//   State<FoodDetailsView> createState() => _FoodDetailsViewState();
// }

// class _FoodDetailsViewState extends State<FoodDetailsView> {
//   final ScrollController _scrollController = ScrollController();
//   bool _isScrolled = false;

//   // Local variables extracted from arguments
//   late String foodName;
//   late String foodImage;
//   late String foodId;
//   late int? foodPrice;
//   late int? discountPrice;
//   late int? actualPrice;
//   late List<Customization>? customizations;
//   late List<AddOn>? addOns;

//   @override
//   void initState() {
//     super.initState();
//     _initializeScrollListener();
//     _extractArguments();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _syncControllerState();
//     });
//   }

//   void _extractArguments() {
//     final args = Get.arguments as Map<String, dynamic>?;
//     if (args != null) {
//       foodName = args['foodName'] ?? '';
//       foodImage = args['foodImage'] ?? '';
//       foodId = args['foodId'] ?? '';
//       foodPrice = args['foodPrice'];
//       discountPrice = args['discountPrice'];
//       actualPrice = args['actualPrice'];
//       customizations = args['customizations'];
//       addOns = args['addOns'];
//     }
//   }

//   /// Sync controller state - ensures selectedFoodItem is set and tracked
//   void _syncControllerState() {
//     final controller = Get.find<RestaurantDetailViewController>();

//     if (controller.selectedFoodItem == null || controller.selectedFoodItem!.foodId != foodId) {
//       log('🔄 Syncing controller state for food: $foodId');

//       final food = Food(
//         foodId: foodId,
//         foodName: foodName,
//         foodImage: foodImage,
//         foodPrice: foodPrice?.toDouble(),
//         discountPrice: discountPrice?.toDouble(),
//         actualPrice: actualPrice?.toDouble(),
//         customizations: customizations,
//         addOns: addOns,
//       );

//       controller.selectFoodItem(food);
//     }
//   }

//   void _initializeScrollListener() {
//     _scrollController.addListener(() {
//       const double scrollThreshold = 100;
//       final bool shouldBeScrolled = _scrollController.offset > scrollThreshold;

//       if (shouldBeScrolled != _isScrolled) {
//         setState(() {
//           _isScrolled = shouldBeScrolled;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<RestaurantDetailViewController>(
//       builder:
//           (controller) => Scaffold(
//             body: SizedBox(
//               height: MediaQuery.of(context).size.height,
//               width: MediaQuery.of(context).size.width,
//               child: Stack(
//                 children: [
//                   _buildBackgroundImage(),
//                   _buildCollapsibleAppBar(),
//                   _buildMainContent(controller),
//                   FoodBottomCartButton(
//                     foodId: foodId,
//                     hasSelectedAddOns: controller.getSelectedAddOns(foodId).isNotEmpty,
//                     onShowPreviewSheet: () => _showPreviewBottomSheet(controller),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//     );
//   }

//   Widget _buildBackgroundImage() {
//     if (_isScrolled) return SizedBox();

//     return Container(
//       width: context.wp(100),
//       height: 343,
//       decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(foodImage), fit: BoxFit.cover)),
//       child: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           child: Column(children: [20.h, _buildBackButton()]),
//         ),
//       ),
//     );
//   }

//   Widget _buildBackButton() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         height: 50,
//         width: 50,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(100),
//           border: Border.all(color: AppColor.white.withOpacity(0.4)),
//         ),
//         child: IconButton(onPressed: () => Get.back(), icon: SvgPicture.string(arrowBack)),
//       ),
//     );
//   }

//   Widget _buildCollapsibleAppBar() {
//     return AnimatedPositioned(
//       duration: Duration(milliseconds: 300),
//       top: 0,
//       left: 0,
//       right: 0,
//       height: _isScrolled ? 120 : 0,
//       child: AnimatedOpacity(
//         duration: Duration(milliseconds: 300),
//         opacity: _isScrolled ? 1.0 : 0.0,
//         child: Container(
//           decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(foodImage), fit: BoxFit.cover)),
//           child: Padding(
//             padding: EdgeInsets.only(left: 16, right: 16, top: 30),
//             child: Row(
//               children: [
//                 Container(
//                   height: 40,
//                   width: 40,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(100),
//                     border: Border.all(color: AppColor.white.withOpacity(0.4)),
//                   ),
//                   child: IconButton(
//                     padding: EdgeInsets.zero,
//                     onPressed: () => Get.back(),
//                     icon: SvgPicture.string(arrowBack),
//                   ),
//                 ),
//                 16.w,
//                 Expanded(
//                   child: text(
//                     text: foodName,
//                     color: AppColor.white,
//                     size: 16,
//                     fontWeight: FontWeight.w600,
//                     maxLines: 1,
//                     overFlow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMainContent(RestaurantDetailViewController controller) {
//     final hasCustomizations = customizations != null && customizations!.isNotEmpty;
//     final hasAddOns = addOns != null && addOns!.isNotEmpty;

//     return AnimatedPositioned(
//       duration: Duration(milliseconds: 300),
//       top: _isScrolled ? 120 - 20 : 343 - 20,
//       left: 0,
//       right: 0,
//       bottom: 100,
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppColor.scaffoldColor,
//           borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
//         ),
//         child: SingleChildScrollView(
//           controller: _scrollController,
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               20.h,
//               FoodInfoSection(
//                 foodName: foodName,
//                 foodId: foodId,
//                 hasCustomizations: hasCustomizations,
//                 controller: controller,
//               ),
//               FoodAboutSection(),
//               if (hasCustomizations) ...[
//                 FoodCustomizationsSection(customizations: customizations, foodId: foodId),
//                 20.h,
//               ],
//               if (hasAddOns) FoodAddOnsSection(addOns: addOns, foodId: foodId),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showPreviewBottomSheet(RestaurantDetailViewController controller) {
//     final foodItem = controller.selectedFoodItem;
//     if (foodItem == null) return;

//     final selectedAddOns = controller.getSelectedAddOns(foodId);

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppColor.scaffoldColor,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
//       isScrollControlled: true,
//       builder:
//           (context) => PreviewOrderBottomSheet(
//             foodItem: foodItem,
//             foodId: foodId,
//             customizations: customizations,
//             selectedAddOns: selectedAddOns,
//           ),
//     );
//   }
// }
