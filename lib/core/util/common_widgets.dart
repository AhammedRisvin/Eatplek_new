import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

import 'app_color.dart';

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
}) {
  return Text(
    text ?? '',
    maxLines: maxLines,
    textAlign: textAlign,
    style: TextStyle(
      fontSize: size,
      color: color ?? AppColor.black,
      fontWeight: fontWeight,
      fontFamily: fontFamily ?? GoogleFonts.poppins().fontFamily,
      decoration: decoration,
      decorationColor: decorationColor,
      overflow: overFlow,
      wordSpacing: wordSpacing,
      letterSpacing: letterSpacing,
      decorationStyle: decorationStyle,
    ),
  );
}

button({
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
  return InkWell(
    onTap: onTap,
    child: Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: color ?? AppColor.appPrimary,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
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
                    SizedBox(width: 10),
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
  );
}

image({
  required String url,
  double? height,
  double? width,
  BorderRadius? borderRadius, // Accept BorderRadius for flexible corner radii
}) {
  return CachedNetworkImage(
    imageUrl: url,
    height: height,
    width: width,
    imageBuilder: (context, imageProvider) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColor.black,
          borderRadius: borderRadius ?? BorderRadius.zero, // Default to no radius if null
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      );
    },
    placeholder:
        (context, url) => Center(
          child: SizedBox(
            height: height,
            width: width,
            child: Center(child: CircularProgressIndicator(color: AppColor.blueColor)),
          ),
        ),
    errorWidget: (context, url, error) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColor.black,
          borderRadius: borderRadius ?? BorderRadius.zero, // Default to no radius if null
        ),
        child: Image.network(
          height: height,
          width: width,
          'https://t4.ftcdn.net/jpg/04/95/28/65/240_F_495286577_rpsT2Shmr6g81hOhGXALhxWOfx1vOQBa.jpg',
          fit: BoxFit.cover,
        ),
      );
    },
  );
}

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
  EdgeInsetsGeometry? contentPadding = const EdgeInsets.only(left: 20, top: 18, bottom: 18, right: 10),
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
  int hintTextSize = 16,
}) {
  return TextFormField(
    inputFormatters: inputFormatters,
    onChanged: onChanged,
    onFieldSubmitted: onFieldSubmitted,
    onTapOutside: (event) => FocusScope.of(context).unfocus(),
    onTap: onTap,
    style: TextStyle(fontFamily: GoogleFonts.poppins().fontFamily, color: color, fontSize: 14),
    expands: expands,
    keyboardType: keyboardType,
    obscureText: obscureText,
    textInputAction: textInputAction,
    enabled: enabled,
    focusNode: focusNode,
    decoration: InputDecoration(
      prefixIcon: prefixIcon,
      counterText: '',
      contentPadding: contentPadding, // Adjusts placement
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: isFromPhoneText ? BorderSide.none : BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: isFromPhoneText ? BorderSide.none : BorderSide(color: borderColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: isFromPhoneText ? BorderSide.none : BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: isFromPhoneText ? BorderSide.none : const BorderSide(color: Color(0x26000000)),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      suffixIcon: suffixIcon,
      fillColor: bgColor,
      filled: true,
      hintText: hintText, // **Use hintText instead of labelText**
      hintStyle: TextStyle(
        color: hintTextColor,
        fontWeight: FontWeight.w400,
        fontSize: hintTextSize.toDouble(),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      alignLabelWithHint: true, // **Important: Moves hint to the top**
    ),
    validator: validator,
    maxLength: maxLength,
    controller: controller,
    readOnly: readOnly,
    minLines: minLine,
    maxLines: maxLine,
    textAlignVertical: TextAlignVertical.top,
  );
}
