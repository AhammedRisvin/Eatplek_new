import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';

import '../../controller/auth_controller.dart';
import 'location_status_widget.dart';

class ProfileCompletionWidget extends StatelessWidget {
  final AuthController controller;

  const ProfileCompletionWidget({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          // Prevent closing by tapping outside
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(responsive.largeBorderRadius),
              topRight: Radius.circular(responsive.largeBorderRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: responsive.spacing10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: responsive.spacing16,
                right: responsive.spacing16,
                top: responsive.spacing24,
                bottom: MediaQuery.of(context).viewInsets.bottom + responsive.spacing16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(responsive),
                  SizedBox(height: responsive.spacing24),
                  _buildNameSection(context, responsive),
                  SizedBox(height: responsive.spacing16),
                  _buildLocationSection(responsive),
                  SizedBox(height: responsive.spacing24),
                  _buildCompleteButton(responsive),
                  SizedBox(height: responsive.spacing12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ResponsiveHelper responsive) {
    return Column(
      children: [
        Center(
          child: Text(
            'Complete Your Profile',
            style: TextStyle(fontSize: responsive.fontSize24, fontWeight: FontWeight.w700, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: responsive.spacing6),
        Center(
          child: Text(
            'Please provide your name and location to continue',
            style: TextStyle(
              fontSize: responsive.fontSize14,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildNameSection(BuildContext context, ResponsiveHelper responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: TextStyle(fontSize: responsive.fontSize16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        SizedBox(height: responsive.spacing10),
        buildCommonTextFormField(
          hintText: 'Enter your full name',
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.done,
          controller: controller.nameController,
          context: context,
        ),
      ],
    );
  }

  Widget _buildLocationSection(ResponsiveHelper responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(fontSize: responsive.fontSize16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        SizedBox(height: responsive.spacing10),
        LocationStatusWidget(controller: controller),
      ],
    );
  }

  Widget _buildCompleteButton(ResponsiveHelper responsive) {
    final isDisabled = controller.isLoading || controller.latitude == null || controller.longitude == null;

    return button(
      name: 'Complete Profile',
      borderRadius: BorderRadius.circular(responsive.spacing40),
      height: responsive.buttonHeight,
      isLoading: controller.isLoading,
      onTap: isDisabled ? () {} : controller.handleProfileCompletion,
    );
  }
}
