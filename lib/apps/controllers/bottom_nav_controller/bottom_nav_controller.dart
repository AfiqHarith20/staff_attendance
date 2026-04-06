import 'package:get/get.dart';

class BottomNavController extends GetxController {
  static BottomNavController get to => Get.find();

  final index = 0.obs;

  void setIndex(int i) {
    if (i < 0) return;
    index(i);
  }
}
