import 'dart:developer';

import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:eatplek_app/screens/bottom_nav/controller/bottom_nav_controller.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../../core/util/common_widgets.dart';
import '../../../core/util/responsive_helper.dart';
import '../controller/profile_controller.dart';
import 'widget/profile_tile.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Scaffold(
      body: Stack(
        children: [
          _buildHeader(context, responsive),
          _buildContentCard(context, responsive),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, ResponsiveHelper responsive) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/image/33b1d8f643bc4393955ae79fcd8039e7fd5963e9.jpg',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Color.fromRGBO(4, 46, 96, 0.78),
            BlendMode.darken,
          ),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 48),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.spacing20),
              child: text(
                text: 'Profile',
                size: responsive.fontSize18,
                fontWeight: FontWeight.w700,
                color: AppColor.white,
              ),
            ),
            SizedBox(height: responsive.spacing24),
            _buildProfileInfo(responsive),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(ResponsiveHelper responsive) {
    return Obx(() {
      final isLoading = _controller.isLoading.value;
      final user = _controller.userData.value;
      final displayName = user?.name ?? 'Loading...';
      final displayPhone =
          user != null
              ? '${user.dialCode ?? ''} ${user.phone ?? ''}'.trim()
              : '';
      final displayImage =
          user?.profileImage ??
          'https://www.w3schools.com/howto/img_avatar.png';

      return Skeletonizer(
        enabled: isLoading,
        ignoreContainers: true,
        child: Column(
          children: [
            // Avatar with edit badge
            GestureDetector(
              onTap: isLoading ? null : () => _showEditNameSheet(displayName),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColor.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: image(
                        url: displayImage,
                        width: responsive.spacing80,
                        height: responsive.spacing80,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: responsive.spacing24,
                      height: responsive.spacing24,
                      decoration: BoxDecoration(
                        color: AppColor.appPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColor.white, width: 1.5),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: responsive.fontSize11,
                        color: AppColor.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: responsive.spacing12),

            if (!isLoading) ...[
              GestureDetector(
                onTap: () => _showEditNameSheet(displayName),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    text(
                      text: displayName,
                      size: responsive.fontSize18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.white,
                    ),
                    SizedBox(width: responsive.spacing6),
                    Icon(
                      Icons.edit_rounded,
                      size: responsive.fontSize13,
                      color: AppColor.white.withOpacity(0.65),
                    ),
                  ],
                ),
              ),
              if (displayPhone.isNotEmpty) ...[
                SizedBox(height: responsive.spacing4),
                text(
                  text: displayPhone,
                  size: responsive.fontSize13,
                  fontWeight: FontWeight.w400,
                  color: AppColor.white.withOpacity(0.7),
                ),
              ],
            ] else
              Bone.text(fontSize: 18, words: 2),
          ],
        ),
      );
    });
  }

  // ── White card overlapping header ─────────────────────────────────────────
  Widget _buildContentCard(BuildContext context, ResponsiveHelper responsive) {
    return Positioned(
      top: context.hp(32),
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Obx(() {
          if (_controller.hasError.value) {
            return errorState(
              message: _controller.errorMessage.value,
              onRetry: _controller.refresh,
            );
          }
          return _buildList(responsive);
        }),
      ),
    );
  }

  Widget _buildList(ResponsiveHelper responsive) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: responsive.spacing20),
          _sectionLabel('Account', responsive),
          SizedBox(height: responsive.spacing12),
          ..._accountTiles(),
          SizedBox(height: responsive.spacing24),
          _sectionLabel('Support', responsive),
          SizedBox(height: responsive.spacing12),
          ..._supportTiles(),
          SizedBox(height: responsive.spacing80),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, ResponsiveHelper responsive) {
    return text(
      text: label.toUpperCase(),
      size: responsive.fontSize11,
      fontWeight: FontWeight.w600,
      color: AppColor.black.withOpacity(0.4),
      letterSpacing: 0.8,
    );
  }

  List<Widget> _accountTiles() {
    return [
          ProfileTile(
            title: 'My Orders',
            svgIcon: myOrderSvg,
            onTap: () => Get.find<BottomNavController>().setBottomBarIndex(1),
          ),
        ]
        .animate(interval: 60.ms)
        .fade(duration: 300.ms)
        .slideX(begin: 0.06, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  List<Widget> _supportTiles() {
    return [
          ProfileTile(
            title: 'Help Center',
            svgIcon: helpCentreSvg,
            onTap: () => log('Help Center tapped'),
          ),
          ProfileTile(
            title: 'FAQ',
            svgIcon: faqSvg,
            onTap: () => log('FAQ tapped'),
          ),
          ProfileTile(
            title: 'Privacy Policy',
            svgIcon: privacySvg,
            onTap: () => log('Privacy tapped'),
          ),
          ProfileTile(
            title: 'Terms & Conditions',
            svgIcon: termsSvg,
            onTap: () => log('Terms tapped'),
          ),
          ProfileTile(
            title: 'Refer and Earn',
            svgIcon: referSvg,
            onTap: () => Get.toNamed(Routes.referScreen),
          ),
          ProfileTile(
            title: 'Logout',
            svgIcon: myOrderSvg,
            titleColor: AppColor.redColor,
            onTap: _confirmLogout,
          ),
        ]
        .animate(interval: 50.ms)
        .fade(duration: 300.ms)
        .slideX(begin: 0.06, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: text(text: 'Logout?', size: 18, fontWeight: FontWeight.w700),
        content: text(
          text: 'Are you sure you want to log out of EatPlek?',
          size: 14,
          color: AppColor.black.withOpacity(0.55),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(),
            child: text(
              text: 'Cancel',
              size: 14,
              fontWeight: FontWeight.w600,
              color: AppColor.black.withOpacity(0.5),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.redColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.of(Get.context!).pop();
              await Store.clear();
              Get.offAllNamed(Routes.splash);
            },
            child: text(
              text: 'Logout',
              size: 14,
              fontWeight: FontWeight.w600,
              color: AppColor.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameSheet(String currentName) {
    final nameController = TextEditingController(text: currentName);
    final isUpdating = false.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColor.black.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  text(
                    text: 'Edit Name',
                    size: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: 4),
                  text(
                    text: 'Update your display name',
                    size: 13,
                    color: AppColor.black.withOpacity(0.45),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(
                        color: AppColor.black.withOpacity(0.35),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F8F8),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColor.black.withOpacity(0.08),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColor.black.withOpacity(0.08),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColor.appPrimary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    final updating = isUpdating.value;
                    return ValueListenableBuilder<TextEditingValue>(
                      valueListenable: nameController,
                      builder: (_, value, _) {
                        final trimmed = value.text.trim();
                        final isDisabled = trimmed.length < 2 || updating;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                isDisabled
                                    ? null
                                    : () async {
                                      if (trimmed == currentName) {
                                        Get.snackbar(
                                          'Same Name',
                                          'Enter a different name to update.',
                                          backgroundColor: Colors.orange,
                                          colorText: Colors.white,
                                        );
                                        return;
                                      }
                                      isUpdating.value = true;
                                      final success = await _controller
                                          .updateName(trimmed);
                                      isUpdating.value = false;
                                      if (success) {
                                        Navigator.of(Get.context!).pop();
                                        Get.snackbar(
                                          'Updated!',
                                          'Name updated successfully.',
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                        );
                                      } else {
                                        Get.snackbar(
                                          'Error',
                                          'Failed to update name. Try again.',
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.appPrimary,
                              disabledBackgroundColor: AppColor.appPrimary
                                  .withOpacity(0.4),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child:
                                updating
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : text(
                                      text: 'Update',
                                      size: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
    );
  }
}
