import 'dart:ui' as ui;

import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controller/location_picker_controller.dart';

class LocationPickerView extends StatefulWidget {
  const LocationPickerView({super.key});

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  late final MapController _mapController;
  final responsive = ResponsiveHelper();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationPickerController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColor.scaffoldColor,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // ── Full-screen map ──────────────────────────────────────────
              _buildMap(controller),

              // ── Center pin (always visible) ──────────────────────────────
              _buildCenterPin(),

              // ── Search bar + results (slides up and out on map drag) ─────
              GetBuilder<LocationPickerController>(
                id: LocationPickerController.uiVisibilityId,
                builder: (c) {
                  return AnimatedSlide(
                    offset:
                        c.isMapInteracting ? const Offset(0, -1) : Offset.zero,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      opacity: c.isMapInteracting ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [_buildSearchBar(c), _buildSearchResults(c)],
                      ),
                    ),
                  );
                },
              ),

              // ── Bottom sheet (slides down and out on map drag) ───────────
              GetBuilder<LocationPickerController>(
                id: LocationPickerController.uiVisibilityId,
                builder: (c) {
                  return AnimatedSlide(
                    offset:
                        c.isMapInteracting ? const Offset(0, 1) : Offset.zero,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      opacity: c.isMapInteracting ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: _buildBottomSheet(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Map ──────────────────────────────────────────────────────────────────

  Widget _buildMap(LocationPickerController controller) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: controller.currentPosition,
        initialZoom: 15.0,
        minZoom: 4.0,
        maxZoom: 18.0,
        onMapEvent: (MapEvent event) {
          // Interaction started — hide UI
          if (event is MapEventMoveStart ||
              event is MapEventRotateStart ||
              event is MapEventFlingAnimation) {
            controller.onMapInteractionStart();
          }

          // Live position update while dragging — keeps pin locked to center
          if (event is MapEventMove) {
            controller.onMapPositionChanged(event.camera.center);
          }

          // Interaction ended — resolve address and show UI
          if (event is MapEventMoveEnd ||
              event is MapEventRotateEnd ||
              event is MapEventFlingAnimationEnd) {
            controller.onMapPositionChanged(event.camera.center);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.eatplek.app',
          maxZoom: 19,
        ),
      ],
    );
  }

  // ─── Center pin ───────────────────────────────────────────────────────────

  Widget _buildCenterPin() {
    return Center(
      child: GetBuilder<LocationPickerController>(
        id: LocationPickerController.addressId,
        builder: (controller) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: EdgeInsets.only(
              bottom:
                  controller.isMapInteracting
                      ? responsive.spacing48
                      : responsive.spacing32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pin head
                Container(
                  width: responsive.spacing40,
                  height: responsive.spacing40,
                  decoration: BoxDecoration(
                    color: AppColor.appPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.appPrimary.withOpacity(0.40),
                        blurRadius: responsive.spacing16,
                        spreadRadius: responsive.spacing4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColor.white,
                    size: responsive.spacing24,
                  ),
                ),
                // Pin tail triangle
                CustomPaint(
                  size: Size(responsive.spacing16, responsive.spacing10),
                  painter: _PinTailPainter(color: AppColor.appPrimary),
                ),
                // Shadow dot on map surface
                Container(
                  width: responsive.spacing8,
                  height: responsive.spacing4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(responsive.spacing4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Search bar ───────────────────────────────────────────────────────────

  Widget _buildSearchBar(LocationPickerController controller) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          responsive.spacing16,
          responsive.spacing12,
          responsive.spacing16,
          0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: responsive.spacing16,
                offset: Offset(0, responsive.spacing4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: EdgeInsets.all(responsive.spacing12),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColor.appPrimary,
                    size: responsive.spacing20,
                  ),
                ),
              ),
              // Divider
              Container(
                width: 1,
                height: responsive.spacing24,
                color: AppColor.black.withOpacity(0.08),
              ),
              SizedBox(width: responsive.spacing10),
              // Search input
              Expanded(
                child: GetBuilder<LocationPickerController>(
                  id: LocationPickerController.searchId,
                  builder: (c) {
                    return TextField(
                      controller: c.searchController,
                      onChanged: c.onSearchChanged,
                      style: TextStyle(
                        fontSize: responsive.fontSize14,
                        color: AppColor.black,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search for an area or landmark...',
                        hintStyle: TextStyle(
                          fontSize: responsive.fontSize13,
                          color: AppColor.hintTextColor,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: responsive.spacing14,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Trailing icon — loading / clear / search
              GetBuilder<LocationPickerController>(
                id: LocationPickerController.searchId,
                builder: (c) {
                  if (c.isSearching) {
                    return Padding(
                      padding: EdgeInsets.all(responsive.spacing12),
                      child: SizedBox(
                        width: responsive.spacing18,
                        height: responsive.spacing18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColor.appPrimary,
                        ),
                      ),
                    );
                  }
                  if (c.searchController.text.isNotEmpty) {
                    return GestureDetector(
                      onTap: c.clearSearch,
                      child: Padding(
                        padding: EdgeInsets.all(responsive.spacing12),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColor.greyColor,
                          size: responsive.spacing20,
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.all(responsive.spacing12),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppColor.greyColor,
                      size: responsive.spacing20,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Search results dropdown ──────────────────────────────────────────────

  Widget _buildSearchResults(LocationPickerController controller) {
    return GetBuilder<LocationPickerController>(
      id: LocationPickerController.searchId,
      builder: (c) {
        if (!c.showSearchResults || c.searchResults.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(
            responsive.spacing16,
            responsive.spacing6,
            responsive.spacing16,
            0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: responsive.spacing16,
                  offset: Offset(0, responsive.spacing4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: c.searchResults.length,
                separatorBuilder:
                    (_, _) => Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColor.black.withOpacity(0.06),
                    ),
                itemBuilder: (context, index) {
                  final result = c.searchResults[index];
                  return _buildSearchTile(c, result);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchTile(
    LocationPickerController controller,
    NominatimResult result,
  ) {
    return InkWell(
      onTap: () {
        controller.onSearchResultTapped(result);
        // Move the actual map to selected location
        _mapController.move(LatLng(result.lat, result.lng), 15.0);
        FocusScope.of(context).unfocus();
      },
      splashColor: AppColor.appPrimary.withOpacity(0.06),
      highlightColor: AppColor.appPrimary.withOpacity(0.04),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing16,
          vertical: responsive.spacing12,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(responsive.spacing8),
              decoration: BoxDecoration(
                color: AppColor.appPrimary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: AppColor.appPrimary,
                size: responsive.spacing18,
              ),
            ),
            SizedBox(width: responsive.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.shortName,
                    style: TextStyle(
                      fontSize: responsive.fontSize13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (result.secondaryName.isNotEmpty) ...[
                    SizedBox(height: responsive.spacing3),
                    Text(
                      result.secondaryName,
                      style: TextStyle(
                        fontSize: responsive.fontSize11,
                        fontWeight: FontWeight.w400,
                        color: AppColor.greyColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom sheet ─────────────────────────────────────────────────────────

  Widget _buildBottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          responsive.spacing16,
          0,
          responsive.spacing16,
          responsive.spacing16 + responsive.bottomPadding,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: responsive.spacing24,
                offset: Offset(0, -responsive.spacing4),
              ),
            ],
          ),
          padding: EdgeInsets.all(responsive.spacing20),
          child: GetBuilder<LocationPickerController>(
            id: LocationPickerController.addressId,
            builder: (controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Location header row ──────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(responsive.spacing10),
                        decoration: BoxDecoration(
                          color: AppColor.appPrimary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(
                            responsive.cardBorderRadius,
                          ),
                        ),
                        child: Icon(
                          Icons.my_location_rounded,
                          color: AppColor.appPrimary,
                          size: responsive.spacing20,
                        ),
                      ),
                      SizedBox(width: responsive.spacing12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Location',
                              style: TextStyle(
                                fontSize: responsive.fontSize11,
                                fontWeight: FontWeight.w500,
                                color: AppColor.greyColor,
                                letterSpacing: 0.4,
                              ),
                            ),
                            SizedBox(height: responsive.spacing4),
                            Text(
                              controller.resolvedCity.isNotEmpty
                                  ? controller.resolvedCity
                                  : 'Locating...',
                              style: TextStyle(
                                fontSize: responsive.fontSize18,
                                fontWeight: FontWeight.w700,
                                color: AppColor.appPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: responsive.spacing12),

                  // ── Divider ──────────────────────────────────────────────
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColor.black.withOpacity(0.07),
                  ),

                  SizedBox(height: responsive.spacing12),

                  // ── Address line ─────────────────────────────────────────
                  if (controller.isLoadingAddress)
                    Row(
                      children: [
                        SizedBox(
                          width: responsive.spacing14,
                          height: responsive.spacing14,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColor.appPrimary,
                          ),
                        ),
                        SizedBox(width: responsive.spacing8),
                        Text(
                          'Fetching address...',
                          style: TextStyle(
                            fontSize: responsive.fontSize13,
                            color: AppColor.greyColor,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: responsive.spacing16,
                          color: AppColor.greyColor,
                        ),
                        SizedBox(width: responsive.spacing6),
                        Expanded(
                          child: Text(
                            controller.resolvedAddress.isNotEmpty
                                ? controller.resolvedAddress
                                : 'Move the map to pick a location',
                            style: TextStyle(
                              fontSize: responsive.fontSize13,
                              fontWeight: FontWeight.w400,
                              color: AppColor.black.withOpacity(0.60),
                              height: 1.45,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: responsive.spacing20),

                  // ── Confirm button ───────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: responsive.buttonHeight,
                    child: ElevatedButton(
                      onPressed:
                          controller.isLoadingAddress
                              ? null
                              : controller.confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.appPrimary,
                        disabledBackgroundColor: AppColor.appPrimary
                            .withOpacity(0.45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            responsive.cardBorderRadius,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColor.white,
                            size: responsive.spacing20,
                          ),
                          SizedBox(width: responsive.spacing8),
                          Text(
                            'Confirm Location',
                            style: TextStyle(
                              fontSize: responsive.fontSize15,
                              fontWeight: FontWeight.w700,
                              color: AppColor.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Pin tail triangle painter ────────────────────────────────────────────

class _PinTailPainter extends CustomPainter {
  final Color color;

  const _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final path =
        ui.Path()
          ..moveTo(0, 0)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(size.width, 0)
          ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PinTailPainter oldDelegate) => oldDelegate.color != color;
}
