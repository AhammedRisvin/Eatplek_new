import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../controller/auth_controller.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AuthController>(
        id: 'auth_screen',
        init: AuthController(),
        builder: (controller) {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                // First container (background)
                Container(width: context.wp(100), height: 245, color: AppColor.appPrimary),

                // Second container (overlayed on top)
                Positioned(
                  top: 245 - 20, // 20px overlap
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        30.h,

                        // Back button for OTP screen
                        if (controller.isOtpStep)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: controller.goBackToForm,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back_ios, color: AppColor.appPrimary, size: 18),
                                  text(text: 'Back', size: 16, fontWeight: FontWeight.w500, color: AppColor.appPrimary),
                                ],
                              ),
                            ),
                          ),

                        if (controller.isOtpStep) 10.h,

                        text(
                          text: controller.title,
                          size: 26,
                          fontWeight: FontWeight.w700,
                          textAlign: TextAlign.center,
                        ),
                        10.h,
                        text(
                          text: controller.subtitle,
                          fontWeight: FontWeight.w400,
                          size: 18,
                          color: AppColor.black.withOpacity(0.6),
                          textAlign: TextAlign.center,
                        ),
                        30.h,

                        // Form fields or OTP input
                        if (controller.isFormStep) ...[
                          if (controller.isSignUp) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: text(
                                text: 'Full Name',
                                size: 16,
                                fontWeight: FontWeight.w500,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            10.h,
                            buildCommonTextFormField(
                              hintText: 'Enter your full name',
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              controller: controller.nameController,
                              context: context,
                            ),
                            20.h,
                          ],

                          // Mobile Number field
                          Align(
                            alignment: Alignment.centerLeft,
                            child: text(
                              text: 'Mobile Number',
                              size: 16,
                              fontWeight: FontWeight.w500,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          10.h,
                          buildCommonTextFormField(
                            hintText: '9876543210',
                            keyboardType: TextInputType.numberWithOptions(decimal: false),
                            textInputAction: TextInputAction.done,
                            controller: controller.phoneController,
                            context: context,
                            maxLength: 10,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(top: 13.0),
                              child: text(
                                text: '+91',
                                size: 16,
                                fontWeight: FontWeight.w500,
                                textAlign: TextAlign.center,
                                color: AppColor.hintTextColor,
                              ),
                            ),
                          ),
                          10.h,
                          Align(
                            alignment: Alignment.centerLeft,
                            child: text(
                              text: controller.isLogin ? 'Please enter your sign-up mobile number' : '',
                              size: 12,
                              fontWeight: FontWeight.w300,
                              textAlign: TextAlign.center,
                              color: AppColor.black.withOpacity(0.6),
                            ),
                          ),
                        ] else ...[
                          // OTP Input
                          Center(
                            child: Pinput(
                              length: 6,
                              controller: controller.otpController,
                              focusedPinTheme: PinTheme(
                                width: 57,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColor.scaffoldColor,
                                  border: Border.all(color: AppColor.appPrimary.withOpacity(.4)),
                                ),
                              ),
                              defaultPinTheme: PinTheme(
                                width: 57,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColor.scaffoldColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                              showCursor: true,
                              errorPinTheme: PinTheme(
                                width: 57,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.withOpacity(.4)),
                                ),
                              ),
                              onTapOutside: (_) {
                                FocusScope.of(context).unfocus();
                              },
                              onCompleted: (value) {
                                controller.handleOtpVerification();
                              },
                              pinAnimationType: PinAnimationType.fade,
                              submittedPinTheme: PinTheme(
                                height: context.hp(6),
                                width: context.hp(6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.withOpacity(.4)),
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Spacer to push button to bottom
                        Spacer(),

                        // Auth Button at bottom
                        button(
                          name: controller.buttonText,
                          borderRadius: BorderRadius.circular(50),
                          height: 60,
                          onTap: controller.handleAuthAction,
                        ),
                        10.h,
                        GestureDetector(
                          onTap: () {
                            if (controller.isOtpStep && !controller.canResend) {
                              return;
                            }
                            controller.toggleAuthMode();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              text(
                                text: controller.switchText,
                                size: 16,
                                fontWeight: FontWeight.w500,
                                textAlign: TextAlign.center,
                                color: AppColor.black.withOpacity(0.6),
                              ),
                              text(
                                text: controller.switchActionText,
                                size: 16,
                                fontWeight: FontWeight.w700,
                                textAlign: TextAlign.center,
                                color:
                                    (controller.isOtpStep && !controller.canResend)
                                        ? AppColor.black.withOpacity(0.4)
                                        : AppColor.appPrimary,
                              ),
                            ],
                          ),
                        ),
                        40.h,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
