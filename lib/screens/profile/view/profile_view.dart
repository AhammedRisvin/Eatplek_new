import 'dart:developer';

import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:eatplek_app/screens/bottom_nav/controller/bottom_nav_controller.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../../core/util/common_widgets.dart';
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
    return Scaffold(
      body: Stack(
        children: [
          _buildProfileHeader(context),
          _buildOverlappingContent(context),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: context.wp(100),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/image/33b1d8f643bc4393955ae79fcd8039e7fd5963e9.jpg',
              ),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Color.fromRGBO(0, 0, 0, 0.5),
                BlendMode.darken,
              ),
            ),
          ),
          padding: const EdgeInsets.only(bottom: 41),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAppBar(),
                const SizedBox(height: 30),
                _buildProfileInfo(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Center(
      child: text(
        text: 'Profile',
        size: 18,
        fontWeight: FontWeight.w600,
        color: AppColor.white,
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Obx(() {
      final isLoading = _controller.isLoading.value;
      final user = _controller.userData.value;

      final displayName = user?.name ?? 'Loading Name';
      final displayPhone =
          user != null
              ? '${user.dialCode ?? ''} ${user.phone ?? ''}'.trim()
              : '+91 9999999999';
      final displayImage =
          user?.profileImage ??
          'https://www.w3schools.com/howto/img_avatar.png';

      return Skeletonizer(
        enabled: isLoading,
        ignoreContainers: true,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.white, width: 2),
                borderRadius: BorderRadius.circular(100),
              ),
              margin: const EdgeInsets.only(bottom: 10),
              child: image(
                url: displayImage,
                width: 70,
                height: 70,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Bone.text(fontSize: isLoading ? 18 : 0, words: 2),
            if (!isLoading) ...[
              GestureDetector(
                onTap: () => _showEditNameBottomSheet(displayName),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    text(
                      text: displayName,
                      size: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColor.white,
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: AppColor.white.withOpacity(0.8),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              text(
                text: displayPhone,
                size: 14,
                fontWeight: FontWeight.w400,
                color: AppColor.white.withOpacity(0.8),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ── Edit Name Bottom Sheet ──────────────────────────────────────────────────

  void _showEditNameBottomSheet(String currentName) {
    final nameController = TextEditingController(text: currentName);
    final isUpdating = false.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColor.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                text(
                  text: 'Edit Name',
                  size: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black,
                ),
                const SizedBox(height: 6),
                text(
                  text: 'Update your display name',
                  size: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColor.black.withOpacity(0.5),
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
                      fontSize: 15,
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
                      borderSide: BorderSide(
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
                    builder: (_, value, __) {
                      final trimmed = value.text.trim();
                      final isEmpty = trimmed.isEmpty;
                      final isTooShort = trimmed.length < 2;
                      final isDisabled = isEmpty || isTooShort || updating;

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              isDisabled
                                  ? null
                                  : () async {
                                    // Same name validation
                                    if (trimmed == currentName) {
                                      Get.snackbar(
                                        'Same Name',
                                        'Please enter a different name to update.',
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
                                        'Success',
                                        'Name updated successfully!',
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                    } else {
                                      Get.snackbar(
                                        'Error',
                                        'Failed to update name. Please try again.',
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.appPrimary,
                            disabledBackgroundColor: AppColor.appPrimary
                                .withOpacity(0.45),
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
        );
      },
    );
  }

  // ── Overlapping white card ──────────────────────────────────────────────────

  Widget _buildOverlappingContent(BuildContext context) {
    return Positioned(
      top: context.hp(31.5),
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          color: Colors.white,
        ),
        child: Obx(() {
          if (_controller.hasError.value) {
            return _buildErrorState();
          }
          return _buildScrollableList();
        }),
      ),
    );
  }

  // ── Error state ─────────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.withOpacity(0.55),
            ),
            const SizedBox(height: 16),
            text(
              text: 'Failed to load profile',
              size: 16,
              fontWeight: FontWeight.w600,
              color: AppColor.black,
            ),
            const SizedBox(height: 8),
            Obx(
              () => text(
                text: _controller.errorMessage.value,
                size: 13,
                fontWeight: FontWeight.w400,
                color: AppColor.black.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _controller.refresh,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColor.appPrimary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: text(
                  text: 'Try Again',
                  size: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Data list ───────────────────────────────────────────────────────────────

  Widget _buildScrollableList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          20.h,
          _buildSectionHeader('Account Settings'),
          20.h,
          ..._buildAccountSettingsTiles(),
          32.h,
          _buildSectionHeader('Support'),
          20.h,
          ..._buildSupportTiles(),
          80.h,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return text(
      text: title,
      size: 14,
      fontWeight: FontWeight.w500,
      color: AppColor.black.withOpacity(0.6),
    );
  }

  List<Widget> _buildAccountSettingsTiles() {
    return [
      // Personal Information hidden — name editing via header edit icon
      ProfileTile(
        title: 'My Orders',
        svgIcon: myOrderSvg,
        onTap: () {
          Get.find<BottomNavController>().setBottomBarIndex(1);
        },
      ),
    ];
  }

  List<Widget> _buildSupportTiles() {
    return [
      ProfileTile(
        title: 'Help Center',
        svgIcon: helpCentreSvg,
        onTap: () => _handleTileTap('Help Center'),
      ),
      ProfileTile(
        title: 'FAQ',
        svgIcon: faqSvg,
        onTap: () => _handleTileTap('FAQ'),
      ),
      ProfileTile(
        title: 'Privacy and Policy',
        svgIcon: privacySvg,
        onTap: () => _handleTileTap('Privacy and Policy'),
      ),
      ProfileTile(
        title: 'Terms & Conditions',
        svgIcon: termsSvg,
        onTap: () => _handleTileTap('Terms & Conditions'),
      ),
      ProfileTile(
        title: 'Refer and Earn',
        svgIcon: referSvg,
        onTap: () {
          Get.toNamed(Routes.referScreen);
        },
      ),
      ProfileTile(
        title: 'Logout',
        svgIcon: referSvg,
        onTap: () async {
          await Store.clear();
          Get.offAllNamed(Routes.splash);
        },
      ),
    ];
  }

  void _handleTileTap(String tileName) {
    log('$tileName tapped');
  }
}
