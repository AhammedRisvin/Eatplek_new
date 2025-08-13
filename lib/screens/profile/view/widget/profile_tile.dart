import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';

class ProfileTile extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final String svgIcon;
  final Color? iconBackgroundColor;
  final Color? borderColor;

  const ProfileTile({
    super.key,
    required this.title,
    required this.svgIcon,
    this.onTap,
    this.iconBackgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _buildLeadingIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: text(
                    text: title,
                    size: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black.withOpacity(0.8),
                  ),
                ),
                _buildTrailingIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: iconBackgroundColor ?? const Color(0xFFF8F8F8),
        border: Border.all(color: borderColor ?? AppColor.black.withOpacity(0.04), width: 1),
      ),
      child: Center(child: SvgPicture.string(svgIcon, color: AppColor.black.withOpacity(0.8), width: 20, height: 20)),
    );
  }

  Widget _buildTrailingIcon() {
    return Icon(Icons.arrow_forward_ios, color: AppColor.black.withOpacity(0.6), size: 16);
  }
}
