import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';

import '../../controller/auth_controller.dart';

class LocationStatusWidget extends StatelessWidget {
  final AuthController controller;

  const LocationStatusWidget({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final isLocationReady = controller.latitude != null && controller.longitude != null;

    return Container(
      padding: EdgeInsets.all(responsive.spacing12),
      decoration: BoxDecoration(
        color: isLocationReady ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
        border: Border.all(color: isLocationReady ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          _buildStatusIcon(responsive, isLocationReady),
          SizedBox(width: responsive.spacing12),
          Expanded(child: _buildStatusContent(responsive, isLocationReady)),
          if (controller.isLocationLoading) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(ResponsiveHelper responsive, bool isReady) {
    return Icon(
      isReady ? Icons.check_circle : Icons.location_on,
      color: isReady ? Colors.green : Colors.orange,
      size: responsive.iconSizeSmall,
    );
  }

  Widget _buildStatusContent(ResponsiveHelper responsive, bool isReady) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isReady ? 'Location Captured' : 'Capturing Location...',
          style: TextStyle(
            fontSize: responsive.fontSize14,
            fontWeight: FontWeight.w600,
            color: isReady ? Colors.green : Colors.orange,
          ),
        ),
        SizedBox(height: responsive.spacing4),
        if (isReady) _buildPlaceName(responsive) else _buildLoadingStatus(responsive),
      ],
    );
  }

  Widget _buildPlaceName(ResponsiveHelper responsive) {
    return Text(
      controller.placeName ?? 'Fetching place name...',
      style: TextStyle(
        fontSize: responsive.fontSize12,
        fontWeight: FontWeight.w400,
        color: AppColor.black.withOpacity(0.6),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLoadingStatus(ResponsiveHelper responsive) {
    return Text(
      controller.isLocationLoading ? 'Fetching your location...' : 'Location required',
      style: TextStyle(
        fontSize: responsive.fontSize12,
        fontWeight: FontWeight.w400,
        color: AppColor.black.withOpacity(0.6),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)),
    );
  }
}
