import 'package:get/get.dart';

class BottomNavController extends GetxController {
  int currentIndex = 0;

  void setBottomBarIndex(int index) {
    currentIndex = index;
    update(['currentIndex']);
  }
}
