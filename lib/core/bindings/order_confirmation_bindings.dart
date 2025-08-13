import 'package:get/get.dart';

import '../../screens/order_confirmation_view/controller/order_confirmation_controller.dart';

class OrderConfirmationBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderConfirmationController>(() => OrderConfirmationController());
  }
}
