import 'package:get/get.dart';
import 'hospital_controller.dart';

class HospitalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HospitalController>(() => HospitalController());
  }
}
