import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/training_records_controller/training_records_controller.dart';

class TrainingRecordsBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<TrainingRecordsController>(() => TrainingRecordsController());
}
