import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../../core/util/common_widgets.dart';
import '../../../core/util/responsive_helper.dart';
import '../../home/model/new_home_model.dart';
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

  // ── Resolved from Get.arguments (Vendor) ─────────────────────────────────
  Vendor? _vendor;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Extract vendor passed as argument — same object used in onRestaurantTapped
    final args = Get.arguments;
    if (args is Vendor) {
      _vendor = args;
    }
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

  // ── Open Google Maps with vendor lat/lng ───────────────────────────────────
  Future<void> _openMap() async {
    final lat = _vendor?.location?.latitude;
    final lng = _vendor?.location?.longitude;
    if (lat == null || lng == null) return;

    final name = Uri.encodeComponent(_vendor?.hotelName ?? 'Restaurant');
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$name',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback: plain coordinates link
      final fallback = Uri.parse('geo:$lat,$lng?q=$lat,$lng($name)');
      if (await canLaunchUrl(fallback)) {
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      }
    }
  }

  // ── Share restaurant name + place as plain text ───────────────────────────
  Future<void> _shareRestaurant() async {
    final name = _vendor?.hotelName;
    final place = _vendor?.place;
    if (name == null && place == null) return;

    final parts = [if (name != null) name, if (place != null) place];

    await Share.share(
      'Check out ${parts.join(', ')} on EatPlek! 🍽️',
      subject: name ?? 'EatPlek Restaurant',
    );
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
                    _buildHeaderBg(responsive),
                    _buildHeaderButtons(responsive),
                    _buildCollapsibleAppBar(responsive),
                    _buildContentCard(controller, responsive),
                  ],
                ),
              ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomCartBar(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderBg(ResponsiveHelper responsive) {
    if (_isScrolled) return const SizedBox.shrink();

    final double headerH = responsive.topPadding + responsive.spacing160;

    return Container(
      width: responsive.screenWidth,
      height: headerH,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/restaurantBg.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildHeaderButtons(ResponsiveHelper responsive) {
    if (_isScrolled) return const SizedBox.shrink();

    final hasLocation =
        _vendor?.location?.latitude != null &&
        _vendor?.location?.longitude != null;

    final hasShareInfo = _vendor?.hotelName != null || _vendor?.place != null;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing16,
          vertical: responsive.spacing12,
        ),
        child: Row(
          children: [
            // Back button
            _circleBtn(
              child: SvgPicture.string(
                arrowBack,
                width: responsive.spacing15,
                height: responsive.spacing15,
              ),
              onTap: () => Navigator.of(context).pop(),
              responsive: responsive,
            ),

            SizedBox(width: responsive.spacing10),

            // Restaurant name from vendor
            Expanded(
              child: text(
                text: _vendor?.hotelName ?? 'Restaurant',
                color: AppColor.white,
                size: responsive.fontSize18,
                fontWeight: FontWeight.w600,
                maxLines: 1,
                overFlow: TextOverflow.ellipsis,
              ),
            ),

            // Map button — only shown when lat/lng available
            if (hasLocation) ...[
              SizedBox(width: responsive.spacing8),
              _circleBtn(
                child: Image.asset(
                  mapPng,
                  width: responsive.spacing20,
                  height: responsive.spacing20,
                ),
                onTap: _openMap,
                responsive: responsive,
              ),
            ],

            // Share button — only shown when name or place available
            if (hasShareInfo) ...[
              SizedBox(width: responsive.spacing8),
              _circleBtn(
                child: Image.asset(
                  sharePng,
                  width: responsive.spacing20,
                  height: responsive.spacing20,
                ),
                onTap: _shareRestaurant,
                responsive: responsive,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _circleBtn({
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
          color: AppColor.white.withOpacity(0.18),
          border: Border.all(color: AppColor.white.withOpacity(0.4), width: 1),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildCollapsibleAppBar(ResponsiveHelper responsive) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      top: 0,
      left: 0,
      right: 0,
      height: _isScrolled ? responsive.topPadding + responsive.spacing60 : 0,
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
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.spacing16,
                vertical: responsive.spacing8,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: responsive.spacing40,
                      width: responsive.spacing40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.white.withOpacity(0.4),
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.string(
                          arrowBack,
                          width: responsive.spacing20,
                          height: responsive.spacing20,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: responsive.spacing16),
                  Expanded(
                    child: text(
                      text: _vendor?.hotelName ?? 'Restaurant',
                      color: AppColor.white,
                      size: responsive.fontSize16,
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
      ),
    );
  }

  Widget _buildContentCard(
    RestaurantDetailViewController controller,
    ResponsiveHelper responsive,
  ) {
    final double cardTopNormal = responsive.topPadding + responsive.spacing60;
    final double cardTopScrolled = responsive.topPadding + responsive.spacing60;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      top: _isScrolled ? cardTopScrolled : cardTopNormal,
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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder:
                  (_, _) => Container(
                    width: responsive.spacing100,
                    margin: EdgeInsets.only(right: responsive.spacing10),
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
