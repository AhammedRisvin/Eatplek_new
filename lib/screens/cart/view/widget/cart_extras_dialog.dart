import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/cart_extra_controller.dart';
import '../../model/extra_model.dart';

/// Shows the extras (add-ons / customizations) bottom-sheet dialog.
/// Call [showCartExtrasDialog] from the widget layer — do NOT use Get.dialog
/// directly, this handles registration automatically.
void showCartExtrasDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (_) => const CartExtrasDialog(),
  );
}

class CartExtrasDialog extends StatelessWidget {
  const CartExtrasDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final controller = Get.find<CartExtrasController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.6, 0.92],
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColor.scaffoldColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(responsive.spacing24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Drag handle ──────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.only(top: responsive.spacing12),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColor.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // ── Header ───────────────────────────────────────────────────────
              Obx(() {
                final foodName =
                    controller.extrasData.value?.foodName ??
                    controller.cartItem?.foodName ??
                    'Extras';
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing20,
                    vertical: responsive.spacing16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customise',
                              style: TextStyle(
                                fontSize: responsive.fontSize20,
                                fontWeight: FontWeight.w700,
                                color: AppColor.black,
                              ),
                            ),
                            SizedBox(height: responsive.spacing4),
                            Text(
                              foodName,
                              style: TextStyle(
                                fontSize: responsive.fontSize14,
                                fontWeight: FontWeight.w400,
                                color: AppColor.black.withOpacity(0.5),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: responsive.spacing36,
                          height: responsive.spacing36,
                          decoration: BoxDecoration(
                            color: AppColor.black.withOpacity(0.06),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: responsive.spacing18,
                            color: AppColor.black.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // ── Thin divider ──────────────────────────────────────────────
              Divider(
                height: 1,
                thickness: 1,
                color: AppColor.black.withOpacity(0.06),
              ),

              // ── Body ─────────────────────────────────────────────────────────
              Expanded(
                child: Obx(() {
                  // Loading state
                  if (controller.isLoading.value) {
                    return _buildLoadingState(responsive);
                  }

                  // Error state
                  if (controller.hasError.value) {
                    return _buildErrorState(controller, responsive);
                  }

                  final data = controller.extrasData.value;
                  if (data == null) return const SizedBox.shrink();

                  final hasAddOns =
                      data.addOns != null && data.addOns!.isNotEmpty;
                  final hasCustomizations =
                      data.customizations != null &&
                      data.customizations!.isNotEmpty;

                  // ── Empty state — nothing left to add ──────────────────────
                  if (!hasAddOns && !hasCustomizations) {
                    return _buildEmptyState(context, responsive);
                  }

                  return ListView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing20,
                      vertical: responsive.spacing16,
                    ),
                    children: [
                      // Add-ons section
                      if (hasAddOns) ...[
                        _SectionHeader(
                          title: 'Add-Ons',
                          subtitle: 'Enhance your meal',
                          responsive: responsive,
                        ),
                        SizedBox(height: responsive.spacing12),
                        ...data.addOns!.map(
                          (item) => _ExtraItemTile(
                            item: item,
                            isAddOn: true,
                            controller: controller,
                            responsive: responsive,
                          ),
                        ),
                      ],

                      // Spacing between sections
                      if (hasAddOns && hasCustomizations)
                        SizedBox(height: responsive.spacing24),

                      // Customizations section
                      if (hasCustomizations) ...[
                        _SectionHeader(
                          title: 'Customizations',
                          subtitle: 'Make it your own',
                          responsive: responsive,
                        ),
                        SizedBox(height: responsive.spacing12),
                        ...data.customizations!.map(
                          (item) => _ExtraItemTile(
                            item: item,
                            isAddOn: false,
                            controller: controller,
                            responsive: responsive,
                          ),
                        ),
                      ],

                      // Bottom padding for safe area
                      SizedBox(
                        height:
                            MediaQuery.of(context).padding.bottom +
                            responsive.spacing20,
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(ResponsiveHelper responsive) {
    return ListView.builder(
      padding: EdgeInsets.all(responsive.spacing20),
      itemCount: 4,
      itemBuilder:
          (_, index) => Padding(
            padding: EdgeInsets.only(bottom: responsive.spacing12),
            child: _ShimmerTile(responsive: responsive),
          ),
    );
  }

  Widget _buildErrorState(
    CartExtrasController controller,
    ResponsiveHelper responsive,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.spacing40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: responsive.spacing80,
              height: responsive.spacing80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: responsive.spacing36,
                color: Colors.red.withOpacity(0.6),
              ),
            ),
            SizedBox(height: responsive.spacing16),
            Text(
              'Couldn\'t load extras',
              style: TextStyle(
                fontSize: responsive.fontSize16,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
              ),
            ),
            SizedBox(height: responsive.spacing8),
            Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: responsive.fontSize13,
                color: AppColor.black.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.spacing24),
            GestureDetector(
              onTap: () {
                if (controller.cartItem != null) {
                  controller.openExtrasDialog(controller.cartItem!);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing24,
                  vertical: responsive.spacing12,
                ),
                decoration: BoxDecoration(
                  color: AppColor.appPrimary,
                  borderRadius: BorderRadius.circular(responsive.spacing40),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: responsive.fontSize14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ResponsiveHelper responsive) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.spacing40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: responsive.spacing80,
              height: responsive.spacing80,
              decoration: BoxDecoration(
                color: AppColor.appPrimary.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: responsive.spacing40,
                color: AppColor.appPrimary.withOpacity(0.5),
              ),
            ),
            SizedBox(height: responsive.spacing16),
            Text(
              'Empty',
              style: TextStyle(
                fontSize: responsive.fontSize16,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
              ),
            ),
            SizedBox(height: responsive.spacing8),
            Text(
              'No extras available for this item.',
              style: TextStyle(
                fontSize: responsive.fontSize13,
                color: AppColor.black.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.spacing24),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing24,
                  vertical: responsive.spacing12,
                ),
                decoration: BoxDecoration(
                  color: AppColor.appPrimary,
                  borderRadius: BorderRadius.circular(responsive.spacing40),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize: responsive.fontSize14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final ResponsiveHelper responsive;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: responsive.spacing20,
          decoration: BoxDecoration(
            color: AppColor.appPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: responsive.spacing10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: responsive.fontSize16,
                fontWeight: FontWeight.w700,
                color: AppColor.black,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: responsive.fontSize12,
                fontWeight: FontWeight.w400,
                color: AppColor.black.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Extra Item Tile ────────────────────────────────────────────────────────────

class _ExtraItemTile extends StatelessWidget {
  final ExtraItem item;
  final bool isAddOn;
  final CartExtrasController controller;
  final ResponsiveHelper responsive;

  const _ExtraItemTile({
    required this.item,
    required this.isAddOn,
    required this.controller,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.spacing10),
      child: Container(
        padding: EdgeInsets.all(responsive.spacing14),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(responsive.spacing14),
          border: Border.all(color: AppColor.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            if (item.image != null && item.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  responsive.smallBorderRadius,
                ),
                child: image(
                  url: item.image!,
                  width: responsive.spacing55,
                  height: responsive.spacing55,
                  borderRadius: BorderRadius.circular(
                    responsive.smallBorderRadius,
                  ),
                ),
              )
            else
              Container(
                width: responsive.spacing55,
                height: responsive.spacing55,
                decoration: BoxDecoration(
                  color: AppColor.appPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(
                    responsive.smallBorderRadius,
                  ),
                ),
                child: Icon(
                  isAddOn
                      ? Icons.add_shopping_cart_rounded
                      : Icons.tune_rounded,
                  color: AppColor.appPrimary.withOpacity(0.5),
                  size: responsive.spacing24,
                ),
              ),

            SizedBox(width: responsive.spacing12),

            // Name + Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? '',
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: responsive.spacing4),
                  Text(
                    'Rs.${item.price ?? 0}',
                    style: TextStyle(
                      fontSize: responsive.fontSize13,
                      fontWeight: FontWeight.w500,
                      color: AppColor.appPrimary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: responsive.spacing12),

            // Quantity control
            Obx(() {
              final isUpdating = controller.updatingItems.contains(item.id);
              final qty =
                  isAddOn
                      ? (controller.selectedAddOnQty[item.id] ?? 0)
                      : (controller.selectedCustomizationQty[item.id] ?? 0);

              if (isUpdating) {
                return SizedBox(
                  width: responsive.spacing80,
                  child: Center(
                    child: SizedBox(
                      width: responsive.spacing20,
                      height: responsive.spacing20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.appPrimary,
                      ),
                    ),
                  ),
                );
              }

              if (qty == 0) {
                // Show "Add" button
                return GestureDetector(
                  onTap:
                      () =>
                          isAddOn
                              ? controller.incrementAddOn(item)
                              : controller.incrementCustomization(item),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing16,
                      vertical: responsive.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.appPrimary,
                      borderRadius: BorderRadius.circular(responsive.spacing40),
                    ),
                    child: Text(
                      'Add',
                      style: TextStyle(
                        fontSize: responsive.fontSize13,
                        fontWeight: FontWeight.w600,
                        color: AppColor.white,
                      ),
                    ),
                  ),
                );
              }

              // Show quantity stepper
              return Container(
                height: responsive.spacing36,
                decoration: BoxDecoration(
                  color: AppColor.appPrimary,
                  borderRadius: BorderRadius.circular(responsive.spacing40),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Minus
                    GestureDetector(
                      onTap:
                          () =>
                              isAddOn
                                  ? controller.decrementAddOn(item)
                                  : controller.decrementCustomization(item),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.spacing10,
                        ),
                        child: Icon(
                          Icons.remove_rounded,
                          color: AppColor.white,
                          size: responsive.spacing16,
                        ),
                      ),
                    ),
                    // Count
                    Text(
                      '$qty',
                      style: TextStyle(
                        fontSize: responsive.fontSize14,
                        fontWeight: FontWeight.w700,
                        color: AppColor.white,
                      ),
                    ),
                    // Plus
                    GestureDetector(
                      onTap:
                          () =>
                              isAddOn
                                  ? controller.incrementAddOn(item)
                                  : controller.incrementCustomization(item),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.spacing10,
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: AppColor.white,
                          size: responsive.spacing16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer Tile ──────────────────────────────────────────────────────────────

class _ShimmerTile extends StatefulWidget {
  final ResponsiveHelper responsive;
  const _ShimmerTile({required this.responsive});

  @override
  State<_ShimmerTile> createState() => _ShimmerTileState();
}

class _ShimmerTileState extends State<_ShimmerTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    return AnimatedBuilder(
      animation: _anim,
      builder:
          (_, __) => Container(
            padding: EdgeInsets.all(r.spacing14),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(r.spacing14),
              border: Border.all(color: AppColor.black.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  width: r.spacing55,
                  height: r.spacing55,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(_anim.value),
                    borderRadius: BorderRadius.circular(r.smallBorderRadius),
                  ),
                ),
                SizedBox(width: r.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: r.spacing14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(_anim.value),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: r.spacing8),
                      Container(
                        height: r.spacing12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(_anim.value),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: r.spacing12),
                Container(
                  width: 60,
                  height: r.spacing32,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(_anim.value),
                    borderRadius: BorderRadius.circular(r.spacing40),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
