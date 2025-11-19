import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:svg_flutter/svg.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../../core/util/common_widgets.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(children: [_buildSearchField(), 20.h, _buildRestaurantsGrid()]),
      ),
    );
  }

  Widget _buildRestaurantsGrid() {
    return Container();
    //  GetBuilder<HomeController>(
    //   id: HomeController.restaurantsId,
    //   init: HomeController(),
    //   builder: (controller) {
    //     if (controller.isLoadingRestaurants) {
    //       return const Center(child: CircularProgressIndicator());
    //     }

    //     return GridView.builder(
    //       shrinkWrap: true,
    //       padding: EdgeInsets.zero,
    //       physics: const NeverScrollableScrollPhysics(),
    //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //         crossAxisCount: 2,
    //         mainAxisSpacing: 16,
    //         crossAxisSpacing: 12,
    //         childAspectRatio: Get.height * 0.001,
    //       ),
    //       itemCount: controller.restaurants.length,
    //       itemBuilder: (context, index) {
    //         final restaurant = controller.restaurants[index];
    //         return RestaurantCardWidget(restaurant: restaurant, onTap: () => controller.onRestaurantTapped(restaurant));
    //       },
    //     );
    //   },
    // );
  }

  Widget _buildSearchField() {
    return buildCommonTextFormField(
      hintText: 'Search Restaurant',
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      controller: TextEditingController(),
      context: context,
      hintTextSize: 13,
      bgColor: AppColor.white,
      radius: 10,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SvgPicture.string(searchSvg, color: const Color(0xFF474747)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final bg = AppColor.scaffoldColor;

    return AppBar(
      elevation: 0,
      backgroundColor: bg,
      centerTitle: true,
      leadingWidth: 80,
      title: text(text: 'Order Details', size: 18, fontWeight: FontWeight.w600),
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.white,
              border: Border.all(color: Colors.black.withOpacity(0.06), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
            ),
            padding: const EdgeInsets.all(12),
            child: SvgPicture.string(arrowBack2),
          ),
        ),
      ),
    );
  }
}
