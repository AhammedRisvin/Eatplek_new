import 'package:get/get.dart';

import '../../screens/notification/cotroller/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotificationController>()) {
      Get.lazyPut<NotificationController>(() => NotificationController());
    }
  }
}
