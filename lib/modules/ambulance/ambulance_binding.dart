import 'package:get/get.dart';

import '../../data/services/ambulance_service.dart';
import '../../data/services/booking_service.dart';
import 'ambulance_controller.dart';

class AmbulanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AmbulanceService>(
          () => AmbulanceService(),
    );

    Get.lazyPut<BookingService>(
          () => BookingService(),
    );

    Get.lazyPut<AmbulanceController>(
          () => AmbulanceController(),
    );
  }
}