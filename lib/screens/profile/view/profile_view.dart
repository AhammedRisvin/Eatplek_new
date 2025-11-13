import 'dart:developer';

import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:svg_flutter/svg.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../../core/util/common_widgets.dart';
import 'widget/profile_tile.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with profile info
          _buildProfileHeader(context),
          // Overlapping white container
          _buildOverlappingContent(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: context.wp(100),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/33b1d8f643bc4393955ae79fcd8039e7fd5963e9.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Color.fromRGBO(0, 0, 0, 0.5), BlendMode.darken),
            ),
          ),
          padding: const EdgeInsets.only(bottom: 41),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_buildAppBar(), const SizedBox(height: 30), _buildProfileInfo()],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildBackButton(),
          Expanded(
            child: Center(child: text(text: 'Profile', size: 18, fontWeight: FontWeight.w600, color: AppColor.white)),
          ),
          const SizedBox(width: 44), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        child: Center(child: SvgPicture.string(arrowBack2, color: AppColor.white)),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.white, width: 2),
            borderRadius: BorderRadius.circular(100),
          ),
          margin: const EdgeInsets.only(bottom: 10),
          child: image(
            url: 'https://www.w3schools.com/howto/img_avatar.png',
            width: 70,
            height: 70,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        text(text: 'Akshar Kannur', size: 18, fontWeight: FontWeight.w600, color: AppColor.white),
        const SizedBox(height: 4),
        text(
          text: 'askhareatplek@gmail.com',
          size: 14,
          fontWeight: FontWeight.w400,
          color: AppColor.white.withOpacity(0.8),
        ),
      ],
    );
  }

  Widget _buildOverlappingContent(BuildContext context) {
    return Positioned(
      top: context.hp(31.5), // This matches your original overlap position
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return text(text: title, size: 14, fontWeight: FontWeight.w500, color: AppColor.black.withOpacity(0.6));
  }

  List<Widget> _buildAccountSettingsTiles() {
    return [
      ProfileTile(
        title: 'Personal Information',
        svgIcon: personalInfoSvg,
        onTap: () => _handleTileTap('Personal Information'),
      ),
      ProfileTile(title: 'My Orders', svgIcon: myOrderSvg, onTap: () => _handleTileTap('My Orders')),
    ];
  }

  List<Widget> _buildSupportTiles() {
    return [
      ProfileTile(title: 'Help Center', svgIcon: helpCentreSvg, onTap: () => _handleTileTap('Help Center')),
      ProfileTile(title: 'FAQ', svgIcon: faqSvg, onTap: () => _handleTileTap('FAQ')),
      ProfileTile(title: 'Privacy and Policy', svgIcon: privacySvg, onTap: () => _handleTileTap('Privacy and Policy')),
      ProfileTile(title: 'Terms & Conditions', svgIcon: termsSvg, onTap: () => _handleTileTap('Terms & Conditions')),
      ProfileTile(title: 'Refer and Earn', svgIcon: referSvg, onTap: () => _handleTileTap('Refer and Earn')),
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
    // Add your navigation logic here
  }
}
