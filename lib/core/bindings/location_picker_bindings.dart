import 'package:get/get.dart';

import '../../screens/location_picker_view/controller/location_picker_controller.dart';

class LocationPickerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LocationPickerController());
  }
}
