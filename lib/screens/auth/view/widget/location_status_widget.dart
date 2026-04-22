import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';

/// A controller-agnostic location status widget.
/// Any controller passed in must expose:
///   - [double? latitude]
///   - [double? longitude]
///   - [String? placeName]
///   - [bool isLocationLoading]
///
/// Both [AuthController] (legacy) and [ProfileCompletionController] satisfy this.
class LocationStatusWidget extends StatelessWidget {
  final dynamic controller;

  const LocationStatusWidget({required this.controller, super.key});

  bool get _isLocationReady =>
      controller.latitude != null && controller.longitude != null;

  bool get _isLoading => controller.isLocationLoading as bool;

  String? get _placeName => controller.placeName as String?;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      padding: EdgeInsets.all(responsive.spacing12),
      decoration: BoxDecoration(
        color:
            _isLocationReady
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
        border: Border.all(
          color:
              _isLocationReady
                  ? Colors.green.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          _buildStatusIcon(responsive),
          SizedBox(width: responsive.spacing12),
          Expanded(child: _buildStatusContent(responsive)),
          if (_isLoading) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(ResponsiveHelper responsive) {
    return Icon(
      _isLocationReady ? Icons.check_circle : Icons.location_on,
      color: _isLocationReady ? Colors.green : Colors.orange,
      size: responsive.iconSizeSmall,
    );
  }

  Widget _buildStatusContent(ResponsiveHelper responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isLocationReady ? 'Location Captured' : 'Capturing Location...',
          style: TextStyle(
            fontSize: responsive.fontSize14,
            fontWeight: FontWeight.w600,
            color: _isLocationReady ? Colors.green : Colors.orange,
          ),
        ),
        SizedBox(height: responsive.spacing4),
        if (_isLocationReady)
          _buildPlaceName(responsive)
        else
          _buildLoadingStatus(responsive),
      ],
    );
  }

  Widget _buildPlaceName(ResponsiveHelper responsive) {
    return Text(
      _placeName ?? 'Fetching place name...',
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
      _isLoading ? 'Fetching your location...' : 'Location required',
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
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
      ),
    );
  }
}
