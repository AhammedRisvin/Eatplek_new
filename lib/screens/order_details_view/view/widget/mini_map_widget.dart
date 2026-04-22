import 'package:eatplek_app/screens/order_details_view/model/order_details_model.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';

class MiniMapWidget extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onMapTap;
  final VoidCallback onTrackTap;

  const MiniMapWidget({
    super.key,
    required this.restaurant,
    required this.onMapTap,
    required this.onTrackTap,
  });

  @override
  Widget build(BuildContext context) {
    final latLng = LatLng(restaurant.latitude, restaurant.longitude);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03), width: 1),
        boxShadow: [
          BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          10.h,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text(
                        text: 'Track Preparation',
                        size: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      6.h,
                      text(
                        text: 'Real-time updates on your order status.',
                        size: 14,
                        fontWeight: FontWeight.w300,
                        color: AppColor.black.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
                button(
                  name: 'Track',
                  onTap: onTrackTap,
                  width: 70,
                  height: 35,
                  borderRadius: BorderRadius.circular(60),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
          18.h,
          GestureDetector(
            onTap: onMapTap,
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: IgnorePointer(
                  // blocks scroll/zoom gestures, tap bubbles up to GestureDetector
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: latLng,
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none, // disables all gestures
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.eatplek.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: latLng,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
