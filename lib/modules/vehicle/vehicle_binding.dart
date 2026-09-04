import 'package:get/get.dart';

import '../../data/services/booking_service.dart';
import '../../data/services/vehicle_service.dart';
import 'vehicle_controller.dart';

class VehicleBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<VehicleService>()) {
      Get.lazyPut<VehicleService>(
            () => VehicleService(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<BookingService>()) {
      Get.lazyPut<BookingService>(
            () => BookingService(),
        fenix: true,
      );
    }

    Get.lazyPut<VehicleController>(
          () => VehicleController(),
    );
  }
}