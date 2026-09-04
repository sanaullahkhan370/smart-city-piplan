import 'package:get/get.dart';

import '../../data/services/ambulance_location_service.dart';
import 'admin_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AmbulanceLocationService>(
          () => AmbulanceLocationService(),
    );

    Get.lazyPut<AdminController>(
          () => AdminController(),
    );
  }
}