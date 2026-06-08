import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';
import '../../controller/offer_controller.dart';
import 'offer_food_card.dart';

class OfferFoodGrid extends StatelessWidget {
  const OfferFoodGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GetBuilder<OfferController>(
      id: OfferController.foodsId,
      builder: (controller) {
        if (controller.hasError) {
          return errorState(
            message: controller.errorMessage,
            onRetry: controller.retryFetch,
          );
        }

        if (controller.offers.isEmpty) {
          return emptyState(
            icon: Icons.local_offer_rounded,
            title: 'No offers today',
            subtitle: 'Try another delivery preference or check again later.',
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: responsive.gridCrossAxisCount,
                  mainAxisSpacing: responsive.gridMainAxisSpacing,
                  crossAxisSpacing: responsive.gridCrossAxisSpacing,
                  childAspectRatio: responsive.gridChildAspectRatioForFood,
                ),
                itemCount: controller.offers.length,
                itemBuilder:
                    (context, index) => OfferFoodCard(
                      offer: controller.offers[index],
                      animationIndex: index,
                    ),
              ),
              if (controller.isLoadingMore) ...[
                const SizedBox(height: 18),
                const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
