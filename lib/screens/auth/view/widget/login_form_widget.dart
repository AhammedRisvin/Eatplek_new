import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';

import '../../controller/auth_controller.dart';

class LoginFormWidget extends StatelessWidget {
  final AuthController controller;

  const LoginFormWidget({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPhoneLabel(responsive),
        SizedBox(height: responsive.spacing10),
        _buildPhoneInputField(context, responsive),
        SizedBox(height: responsive.spacing10),
        _buildPhoneHint(responsive),
      ],
    );
  }

  Widget _buildPhoneLabel(ResponsiveHelper responsive) {
    return Text(
      'Mobile Number',
      style: TextStyle(fontSize: responsive.fontSize16, fontWeight: FontWeight.w500, color: Colors.black),
    );
  }

  Widget _buildPhoneInputField(BuildContext context, ResponsiveHelper responsive) {
    return buildCommonTextFormField(
      hintText: '9876543210',
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      textInputAction: TextInputAction.done,
      controller: controller.phoneController,
      context: context,
      maxLength: 10,
      prefixIcon: Padding(
        padding: EdgeInsets.only(top: responsive.spacing13, left: responsive.spacing10),
        child: Text(
          '+91',
          style: TextStyle(fontSize: responsive.fontSize16, fontWeight: FontWeight.w500, color: AppColor.hintTextColor),
        ),
      ),
    );
  }

  Widget _buildPhoneHint(ResponsiveHelper responsive) {
    return Text(
      'Please enter your 10-digit mobile number',
      style: TextStyle(
        fontSize: responsive.fontSize12,
        fontWeight: FontWeight.w300,
        color: AppColor.black.withOpacity(0.6),
      ),
    );
  }
}
