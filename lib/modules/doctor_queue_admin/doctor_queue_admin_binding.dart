import 'package:get/get.dart';
import 'doctor_queue_admin_controller.dart';

class DoctorQueueAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorQueueAdminController>(
      () => DoctorQueueAdminController(),
    );
  }
}
