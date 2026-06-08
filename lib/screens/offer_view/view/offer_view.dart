import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/util/app_color.dart';
import '../controller/offer_controller.dart';
import 'widget/offer_food_grid.dart';
import 'widget/offer_header.dart';
import 'widget/offer_loading_grid.dart';
import 'widget/offer_preference_row.dart';

class OfferView extends StatefulWidget {
  const OfferView({super.key});

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView> {
  late final OfferController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        Get.isRegistered<OfferController>()
            ? Get.find<OfferController>()
            : Get.put(OfferController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColor.appPrimary,
          onRefresh: _controller.refreshOffers,
          child: CustomScrollView(
            controller: _controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: const [
              SliverToBoxAdapter(child: OfferHeader()),
              SliverToBoxAdapter(child: OfferPreferenceRow()),
              SliverToBoxAdapter(child: _OfferContent()),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferContent extends StatelessWidget {
  const _OfferContent();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OfferController>(
      id: OfferController.foodsId,
      builder: (controller) {
        if (controller.isLoading) {
          return const Skeletonizer(
            enabled: true,
            child: OfferLoadingGrid(),
          );
        }

        return const OfferFoodGrid();
      },
    );
  }
}
