import 'package:eatplek_app/screens/pre_book_details_view/view_model/pre_book_controller.dart';
import 'package:get/get.dart';

class PreBookDetailsBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PrebookDetailController());
  }
}
