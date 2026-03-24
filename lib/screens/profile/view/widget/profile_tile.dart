import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';

class ProfileTile extends StatelessWidget {
  final String title;
  final String svgIcon;
  final VoidCallback onTap;
  final Color? titleColor;

  const ProfileTile({
    super.key,
    required this.title,
    required this.svgIcon,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final isDestructive = titleColor != null;

    return Padding(
      padding: EdgeInsets.only(bottom: responsive.spacing8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
          splashColor: (isDestructive ? AppColor.redColor : AppColor.appPrimary)
              .withOpacity(0.06),
          highlightColor: (isDestructive
                  ? AppColor.redColor
                  : AppColor.appPrimary)
              .withOpacity(0.03),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing16,
              vertical: responsive.spacing14,
            ),
            decoration: BoxDecoration(
              color:
                  isDestructive
                      ? AppColor.redColor.withOpacity(0.04)
                      : AppColor.scaffoldColor,
              borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
              border: Border.all(
                color:
                    isDestructive
                        ? AppColor.redColor.withOpacity(0.12)
                        : AppColor.black.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: responsive.spacing36,
                  height: responsive.spacing36,
                  decoration: BoxDecoration(
                    color:
                        isDestructive
                            ? AppColor.redColor.withOpacity(0.08)
                            : AppColor.appPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(
                      responsive.cardBorderRadius,
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.string(
                      svgIcon,
                      width: responsive.fontSize16,
                      height: responsive.fontSize16,
                      colorFilter: ColorFilter.mode(
                        isDestructive ? AppColor.redColor : AppColor.appPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: responsive.spacing14),

                // Title
                Expanded(
                  child: text(
                    text: title,
                    size: responsive.fontSize14,
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? AppColor.black.withOpacity(0.8),
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  size: responsive.fontSize20,
                  color:
                      isDestructive
                          ? AppColor.redColor.withOpacity(0.5)
                          : AppColor.black.withOpacity(0.25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
