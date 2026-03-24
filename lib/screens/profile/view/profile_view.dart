import 'dart:developer';

import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:eatplek_app/screens/bottom_nav/controller/bottom_nav_controller.dart';
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
    // ProfileView lives inside IndexedStack and mounts at app launch even when
    // the profile tab is not visible. Guard the fetch so it only fires when the
    // tab is actually active. BottomNavController.setBottomBarIndex() triggers
    // fetchProfile() when the user taps the profile tab for the first time.
    // The _hasFetched flag inside ProfileController prevents redundant re-fetches.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final navCtrl = Get.find<BottomNavController>();
        if (navCtrl.currentIndex == 3) {
          // Profile tab is the active tab right now — fetch
          _controller.fetchProfile();
        }
        // Otherwise do nothing — BottomNavController owns the trigger
      } catch (_) {
        // Fallback: not inside IndexedStack (e.g. pushed directly via /profileView)
        _controller.fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(responsive),
          Expanded(child: _buildContentCard(responsive)),
        ],
      ),
    );
  }

  Widget _buildHeader(ResponsiveHelper responsive) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/image/33b1d8f643bc4393955ae79fcd8039e7fd5963e9.jpg',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Color.fromRGBO(0, 0, 0, 0.45),
            BlendMode.darken,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: responsive.spacing16,
            bottom: responsive.spacing40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              text(
                text: 'Profile',
                size: responsive.fontSize18,
                fontWeight: FontWeight.w700,
                color: AppColor.white,
              ),
              SizedBox(height: responsive.spacing20),
              _buildAvatarSection(responsive),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(ResponsiveHelper responsive) {
    return Obx(() {
      final isLoading = _controller.isLoading.value;
      final user = _controller.userData.value;
      final displayName =
          (user?.name?.isNotEmpty == true)
              ? user!.name!
              : (isLoading ? '' : 'User');
      final displayPhone =
          user != null
              ? '${user.dialCode ?? ''} ${user.phone ?? ''}'.trim()
              : '';
      final displayImage =
          (user?.profileImage?.isNotEmpty == true)
              ? user!.profileImage!
              : 'https://www.w3schools.com/howto/img_avatar.png';

      return Skeletonizer(
        enabled: isLoading,
        ignoreContainers: true,
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _showEditNameSheet(displayName),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColor.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
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
            SizedBox(height: responsive.spacing10),
            isLoading
                ? Container(
                  width: 100,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColor.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
                : text(
                  text: displayName,
                  size: responsive.fontSize18,
                  fontWeight: FontWeight.w700,
                  color: AppColor.white,
                ),
            SizedBox(height: responsive.spacing4),
            isLoading
                ? Container(
                  width: 80,
                  height: 13,
                  decoration: BoxDecoration(
                    color: AppColor.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
                : text(
                  text: displayPhone,
                  size: responsive.fontSize13,
                  color: AppColor.white.withOpacity(0.7),
                ),
          ],
        ),
      );
    });
  }

  Widget _buildContentCard(ResponsiveHelper responsive) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() {
        if (_controller.hasError.value) {
          return errorState(
            message: _controller.errorMessage.value,
            onRetry: _controller.refresh,
          );
        }
        return _buildTileList(responsive);
      }),
    );
  }

  Widget _buildTileList(ResponsiveHelper responsive) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: responsive.spacing24),

          _sectionLabel('ACCOUNT', responsive),
          SizedBox(height: responsive.spacing12),

          ProfileTile(
                title: 'My Orders',
                svgIcon: myOrderSvg,
                onTap:
                    () => Get.find<BottomNavController>().setBottomBarIndex(1),
              )
              .animate()
              .fade(duration: 300.ms)
              .slideX(begin: 0.05, end: 0, duration: 300.ms),

          SizedBox(height: responsive.spacing28),

          _sectionLabel('SUPPORT', responsive),
          SizedBox(height: responsive.spacing12),

          ProfileTile(
                title: 'Help Center',
                svgIcon: helpCentreSvg,
                onTap: () => log('Help Center'),
              )
              .animate(delay: 50.ms)
              .fade(duration: 280.ms)
              .slideX(begin: 0.05, end: 0, duration: 280.ms),

          ProfileTile(title: 'FAQ', svgIcon: faqSvg, onTap: () => log('FAQ'))
              .animate(delay: 80.ms)
              .fade(duration: 280.ms)
              .slideX(begin: 0.05, end: 0, duration: 280.ms),

          ProfileTile(
                title: 'Privacy & Policy',
                svgIcon: privacySvg,
                onTap: () => log('Privacy'),
              )
              .animate(delay: 110.ms)
              .fade(duration: 280.ms)
              .slideX(begin: 0.05, end: 0, duration: 280.ms),

          ProfileTile(
                title: 'Terms & Conditions',
                svgIcon: termsSvg,
                onTap: () => log('Terms'),
              )
              .animate(delay: 140.ms)
              .fade(duration: 280.ms)
              .slideX(begin: 0.05, end: 0, duration: 280.ms),

          ProfileTile(
                title: 'Refer and Earn',
                svgIcon: referSvg,
                onTap: () => Get.toNamed(Routes.referScreen),
              )
              .animate(delay: 170.ms)
              .fade(duration: 280.ms)
              .slideX(begin: 0.05, end: 0, duration: 280.ms),

          ProfileTile(
                title: 'Logout',
                svgIcon: referSvg,
                titleColor: AppColor.redColor,
                onTap: _confirmLogout,
              )
              .animate(delay: 200.ms)
              .fade(duration: 280.ms)
              .slideX(begin: 0.05, end: 0, duration: 280.ms),

          SizedBox(height: responsive.spacing80),
        ],
      ),
    );
  }

  Widget _sectionLabel(String title, ResponsiveHelper responsive) {
    return text(
      text: title,
      size: responsive.fontSize11,
      fontWeight: FontWeight.w600,
      color: AppColor.black.withOpacity(0.38),
      letterSpacing: 0.8,
    );
  }

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: text(text: 'Logout?', size: 18, fontWeight: FontWeight.w700),
        content: text(
          text: 'Are you sure you want to logout?',
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
    final nameCtrl = TextEditingController(text: currentName);
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
                    controller: nameCtrl,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(
                        color: AppColor.black.withOpacity(0.3),
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
                        borderSide: const BorderSide(
                          color: AppColor.appPrimary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    final updating = isUpdating.value;
                    return ValueListenableBuilder<TextEditingValue>(
                      valueListenable: nameCtrl,
                      builder: (_, val, _) {
                        final trimmed = val.text.trim();
                        final disabled =
                            trimmed.isEmpty || trimmed.length < 2 || updating;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                disabled
                                    ? null
                                    : () async {
                                      if (trimmed == currentName) {
                                        Get.snackbar(
                                          'Same Name',
                                          'Please enter a different name.',
                                          backgroundColor: Colors.orange,
                                          colorText: Colors.white,
                                        );
                                        return;
                                      }
                                      isUpdating.value = true;
                                      final ok = await _controller.updateName(
                                        trimmed,
                                      );
                                      isUpdating.value = false;
                                      if (ok) {
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
                                          'Failed to update name.',
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
