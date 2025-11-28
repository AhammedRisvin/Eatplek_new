import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../../core/util/common_widgets.dart';
import '../../home/model/new_home_model.dart';
import '../view_model/pre_book_controller.dart';
import 'widget/pre_book_about_section.dart' show PrebookAboutSection;
import 'widget/pre_book_bottom_cart_button.dart';
import 'widget/pre_book_info.dart';

class PrebookDetailView extends StatefulWidget {
  const PrebookDetailView({super.key});

  @override
  State<PrebookDetailView> createState() => _PrebookDetailViewState();
}

class _PrebookDetailViewState extends State<PrebookDetailView> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // Local variables extracted from arguments
  late String prebookName;
  late String prebookImage;
  late String prebookId;
  late double? basePrice;
  late double? discountPrice;
  late double? effectivePrice;
  late PrebookList? prebookData;

  @override
  void initState() {
    super.initState();
    _extractArguments();
    _scrollController.addListener(_onScroll);
  }

  void _extractArguments() {
    final args = Get.arguments as PrebookList?;
    if (args != null) {
      prebookData = args;
      prebookName = args.foodName ?? '';
      prebookImage = args.foodImage ?? '';
      prebookId = args.foodId ?? '';
      basePrice = args.basePrice;
      discountPrice = args.discountPrice;
      effectivePrice = args.effectivePrice;
    }
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 100;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
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
    return GetBuilder<PrebookDetailController>(
      init: PrebookDetailController(),
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
                  PrebookBottomCartButton(prebookId: prebookId, controller: controller),
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
      decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(prebookImage), fit: BoxFit.cover)),
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
        child: IconButton(onPressed: () => Get.back(), icon: SvgPicture.string(arrowBack)),
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
          decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(prebookImage), fit: BoxFit.cover)),
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
                    text: prebookName,
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

  Widget _buildMainContent(PrebookDetailController controller) {
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
              PrebookInfoSection(
                prebookName: prebookName,
                prebookId: prebookId,
                controller: controller,
                prebookData: prebookData,
              ),
              PrebookAboutSection(prebookData: prebookData),
            ],
          ),
        ),
      ),
    );
  }
}
