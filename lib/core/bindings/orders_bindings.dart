import 'package:eatplek_app/screens/orders/controller/orders_controller.dart';
import 'package:get/get.dart';

class OrdersBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersController>(() => OrdersController());
  }
}
