import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';

import '../../controller/auth_controller.dart';

class LoginFormWidget extends StatelessWidget {
  final AuthController controller;

  const LoginFormWidget({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildPhoneLabel(), 10.h, _buildPhoneInputField(context), 10.h, _buildPhoneHint()],
    );
  }

  Widget _buildPhoneLabel() {
    return text(text: 'Mobile Number', size: 16, fontWeight: FontWeight.w500);
  }

  Widget _buildPhoneInputField(BuildContext context) {
    return buildCommonTextFormField(
      hintText: '9876543210',
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      textInputAction: TextInputAction.done,
      controller: controller.phoneController,
      context: context,
      maxLength: 10,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(top: 13.0, left: 10),
        child: text(text: '+91', size: 16, fontWeight: FontWeight.w500, color: AppColor.hintTextColor),
      ),
    );
  }

  Widget _buildPhoneHint() {
    return text(
      text: 'Please enter your 10-digit mobile number',
      size: 12,
      fontWeight: FontWeight.w300,
      color: AppColor.black.withOpacity(0.6),
    );
  }
}
