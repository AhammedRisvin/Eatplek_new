// import 'package:fittor/fittor.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../../core/util/app_color.dart';
// import '../../../../core/util/common_widgets.dart';
// import '../../../restaurant_detail_view/controller/restaurant_detail_view_controller.dart';
// import '../../../restaurant_detail_view/model/restaurent_details_model.dart';
// import '../../../restaurant_detail_view/view/widget/quantity_control_widget.dart';

// class FoodCustomizationsSection extends StatelessWidget {
//   final List<Customization>? customizations;
//   final String foodId;

//   const FoodCustomizationsSection({super.key, required this.customizations, required this.foodId});

//   @override
//   Widget build(BuildContext context) {
//     if (customizations == null || customizations!.isEmpty) {
//       return SizedBox();
//     }

//     return GetBuilder<RestaurantDetailViewController>(
//       id: 'customization_widget',
//       builder: (controller) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   height: 16,
//                   width: 4,
//                   decoration: BoxDecoration(color: AppColor.appPrimary, borderRadius: BorderRadius.circular(100)),
//                   margin: EdgeInsets.only(right: 6),
//                 ),
//                 text(text: 'Customize Your Food', size: 16, fontWeight: FontWeight.w600),
//               ],
//             ),
//             10.h,
//             ListView.separated(
//               physics: NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               padding: EdgeInsets.zero,
//               itemBuilder: (context, index) {
//                 final customization = customizations![index];
//                 return _buildCustomizationTile(controller, customization);
//               },
//               separatorBuilder: (context, index) => 16.h,
//               itemCount: customizations!.length,
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildCustomizationTile(RestaurantDetailViewController controller, Customization customization) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         color: AppColor.white,
//         boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
//       ),
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 text(text: customization.name ?? '', size: 14, fontWeight: FontWeight.w600, color: AppColor.black),
//                 4.h,
//                 text(
//                   text: '₹ ${customization.price?.toInt() ?? 0}',
//                   size: 12,
//                   fontWeight: FontWeight.w500,
//                   color: AppColor.black.withOpacity(0.6),
//                 ),
//               ],
//             ),
//           ),
//           GetBuilder<RestaurantDetailViewController>(
//             id: 'customization_widget',
//             builder: (controller) {
//               final quantity = controller.getCustomizationCount(foodId);
//               return QuantityControlWidget(
//                 quantity: quantity,
//                 onIncrease: () => controller.toggleCustomization(customization.customizationId ?? ''),
//                 onDecrease: controller.decreaseCustomization,
//                 showRemoveButton: quantity > 0,
//                 buttonSize: 32,
//                 iconSize: 14,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
