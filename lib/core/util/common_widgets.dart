import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'app_color.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TEXT
// ─────────────────────────────────────────────────────────────────────────────

Widget text({
  String? text,
  double? size,
  Color? color,
  int? maxLines,
  TextAlign? textAlign,
  FontWeight? fontWeight,
  String? fontFamily,
  TextDecoration? decoration,
  TextOverflow? overFlow,
  double? wordSpacing,
  double? letterSpacing,
  TextDecorationStyle? decorationStyle,
  Color? decorationColor,
  double? height,
}) {
  return Text(
    text ?? '',
    maxLines: maxLines,
    textAlign: textAlign,
    style: TextStyle(
      fontSize: size,
      color: color ?? AppColor.black,
      fontWeight: fontWeight,
      fontFamily: fontFamily ?? GoogleFonts.urbanist().fontFamily,
      decoration: decoration,
      decorationColor: decorationColor,
      overflow: overFlow,
      wordSpacing: wordSpacing,
      letterSpacing: letterSpacing,
      decorationStyle: decorationStyle,
      height: height,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// BUTTON
// Pill shape by default (BorderRadius.circular(100)) — matches Zomato/Blinkit
// aesthetic. Pass a custom borderRadius to override.
// ─────────────────────────────────────────────────────────────────────────────

Widget button({
  double? height,
  double? width,
  Color? color,
  BorderRadius? borderRadius,
  String? name,
  Function()? onTap,
  double? fontSize = 16,
  Color? textColor = AppColor.white,
  Color borderColor = AppColor.appPrimary,
  bool isLoading = false,
  bool isIcon = false,
  String? image,
  FontWeight? fontWeight = FontWeight.bold,
  BuildContext? context,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: borderRadius ?? BorderRadius.circular(100),
      splashColor: AppColor.white.withOpacity(0.15),
      highlightColor: AppColor.white.withOpacity(0.08),
      child: Ink(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: color ?? AppColor.appPrimary,
          // Default pill radius — matches Zomato/Blinkit style
          borderRadius: borderRadius ?? BorderRadius.circular(100),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child:
              isLoading
                  ? const CupertinoActivityIndicator(color: AppColor.white)
                  : isIcon
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.string(image ?? ''),
                      const SizedBox(width: 10),
                      text(
                        text: name ?? 'Continue',
                        size: fontSize,
                        color: textColor,
                        fontWeight: fontWeight,
                        letterSpacing: 1,
                      ),
                    ],
                  )
                  : text(
                    text: name ?? 'Continue',
                    size: fontSize,
                    color: textColor,
                    fontWeight: fontWeight,
                    letterSpacing: 1,
                  ),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// CACHED NETWORK IMAGE
// Uses CachedNetworkImage with skeletonizer-compatible placeholder.
// Replaces plain Image.network calls across the app.
// ─────────────────────────────────────────────────────────────────────────────

Widget image({
  required String url,
  double? height,
  double? width,
  BorderRadius? borderRadius,
  BoxFit fit = BoxFit.cover,
}) {
  return CachedNetworkImage(
    imageUrl: url,
    height: height,
    width: width,
    fit: fit,
    imageBuilder: (context, imageProvider) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.zero,
          image: DecorationImage(image: imageProvider, fit: fit),
        ),
      );
    },
    // Skeleton-compatible placeholder — works with Skeletonizer wrapping
    placeholder:
        (context, url) => Skeleton.leaf(
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: borderRadius ?? BorderRadius.zero,
            ),
          ),
        ),
    errorWidget: (context, url, error) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: borderRadius ?? BorderRadius.zero,
        ),
        child: Center(
          child: Icon(
            Icons.restaurant,
            color: Colors.grey.shade400,
            size: (height != null && height < 60) ? 16 : 28,
          ),
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TEXT FORM FIELD
// ─────────────────────────────────────────────────────────────────────────────

Widget buildCommonTextFormField({
  bool expands = false,
  Color borderColor = Colors.black12,
  Color bgColor = AppColor.scaffoldColor,
  required String hintText,
  Color hintTextColor = AppColor.hintTextColor,
  Widget? prefixIcon,
  Color color = AppColor.black,
  required TextInputType keyboardType,
  required TextInputAction textInputAction,
  String? Function(String?)? validator,
  int? maxLength,
  required TextEditingController? controller,
  List<TextInputFormatter>? inputFormatters,
  EdgeInsetsGeometry? contentPadding = const EdgeInsets.only(
    left: 20,
    top: 18,
    bottom: 18,
    right: 10,
  ),
  bool obscureText = false,
  Widget? suffixIcon,
  void Function()? onTap,
  bool enabled = true,
  bool readOnly = false,
  double radius = 10,
  int? minLine,
  int? maxLine,
  FocusNode? focusNode,
  bool isFromChat = false,
  void Function(String)? onChanged,
  void Function(String)? onFieldSubmitted,
  required BuildContext context,
  bool isFromPhoneText = false,
  TextAlignVertical textAlignVertical = TextAlignVertical.center,
  double hintTextSize = 16,
}) {
  return TextFormField(
    inputFormatters: inputFormatters,
    onChanged: onChanged,
    onFieldSubmitted: onFieldSubmitted,
    onTapOutside: (event) => FocusScope.of(context).unfocus(),
    onTap: onTap,
    style: TextStyle(
      fontFamily: GoogleFonts.urbanist().fontFamily,
      color: color,
      fontSize: 14,
    ),
    expands: expands,
    keyboardType: keyboardType,
    obscureText: obscureText,
    textInputAction: textInputAction,
    enabled: enabled,
    focusNode: focusNode,
    decoration: InputDecoration(
      prefixIcon: prefixIcon,
      counterText: '',
      contentPadding: contentPadding,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide:
            isFromPhoneText ? BorderSide.none : BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide:
            isFromPhoneText ? BorderSide.none : BorderSide(color: borderColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide:
            isFromPhoneText ? BorderSide.none : BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide:
            isFromPhoneText
                ? BorderSide.none
                : BorderSide(
                  color: AppColor.appPrimary.withOpacity(0.5),
                  width: 1.5,
                ),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      suffixIcon: suffixIcon,
      fillColor: bgColor,
      filled: true,
      hintText: hintText,
      hintStyle: TextStyle(
        color: hintTextColor,
        fontWeight: FontWeight.w400,
        fontSize: hintTextSize.toDouble(),
        fontFamily: GoogleFonts.urbanist().fontFamily,
      ),
      alignLabelWithHint: true,
    ),
    validator: validator,
    maxLength: maxLength,
    controller: controller,
    readOnly: readOnly,
    minLines: minLine,
    maxLines: maxLine,
    textAlignVertical: textAlignVertical,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS BADGE
// Colour-coded order status chip — reusable across orders & order details.
// ─────────────────────────────────────────────────────────────────────────────

Widget statusBadge(String status) {
  final config = _statusConfig(status);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: config.bg,
      borderRadius: BorderRadius.circular(100),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: config.dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        text(
          text: _formatStatus(status),
          size: 11,
          fontWeight: FontWeight.w600,
          color: config.dot,
        ),
      ],
    ),
  );
}

class _StatusConfig {
  final Color bg;
  final Color dot;
  const _StatusConfig({required this.bg, required this.dot});
}

_StatusConfig _statusConfig(String status) {
  switch (status.toLowerCase().replaceAll('_', '').replaceAll(' ', '')) {
    case 'accepted':
    case 'preparing':
      return _StatusConfig(
        bg: const Color(0xFF00b894).withOpacity(0.12),
        dot: const Color(0xFF00b894),
      );
    case 'ready':
    case 'delivered':
    case 'completed':
      return _StatusConfig(
        bg: const Color(0xFF0984e3).withOpacity(0.12),
        dot: const Color(0xFF0984e3),
      );
    case 'cancelled':
    case 'rejected':
      return _StatusConfig(
        bg: const Color(0xFFd63031).withOpacity(0.12),
        dot: const Color(0xFFd63031),
      );
    case 'pending':
    default:
      return _StatusConfig(
        bg: const Color(0xFFfdcb6e).withOpacity(0.2),
        dot: const Color(0xFFe17055),
      );
  }
}

String _formatStatus(String status) {
  return status
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// Consistent illustrated empty state — replaces scattered Icon() empties.
// ─────────────────────────────────────────────────────────────────────────────

Widget emptyState({
  required IconData icon,
  required String title,
  String? subtitle,
  Widget? action,
  double iconSize = 72,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize + 32,
            height: iconSize + 32,
            decoration: BoxDecoration(
              color: AppColor.appPrimary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: iconSize * 0.65,
              color: AppColor.appPrimary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 20),
          text(
            text: title,
            size: 17,
            fontWeight: FontWeight.w600,
            color: AppColor.black.withOpacity(0.7),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            text(
              text: subtitle,
              size: 13,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.4),
              textAlign: TextAlign.center,
              maxLines: 3,
              overFlow: TextOverflow.ellipsis,
            ),
          ],
          if (action != null) ...[const SizedBox(height: 24), action],
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR STATE
// Consistent error state with retry — replaces scattered error widgets.
// ─────────────────────────────────────────────────────────────────────────────

Widget errorState({
  required String message,
  required VoidCallback onRetry,
  String retryLabel = 'Try Again',
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColor.redColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 40,
              color: AppColor.redColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          text(
            text: 'Something went wrong',
            size: 17,
            fontWeight: FontWeight.w600,
            color: AppColor.black.withOpacity(0.7),
          ),
          const SizedBox(height: 8),
          text(
            text: message,
            size: 13,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.45),
            textAlign: TextAlign.center,
            maxLines: 3,
            overFlow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          button(
            name: retryLabel,
            width: 160,
            height: 48,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            borderRadius: BorderRadius.circular(100),
            onTap: onRetry,
          ),
        ],
      ),
    ),
  );
}
