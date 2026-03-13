import 'package:eatplek_app/core/network/api_client.dart';
import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../model/user_profile_model.dart';

class ProfileController extends GetxController {
  final FittorConnect _apiClient = FittorConnect();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<UserData?> userData = Rx<UserData?>(null);

  bool _hasFetched = false;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile({bool forceRefresh = false}) async {
    if (_hasFetched && !forceRefresh) {
      debugPrint('👤 ProfileController: Using cached profile data');
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      debugPrint('👤 ProfileController: Fetching profile...');

      final response = await _apiClient.get(endpoint: Urls.getProfileUrl);

      if (response != null && response['success'] == true) {
        final model = UserProfileModel.fromJson(response);
        userData.value = model.data;
        _hasFetched = true;
        debugPrint(
          '✅ ProfileController: Profile fetched — ${userData.value?.name}',
        );
      } else {
        hasError.value = true;
        errorMessage.value = response?['message'] ?? 'Failed to load profile';
        debugPrint('❌ ProfileController: ${errorMessage.value}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('❌ ProfileController: Exception — $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateName(String newName) async {
    try {
      isLoading.value = true;

      final response = await _apiClient.put<Map<String, dynamic>>(
        endpoint: Urls.addUserDetails,
        data: {'name': newName.trim()},
      );

      if (response['success'] == true) {
        if (userData.value != null) {
          userData.value = userData.value!.copyWith(name: newName.trim());
        }
        debugPrint('✅ ProfileController: Name updated to ${newName.trim()}');
        return true;
      } else {
        debugPrint(
          '❌ ProfileController: Name update failed — ${response['message']}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ ProfileController: updateName exception — $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void refresh() => fetchProfile(forceRefresh: true);
}
