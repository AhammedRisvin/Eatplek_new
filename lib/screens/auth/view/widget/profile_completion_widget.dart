// import 'package:eatplek_app/core/util/app_color.dart';
// import 'package:eatplek_app/core/util/common_widgets.dart';
// import 'package:eatplek_app/core/util/responsive_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import '../../controller/auth_controller.dart';
// import 'location_status_widget.dart';

// class ProfileCompletionWidget extends StatefulWidget {
//   final AuthController controller;

//   const ProfileCompletionWidget({required this.controller, super.key});

//   @override
//   State<ProfileCompletionWidget> createState() =>
//       _ProfileCompletionWidgetState();
// }

// class _ProfileCompletionWidgetState extends State<ProfileCompletionWidget> {
//   // Tracks whether the referral field has been touched at all
//   bool _referralTouched = false;

//   bool get _isReferralValid => widget.controller.isReferralCodeValid;

//   bool get _showReferralError {
//     if (!_referralTouched) return false;
//     final code = widget.controller.referralCodeController.text.trim();
//     return code.isNotEmpty && !_isReferralValid;
//   }

//   bool get _showReferralSuccess {
//     final code = widget.controller.referralCodeController.text.trim();
//     return code.isNotEmpty && _isReferralValid;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final responsive = ResponsiveHelper();

//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: GestureDetector(
//         onTap: () {
//           // Prevent closing by tapping outside
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(responsive.extraLargeBorderRadius),
//               topRight: Radius.circular(responsive.extraLargeBorderRadius),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: responsive.spacing10,
//                 offset: const Offset(0, -5),
//               ),
//             ],
//           ),
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.only(
//                 left: responsive.spacing16,
//                 right: responsive.spacing16,
//                 top: responsive.spacing24,
//                 bottom:
//                     MediaQuery.of(context).viewInsets.bottom +
//                     responsive.spacing16,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildHeader(responsive),
//                   SizedBox(height: responsive.spacing24),
//                   _buildNameSection(context, responsive),
//                   SizedBox(height: responsive.spacing16),
//                   _buildLocationSection(responsive),
//                   SizedBox(height: responsive.spacing16),
//                   _buildReferralSection(context, responsive),
//                   SizedBox(height: responsive.spacing24),
//                   _buildCompleteButton(responsive),
//                   SizedBox(height: responsive.spacing12),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(ResponsiveHelper responsive) {
//     return Column(
//       children: [
//         Center(
//           child: Text(
//             'Complete Your Profile',
//             style: TextStyle(
//               fontSize: responsive.fontSize24,
//               fontWeight: FontWeight.w700,
//               color: Colors.black,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//         SizedBox(height: responsive.spacing6),
//         Center(
//           child: Text(
//             'Please provide your name and location to continue',
//             style: TextStyle(
//               fontSize: responsive.fontSize14,
//               fontWeight: FontWeight.w400,
//               color: AppColor.black.withOpacity(0.6),
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildNameSection(BuildContext context, ResponsiveHelper responsive) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Full Name',
//           style: TextStyle(
//             fontSize: responsive.fontSize16,
//             fontWeight: FontWeight.w500,
//             color: Colors.black,
//           ),
//         ),
//         SizedBox(height: responsive.spacing10),
//         buildCommonTextFormField(
//           hintText: 'Enter your full name',
//           keyboardType: TextInputType.name,
//           textInputAction: TextInputAction.done,
//           controller: widget.controller.nameController,
//           context: context,
//         ),
//       ],
//     );
//   }

//   Widget _buildLocationSection(ResponsiveHelper responsive) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Location',
//           style: TextStyle(
//             fontSize: responsive.fontSize16,
//             fontWeight: FontWeight.w500,
//             color: Colors.black,
//           ),
//         ),
//         SizedBox(height: responsive.spacing10),
//         LocationStatusWidget(controller: widget.controller),
//       ],
//     );
//   }

//   Widget _buildReferralSection(
//     BuildContext context,
//     ResponsiveHelper responsive,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Label row — "Referral Code" + "Optional" badge
//         Row(
//           children: [
//             Text(
//               'Referral Code',
//               style: TextStyle(
//                 fontSize: responsive.fontSize16,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black,
//               ),
//             ),
//             SizedBox(width: responsive.spacing8),
//             Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: responsive.spacing8,
//                 vertical: 2,
//               ),
//               decoration: BoxDecoration(
//                 color: AppColor.appPrimary.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 'Optional',
//                 style: TextStyle(
//                   fontSize: responsive.fontSize10,
//                   fontWeight: FontWeight.w600,
//                   color: AppColor.appPrimary,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: responsive.spacing10),

//         // Text field
//         StatefulBuilder(
//           builder: (ctx, setFieldState) {
//             return TextField(
//               controller: widget.controller.referralCodeController,
//               textCapitalization: TextCapitalization.characters,
//               inputFormatters: [
//                 // Force uppercase as user types
//                 TextInputFormatter.withFunction(
//                   (oldValue, newValue) =>
//                       newValue.copyWith(text: newValue.text.toUpperCase()),
//                 ),
//                 // Max length = 12 chars (EAT + 9 alphanumeric)
//                 LengthLimitingTextInputFormatter(12),
//               ],
//               onChanged: (_) {
//                 setState(() => _referralTouched = true);
//               },
//               style: TextStyle(
//                 fontSize: responsive.fontSize15,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 1.1,
//                 color:
//                     _showReferralError
//                         ? AppColor.redColor
//                         : _showReferralSuccess
//                         ? const Color(0xFF2E7D32)
//                         : AppColor.black,
//               ),
//               decoration: InputDecoration(
//                 hintText: 'e.g. EAT3930KAN8F',
//                 hintStyle: TextStyle(
//                   color: AppColor.black.withOpacity(0.25),
//                   fontSize: responsive.fontSize14,
//                   letterSpacing: 0.5,
//                   fontWeight: FontWeight.w400,
//                 ),
//                 filled: true,
//                 fillColor: const Color(0xFFF8F8F8),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: responsive.spacing16,
//                   vertical: responsive.spacing14,
//                 ),

//                 // Trailing icon — check or error
//                 suffixIcon:
//                     _showReferralSuccess
//                         ? Padding(
//                           padding: const EdgeInsets.only(right: 12),
//                           child: Icon(
//                             Icons.check_circle_rounded,
//                             color: const Color(0xFF2E7D32),
//                             size: 20,
//                           ),
//                         )
//                         : _showReferralError
//                         ? Padding(
//                           padding: const EdgeInsets.only(right: 12),
//                           child: Icon(
//                             Icons.cancel_rounded,
//                             color: AppColor.redColor,
//                             size: 20,
//                           ),
//                         )
//                         : null,
//                 suffixIconConstraints: const BoxConstraints(minWidth: 0),

//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(
//                     color: AppColor.black.withOpacity(0.08),
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(
//                     color:
//                         _showReferralError
//                             ? AppColor.redColor.withOpacity(0.5)
//                             : _showReferralSuccess
//                             ? const Color(0xFF2E7D32).withOpacity(0.4)
//                             : AppColor.black.withOpacity(0.08),
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(
//                     color:
//                         _showReferralError
//                             ? AppColor.redColor
//                             : _showReferralSuccess
//                             ? const Color(0xFF2E7D32)
//                             : AppColor.appPrimary,
//                     width: 1.5,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),

//         // Inline error / success message
//         if (_showReferralError) ...[
//           SizedBox(height: responsive.spacing6),
//           Row(
//             children: [
//               Icon(
//                 Icons.info_outline_rounded,
//                 size: 13,
//                 color: AppColor.redColor,
//               ),
//               SizedBox(width: 4),
//               Text(
//                 'Format must be EAT followed by 9 letters/numbers',
//                 style: TextStyle(
//                   fontSize: responsive.fontSize12,
//                   color: AppColor.redColor,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ],
//           ),
//         ] else if (_showReferralSuccess) ...[
//           SizedBox(height: responsive.spacing6),
//           Row(
//             children: [
//               Icon(
//                 Icons.check_circle_outline_rounded,
//                 size: 13,
//                 color: const Color(0xFF2E7D32),
//               ),
//               SizedBox(width: 4),
//               Text(
//                 'Valid referral code',
//                 style: TextStyle(
//                   fontSize: responsive.fontSize12,
//                   color: const Color(0xFF2E7D32),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildCompleteButton(ResponsiveHelper responsive) {
//     // Disable if loading, no location, or referral code is invalid
//     final isDisabled =
//         widget.controller.isLoading ||
//         widget.controller.latitude == null ||
//         widget.controller.longitude == null ||
//         !widget.controller.isReferralCodeValid;

//     return button(
//       name: 'Complete Profile',
//       borderRadius: BorderRadius.circular(responsive.spacing40),
//       height: widget.controller.isLoading ? responsive.buttonHeight : null,
//       isLoading: widget.controller.isLoading,
//       onTap: isDisabled ? () {} : widget.controller.handleProfileCompletion,
//     );
//   }
// }
