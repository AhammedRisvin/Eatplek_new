import 'package:get/get.dart';

import '../../screens/order_details_view/controller/order_details_controller.dart';

class OrderDetailsBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderDetailsController());
  }
}
