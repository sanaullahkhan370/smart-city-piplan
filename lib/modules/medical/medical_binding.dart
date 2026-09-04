import 'package:get/get.dart';

import 'medical_controller.dart';

class MedicalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MedicalController>(
          () => MedicalController(),
    );
  }
}