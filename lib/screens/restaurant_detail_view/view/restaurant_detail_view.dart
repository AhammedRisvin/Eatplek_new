import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../../core/util/common_widgets.dart';
import '../../../core/util/responsive_helper.dart';
import '../controller/restaurant_detail_view_controller.dart';
import 'widget/banner_section.dart';
import 'widget/bottom_cart_bar.dart';
import 'widget/category_section.dart';
import 'widget/food_grid_section.dart';

class RestaurantDetailView extends StatefulWidget {
  const RestaurantDetailView({super.key});

  @override
  State<RestaurantDetailView> createState() => _RestaurantDetailViewState();
}

class _RestaurantDetailViewState extends State<RestaurantDetailView> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final shouldBeScrolled = _scrollController.offset > 80;
    if (shouldBeScrolled != _isScrolled) {
      setState(() => _isScrolled = shouldBeScrolled);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GetBuilder<RestaurantDetailViewController>(
      id: 'main_content',
      builder: (controller) {
        return Scaffold(
          body: Stack(
            children: [
              SizedBox(
                height: responsive.screenHeight,
                width: responsive.screenWidth,
                child: Stack(
                  children: [
                    // Background header image
                    _buildHeader(controller, responsive),
                    // Collapsible app bar on scroll
                    _buildCollapsibleAppBar(responsive),
                    // Main scrollable content card
                    _buildContentCard(controller, responsive),
                  ],
                ),
              ),
              // Floating bottom cart bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: const BottomCartBar(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Static header (visible before scroll) ─────────────────────────────────
  Widget _buildHeader(
    RestaurantDetailViewController controller,
    ResponsiveHelper responsive,
  ) {
    if (_isScrolled) return const SizedBox.shrink();

    return Container(
      width: responsive.screenWidth,
      height: responsive.spacing201,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/restaurantBg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
          child: Row(
            children: [
              _buildCircleButton(
                child: SvgPicture.string(arrowBack),
                onTap: () => Navigator.of(context).pop(),
                responsive: responsive,
              ),
              SizedBox(width: responsive.spacing10),
              text(
                text: 'Restaurant',
                color: AppColor.white,
                size: responsive.fontSize20,
                fontWeight: FontWeight.w600,
              ),
              const Spacer(),
              _buildCircleButton(
                child: Image.asset(mapPng),
                onTap: () {},
                responsive: responsive,
              ),
              SizedBox(width: responsive.spacing8),
              _buildCircleButton(
                child: Image.asset(sharePng),
                onTap: () {},
                responsive: responsive,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required Widget child,
    required VoidCallback onTap,
    required ResponsiveHelper responsive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: responsive.iconSizeLarge,
        width: responsive.iconSizeLarge,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.white.withOpacity(0.15),
          border: Border.all(color: AppColor.white.withOpacity(0.35)),
        ),
        child: Center(child: child),
      ),
    );
  }

  // ── Collapsible app bar (appears after scroll) ────────────────────────────
  Widget _buildCollapsibleAppBar(ResponsiveHelper responsive) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      top: 0,
      left: 0,
      right: 0,
      height: _isScrolled ? responsive.spacing120 : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _isScrolled ? 1.0 : 0.0,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/restaurantBg.png'),
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.only(
            left: responsive.spacing16,
            right: responsive.spacing16,
            top: responsive.spacing30,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  height: responsive.spacing40,
                  width: responsive.spacing40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.white.withOpacity(0.4)),
                  ),
                  child: Center(child: SvgPicture.string(arrowBack)),
                ),
              ),
              SizedBox(width: responsive.spacing16),
              text(
                text: 'Restaurant',
                color: AppColor.white,
                size: responsive.fontSize16,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Main content card ─────────────────────────────────────────────────────
  Widget _buildContentCard(
    RestaurantDetailViewController controller,
    ResponsiveHelper responsive,
  ) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      top: _isScrolled ? responsive.spacing120 : responsive.spacing100,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.scaffoldColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(responsive.largeBorderRadius),
            topRight: Radius.circular(responsive.largeBorderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Skeletonizer(
          enabled: controller.isLoading,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.hasError)
                  errorState(
                    message: controller.errorMessage,
                    onRetry: () {
                      if (controller.restaurantId != null) {
                        controller.getRestaurantDetailsFn(
                          restaurantId: controller.restaurantId!,
                        );
                      }
                    },
                  )
                else if (controller.isLoading)
                  _buildLoadingSkeleton(responsive)
                else if (controller.restaurantData.isEmpty)
                  emptyState(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'No items available',
                    subtitle:
                        'This restaurant has no food items available right now.',
                  )
                else ...[
                  BannerSection(controller: controller)
                      .animate()
                      .fade(duration: 400.ms)
                      .slideY(
                        begin: 0.05,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      ),
                  SizedBox(height: responsive.spacing16),
                  CategorySection(
                    controller: controller,
                  ).animate().fade(duration: 400.ms, delay: 80.ms),
                  SizedBox(height: responsive.spacing16),
                  FoodGridSection(
                    controller: controller,
                  ).animate().fade(duration: 400.ms, delay: 150.ms),
                  SizedBox(height: responsive.spacing100),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Skeleton ──────────────────────────────────────────────────────────────
  Widget _buildLoadingSkeleton(ResponsiveHelper responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(responsive.spacing16),
          child: Container(
            height: responsive.spacing180,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
            ),
          ),
        ),
        SizedBox(height: responsive.spacing16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
          child: Container(
            height: responsive.spacing24,
            width: responsive.spacing150,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(responsive.spacing8),
            ),
          ),
        ),
        SizedBox(height: responsive.spacing14),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
          child: SizedBox(
            height: responsive.spacing50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, _) => SizedBox(width: responsive.spacing10),
              itemBuilder:
                  (_, _) => Container(
                    width: responsive.spacing100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(responsive.spacing40),
                    ),
                  ),
            ),
          ),
        ),
        SizedBox(height: responsive.spacing20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: responsive.gridCrossAxisCount,
              mainAxisSpacing: responsive.gridMainAxisSpacing,
              crossAxisSpacing: responsive.gridCrossAxisSpacing,
              childAspectRatio: responsive.gridChildAspectRatioForFood,
            ),
            itemCount: 6,
            itemBuilder:
                (_, _) => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(
                      responsive.largeBorderRadius,
                    ),
                  ),
                ),
          ),
        ),
        SizedBox(height: responsive.spacing100),
      ],
    );
  }
}
