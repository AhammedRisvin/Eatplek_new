import 'package:get/get.dart';

import '../../screens/auth/controller/profile_completion_controller.dart';

class ProfileCompletionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileCompletionController>(
      () => ProfileCompletionController(),
    );
  }
}
