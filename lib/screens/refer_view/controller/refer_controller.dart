import 'package:eatplek_app/core/network/api_client.dart';
import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ReferController extends GetxController {
  final FittorConnect _apiClient = FittorConnect();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString referralCode = ''.obs;
  final RxString referredByName = ''.obs;
  final RxString referredByCode = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReferral();
  }

  Future<void> fetchReferral({bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      debugPrint('🎁 ReferController: Fetching referral code...');

      final response = await _apiClient.get(endpoint: Urls.getReferralUrl);

      if (response != null && response['success'] == true) {
        final data = response['data'];
        referralCode.value = data?['referralCode'] ?? '';
        referredByName.value = data?['referredBy']?['name'] ?? '';
        referredByCode.value = data?['referredBy']?['userCode'] ?? '';
        debugPrint('✅ ReferController: Code — ${referralCode.value}');
      } else {
        hasError.value = true;
        errorMessage.value =
            response?['message'] ?? 'Failed to load referral code';
        debugPrint('❌ ReferController: ${errorMessage.value}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('❌ ReferController: Exception — $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void refresh() => fetchReferral(forceRefresh: true);
}
