import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';

import '../../controller/auth_controller.dart';
import 'location_status_widget.dart';

class ProfileCompletionWidget extends StatelessWidget {
  final AuthController controller;

  const ProfileCompletionWidget({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
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
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  24.h,
                  _buildNameSection(context),
                  16.h,
                  _buildLocationSection(),
                  24.h,
                  _buildCompleteButton(),
                  12.h,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: text(
            text: 'Complete Your Profile',
            size: 24,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
        ),
        6.h,
        Center(
          child: text(
            text: 'Please provide your name and location to continue',
            size: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.6),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildNameSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(text: 'Full Name', size: 16, fontWeight: FontWeight.w500),
        10.h,
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

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(text: 'Location', size: 16, fontWeight: FontWeight.w500),
        10.h,
        LocationStatusWidget(controller: controller),
      ],
    );
  }

  Widget _buildCompleteButton() {
    final isDisabled = controller.isLoading || controller.latitude == null || controller.longitude == null;

    return button(
      name: 'Complete Profile',
      borderRadius: BorderRadius.circular(50),
      height: 60,
      isLoading: controller.isLoading,
      onTap: isDisabled ? () {} : controller.handleProfileCompletion,
    );
  }
}
