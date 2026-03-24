import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationPickerController extends GetxController {
  // ─── Map state ────────────────────────────────────────────────────────────
  LatLng currentPosition = const LatLng(11.8705, 75.3679);
  bool isLoadingAddress = false;
  bool isMapInteracting = false;

  // ─── Address state ────────────────────────────────────────────────────────
  String resolvedAddress = '';
  String resolvedCity = '';

  // ─── Search state ─────────────────────────────────────────────────────────
  List<NominatimResult> searchResults = [];
  bool isSearching = false;
  bool showSearchResults = false;
  final TextEditingController searchController = TextEditingController();

  // ─── Update IDs ───────────────────────────────────────────────────────────
  static const String mapId = 'map';
  static const String addressId = 'address';
  static const String searchId = 'search';
  static const String uiVisibilityId = 'uiVisibility';

  Timer? _searchDebounce;
  Timer? _interactionTimer;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;
    final double? initialLat = args?['latitude'] as double?;
    final double? initialLng = args?['longitude'] as double?;

    if (initialLat != null &&
        initialLng != null &&
        initialLat != 0.0 &&
        initialLng != 0.0) {
      currentPosition = LatLng(initialLat, initialLng);
    }

    _resolveAddressFromLatLng(currentPosition);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _interactionTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  // ─── Map interaction ──────────────────────────────────────────────────────

  void onMapInteractionStart() {
    isMapInteracting = true;
    showSearchResults = false;
    _interactionTimer?.cancel();
    update([uiVisibilityId, searchId]);
  }

  void onMapPositionChanged(LatLng newPosition) {
    currentPosition = newPosition;
    update([mapId]);

    _interactionTimer?.cancel();
    _interactionTimer = Timer(const Duration(milliseconds: 600), () {
      isMapInteracting = false;
      update([uiVisibilityId]);
      _resolveAddressFromLatLng(newPosition);
    });
  }

  // ─── Address resolution ───────────────────────────────────────────────────

  Future<void> _resolveAddressFromLatLng(LatLng position) async {
    try {
      isLoadingAddress = true;
      update([addressId]);

      final placemarks = await GeocodingPlatform.instance!
          .placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        resolvedCity =
            place.locality ?? place.administrativeArea ?? 'Unknown City';

        final parts = <String>[
          if (place.name != null && place.name!.isNotEmpty) place.name!,
          if (place.subLocality != null && place.subLocality!.isNotEmpty)
            place.subLocality!,
          if (place.locality != null && place.locality!.isNotEmpty)
            place.locality!,
          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty)
            place.administrativeArea!,
        ];

        resolvedAddress =
            parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';

        debugPrint('📍 Resolved: $resolvedAddress | City: $resolvedCity');
      }
    } catch (e) {
      debugPrint('⚠️ Geocoding error: $e');
      resolvedAddress = 'Unable to resolve address';
      resolvedCity = 'Unknown';
    } finally {
      isLoadingAddress = false;
      update([addressId]);
    }
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  void onSearchChanged(String query) {
    _searchDebounce?.cancel();

    if (query.trim().isEmpty) {
      searchResults = [];
      showSearchResults = false;
      update([searchId]);
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _searchNominatim(query.trim());
    });
  }

  Future<void> _searchNominatim(String query) async {
    try {
      isSearching = true;
      update([searchId]);

      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&addressdetails=1'
        '&limit=6'
        '&accept-language=en',
      );

      final response = await http
          .get(uri, headers: {'User-Agent': 'EatPlekApp/1.0'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        searchResults =
            data.map((item) => NominatimResult.fromJson(item)).toList();
        showSearchResults = searchResults.isNotEmpty;
        debugPrint('🔍 Nominatim: ${searchResults.length} results');
      }
    } catch (e) {
      debugPrint('⚠️ Nominatim error: $e');
      searchResults = [];
      showSearchResults = false;
    } finally {
      isSearching = false;
      update([searchId]);
    }
  }

  void onSearchResultTapped(NominatimResult result) {
    searchController.text = result.displayName;
    searchResults = [];
    showSearchResults = false;
    update([searchId]);

    currentPosition = LatLng(result.lat, result.lng);
    update([mapId]);

    _resolveAddressFromLatLng(currentPosition);
  }

  void clearSearch() {
    searchController.clear();
    searchResults = [];
    showSearchResults = false;
    update([searchId]);
  }

  // ─── Confirm ──────────────────────────────────────────────────────────────

  void confirmLocation() {
    debugPrint(
      '✅ Confirmed: ${currentPosition.latitude}, ${currentPosition.longitude} | $resolvedCity',
    );

    Navigator.of(Get.context!).pop({
      'latitude': currentPosition.latitude,
      'longitude': currentPosition.longitude,
      'city': resolvedCity.isNotEmpty ? resolvedCity : 'Unknown',
      'address': resolvedAddress,
    });
  }
}

// ─── Nominatim result model ────────────────────────────────────────────────

class NominatimResult {
  final double lat;
  final double lng;
  final String displayName;
  final String type;

  NominatimResult({
    required this.lat,
    required this.lng,
    required this.displayName,
    required this.type,
  });

  factory NominatimResult.fromJson(Map<String, dynamic> json) {
    return NominatimResult(
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      lng: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
      displayName: json['display_name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  String get shortName {
    final parts = displayName.split(', ');
    if (parts.length <= 2) return displayName;
    return '${parts[0]}, ${parts[1]}';
  }

  String get secondaryName {
    final parts = displayName.split(', ');
    if (parts.length <= 2) return '';
    return parts.sublist(2).join(', ');
  }
}
