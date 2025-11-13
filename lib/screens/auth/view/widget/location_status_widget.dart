import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';

import '../../controller/auth_controller.dart';

class LocationStatusWidget extends StatelessWidget {
  final AuthController controller;

  const LocationStatusWidget({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final isLocationReady = controller.latitude != null && controller.longitude != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLocationReady ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isLocationReady ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          _buildStatusIcon(isLocationReady),
          12.w,
          Expanded(child: _buildStatusContent(isLocationReady)),
          if (controller.isLocationLoading) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(bool isReady) {
    return Icon(
      isReady ? Icons.check_circle : Icons.location_on,
      color: isReady ? Colors.green : Colors.orange,
      size: 20,
    );
  }

  Widget _buildStatusContent(bool isReady) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(
          text: isReady ? 'Location Captured' : 'Capturing Location...',
          size: 14,
          fontWeight: FontWeight.w600,
          color: isReady ? Colors.green : Colors.orange,
        ),
        4.h,
        if (isReady) _buildPlaceName() else _buildLoadingStatus(),
      ],
    );
  }

  Widget _buildPlaceName() {
    return text(
      text: controller.placeName ?? 'Fetching place name...',
      size: 12,
      fontWeight: FontWeight.w400,
      color: AppColor.black.withOpacity(0.6),
      maxLines: 2,
      overFlow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLoadingStatus() {
    return text(
      text: controller.isLocationLoading ? 'Fetching your location...' : 'Location required',
      size: 12,
      fontWeight: FontWeight.w400,
      color: AppColor.black.withOpacity(0.6),
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
