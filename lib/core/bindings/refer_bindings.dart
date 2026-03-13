import 'package:get/get.dart';

import '../../screens/refer_view/controller/refer_controller.dart';

class ReferBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReferController>(() => ReferController());
  }
}
