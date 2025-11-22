// import 'package:fittor/fittor.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../../core/util/app_color.dart';
// import '../../../../core/util/common_widgets.dart';
// import '../../../restaurant_detail_view/controller/restaurant_detail_view_controller.dart';

// class FoodBottomCartButton extends StatefulWidget {
//   final String foodId;
//   final bool hasSelectedAddOns;
//   final VoidCallback onShowPreviewSheet;

//   const FoodBottomCartButton({
//     super.key,
//     required this.foodId,
//     required this.hasSelectedAddOns,
//     required this.onShowPreviewSheet,
//   });

//   @override
//   State<FoodBottomCartButton> createState() => _FoodBottomCartButtonState();
// }

// class _FoodBottomCartButtonState extends State<FoodBottomCartButton> {
//   bool _isPreviewSheetOpen = false;

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<RestaurantDetailViewController>(
//       id: 'total_price',
//       builder: (controller) {
//         final quantity = controller.getCustomizationCount(widget.foodId);
//         if (quantity == 0) {
//           return SizedBox.shrink();
//         }

//         return AnimatedPositioned(
//           duration: Duration(milliseconds: 300),
//           bottom: 0,
//           left: 0,
//           right: 0,
//           height: 100,
//           child: Container(
//             decoration: BoxDecoration(
//               color: AppColor.white,
//               border: BorderDirectional(top: BorderSide(color: AppColor.black.withOpacity(0.1), width: 1)),
//               boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.08), blurRadius: 14, offset: Offset(0, -2))],
//             ),
//             padding: EdgeInsets.only(top: 11, left: 16, right: 16, bottom: 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         children: [
//                           text(
//                             text: 'Total Amount',
//                             size: 14,
//                             fontWeight: FontWeight.w400,
//                             color: AppColor.black.withOpacity(0.6),
//                           ),
//                           if (widget.hasSelectedAddOns) ...[
//                             4.w,
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() => _isPreviewSheetOpen = !_isPreviewSheetOpen);
//                                 widget.onShowPreviewSheet();
//                               },
//                               child: AnimatedRotation(
//                                 turns: _isPreviewSheetOpen ? 0.5 : 0.0,
//                                 duration: Duration(milliseconds: 300),
//                                 child: Icon(
//                                   Icons.keyboard_arrow_down_rounded,
//                                   color: AppColor.black.withOpacity(0.6),
//                                   size: 18,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                       text(
//                         text: '₹${controller.getTotalPrice().toStringAsFixed(0)}',
//                         size: 22,
//                         fontWeight: FontWeight.w600,
//                         color: AppColor.black,
//                       ),
//                     ],
//                   ),
//                 ),
//                 button(
//                   name: 'Add to Cart',
//                   onTap: () {
//                     controller.logAndAddToCartFromFoodDetails();
//                     Get.back();
//                   },
//                   width: 125,
//                   height: 50,
//                   color: AppColor.appPrimary,
//                   textColor: AppColor.white,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16,
//                   borderRadius: BorderRadius.circular(100),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
